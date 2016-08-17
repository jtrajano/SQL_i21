CREATE PROCEDURE [dbo].[uspMFTransferKit]
	@strWorkOrderIds nvarchar(max),
	@intLoggedOnLocationId int,
	@intBlendLocationId int,
	@intBlendStagingLocationId int,
	@intUserId int
AS
Begin Try

Declare @intPickListId int
Declare @intManufacturingProcessId int
Declare @intKitStagingLocationId int
--Declare @intLocationId int
Declare @intLotId int
Declare @intNewSubLocationId int
Declare @strLotNumber nvarchar(50)
Declare @intNewLotId int
Declare @intItemId int
Declare @ErrMsg nvarchar(max)
Declare @intMinWorkOrder int
Declare @intMinParentLot int
Declare @intMinChildLot int
Declare @intWorkOrderId int
Declare @intParentLotId int
Declare @dblReqQty numeric(38,20)
Declare @dblAvailableQty numeric(38,20)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @index int
Declare @id int
Declare @ysnBlendSheetRequired bit
Declare @intBlendItemId int
Declare @dblWeightPerUnit numeric(38,20)
Declare @dblMoveQty numeric(38,20)
Declare @intItemUOMId int
Declare @intItemIssuedUOMId int
DECLARE @strInActiveLots NVARCHAR(MAX) 
Declare @intPickListDetailId int
Declare @ysnDirectTransferToBlendFloor bit=0

Declare @strBulkItemXml nvarchar(max)
		,@dblPickQuantity numeric(38,20)
		,@intPickUOMId int
		,@intQtyItemUOMId int
 
Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2

Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLoggedOnLocationId 
and at.strAttributeName='Kit Staging Location'

SELECT @ysnDirectTransferToBlendFloor = CASE 
		WHEN UPPER(pa.strAttributeValue) = 'TRUE'
			THEN 1
		ELSE 0
		END
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLoggedOnLocationId
	AND at.strAttributeName = 'Direct Transfer To Blend Floor'

If ISNULL(@intKitStagingLocationId ,0)=0 AND @ysnDirectTransferToBlendFloor=0
	RaisError('Kit Staging Location is not defined.',16,1)

If ISNULL(@intBlendStagingLocationId ,0)=0
	RaisError('Blend Staging Location is not defined.',16,1)

Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intBlendStagingLocationId

Declare @tblWorkOrder table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int
)

Declare @tblParentLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int,
	intParentLotId int,
	dblReqQty numeric(38,20),
	intItemUOMId int,
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(38,20)
)

Declare @tblChildLot table
(
	intRowNo int Identity(1,1),
	intStageLotId int,
	strStageLotNumber nvarchar(50),
	intItemId int,
	dblAvailableQty numeric(38,20),
	intItemUOMId int,
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(38,20),
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	intPickListDetailId int
)

--Get the Comma Separated Work Order Ids into a table
SET @index = CharIndex(',',@strWorkOrderIds)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strWorkOrderIds,1,@index-1)
        SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds,@index+1,LEN(@strWorkOrderIds)-@index)

        INSERT INTO @tblWorkOrder(intWorkOrderId) values (@id)
        SET @index = CharIndex(',',@strWorkOrderIds)
END
SET @id=@strWorkOrderIds
INSERT INTO @tblWorkOrder(intWorkOrderId) values (@id)


--One WorkOrder one Pick List
If (Select COUNT(1) From @tblWorkOrder)=1
Begin
Select @intWorkOrderId=intWorkOrderId From @tblWorkOrder
Select @intPickListId=intPickListId,@intBlendItemId=intItemId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 8
Begin
	Set @ErrMsg='The Blend Sheet is already transferred.'
	RaisError(@ErrMsg,16,1)
End

If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) <> 12 AND @ysnDirectTransferToBlendFloor=0
Begin
	Set @ErrMsg='The Blend Sheet is not staged.'
	RaisError(@ErrMsg,16,1)
End

If (Select intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 13
Begin
	Set @ErrMsg='The Blend Sheet is already completed.'
	RaisError(@ErrMsg,16,1)
End

If (Select COUNT(1) From tblMFWorkOrder Where intPickListId=@intPickListId)=1
Begin Try

	--Only Active lots are allowed to transfer
	SELECT @strInActiveLots = COALESCE(@strInActiveLots + ', ', '') + l.strLotNumber
	FROM tblMFPickListDetail tpl Join tblICLot l on tpl.intStageLotId=l.intLotId 
	Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId Where tpl.intPickListId=@intPickListId AND ls.strPrimaryStatus<>'Active'

	If ISNULL(@strInActiveLots,'')<>''
	Begin
		Set @ErrMsg='Lots ' + @strInActiveLots + ' are not active. Unable to perform transfer operation.'
		RaisError(@ErrMsg,16,1)
	End
	
	--validate shortage of inventory if direct transfer
	If @ysnDirectTransferToBlendFloor=1
		Exec uspMFValidateTransferKit @intWorkOrderId,0,1

	Begin Tran

	--Create Reservation
	--Get Bulk Items From Reserved Lots
	Set @strBulkItemXml='<root>'

	--Bulk Item
	Select @strBulkItemXml=COALESCE(@strBulkItemXml, '') + '<lot>' + 
	'<intItemId>' + convert(varchar,sr.intItemId) + '</intItemId>' +
	'<intItemUOMId>' + convert(varchar,sr.intItemUOMId) + '</intItemUOMId>' + 
	'<dblQuantity>' + convert(varchar,sr.dblQty) + '</dblQuantity>' + '</lot>'
	From tblICStockReservation sr 
	Where sr.intTransactionId=@intPickListId AND sr.intInventoryTransactionType=34 AND ISNULL(sr.intLotId,0)=0
	AND sr.intItemId NOT IN (Select intItemId From tblMFPickListDetail Where intPickListId=@intPickListId)

	Set @strBulkItemXml=@strBulkItemXml+'</root>'

	If LTRIM(RTRIM(@strBulkItemXml))='<root></root>' 
		Set @strBulkItemXml=''

	EXEC uspMFDeleteLotReservationByPickList @intPickListId = @intPickListId

	If @ysnBlendSheetRequired=0
	Begin
		--Add Parent Lots to Work Order Parent Lot Table
		Delete From tblMFWorkOrderInputParentLot Where intWorkOrderId=@intWorkOrderId

		Insert Into tblMFWorkOrderInputParentLot(intWorkOrderId,intParentLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
		dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId,dblWeightPerUnit,intLocationId,intStorageLocationId)
		Select @intWorkOrderId,intParentLotId,intItemId,SUM(dblQuantity),intItemUOMId,SUM(dblIssuedQuantity),intItemIssuedUOMId,null,
		@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null AS intRecipeItemId,
		(Select TOP 1 dblWeightPerQty From tblICLot Where intParentLotId=pl.intParentLotId) AS dblWeightPerUnit,@intBlendLocationId,null intStorageLocationId
		From tblMFPickListDetail pl 
		Where intPickListId=@intPickListId AND ISNULL(pl.intLotId,0)>0 Group By intParentLotId,intItemId,intItemUOMId,intItemIssuedUOMId

		--Copy Recipe
		Exec uspMFCopyRecipe @intBlendItemId,@intBlendLocationId,@intUserId,@intWorkOrderId
	End

	--Get the child Lots attached to Pick List
	Delete From @tblChildLot
	If ISNULL(@ysnDirectTransferToBlendFloor,0)=0
		Insert Into @tblChildLot(intStageLotId,strStageLotNumber,intItemId,dblAvailableQty,intItemUOMId,intItemIssuedUOMId,dblWeightPerUnit,dblPickQuantity,intPickUOMId,intPickListDetailId)
		Select l.intLotId,l.strLotNumber,l.intItemId,pld.dblQuantity,pld.intItemUOMId,pld.intItemIssuedUOMId,
		CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty,pld.dblPickQuantity,pld.intPickUOMId,pld.intPickListDetailId
		From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId
		Where pld.intPickListId=@intPickListId
		UNION --Non Lot Tracked
		Select 0,'',pld.intItemId,0,pld.intItemUOMId,pld.intItemIssuedUOMId,1,
		pld.dblQuantity,pld.intPickUOMId,pld.intPickListDetailId
		From tblMFPickListDetail pld Join tblICItem i on pld.intItemId=i.intItemId 
		Where pld.intPickListId=@intPickListId AND i.strLotTracking='No'
	Else
		Insert Into @tblChildLot(intStageLotId,strStageLotNumber,intItemId,dblAvailableQty,intItemUOMId,intItemIssuedUOMId,dblWeightPerUnit,dblPickQuantity,intPickUOMId,intPickListDetailId)
		Select l.intLotId,l.strLotNumber,l.intItemId,pld.dblQuantity,pld.intItemUOMId,pld.intItemIssuedUOMId,
		CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty,pld.dblPickQuantity,pld.intPickUOMId,pld.intPickListDetailId
		From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId
		Where pld.intPickListId=@intPickListId AND pld.intLotId=pld.intStageLotId
		UNION --Non Lot Tracked
		Select 0,'',pld.intItemId,0,pld.intItemUOMId,pld.intItemIssuedUOMId,1,
		pld.dblQuantity,pld.intPickUOMId,pld.intPickListDetailId
		From tblMFPickListDetail pld Join tblICItem i on pld.intItemId=i.intItemId 
		Where pld.intPickListId=@intPickListId AND i.strLotTracking='No'

	Select @intMinChildLot=Min(intRowNo) from @tblChildLot

	While(@intMinChildLot is not null) --Loop Child Lot.
	Begin
		Select @dblPickQuantity=NULL,@intPickUOMId=NULL,@intQtyItemUOMId=NULL
		Select @intLotId=intStageLotId,@strLotNumber=strStageLotNumber,@dblReqQty=dblAvailableQty,@intItemId=intItemId,@dblWeightPerUnit=dblWeightPerUnit,@dblPickQuantity=dblPickQuantity,@intPickUOMId=intPickUOMId
				,@intQtyItemUOMId=intItemUOMId,@intPickListDetailId=intPickListDetailId
		From @tblChildLot Where intRowNo=@intMinChildLot

		--Non Lot Tracked Item
		If ISNULL(@intLotId,0)=0
		Begin
			Exec uspMFKitItemMove @intPickListDetailId,@intBlendStagingLocationId,@intUserId

			Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId,intSubLocationId,intStorageLocationId)
			Select @intWorkOrderId,NULL,@intItemId,@dblPickQuantity,@intPickUOMId,
			@dblPickQuantity,@intPickUOMId,null,
			@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null,@intNewSubLocationId,@intBlendStagingLocationId

			GOTO NEXT_RECORD
		End

		Set @intNewLotId=NULL
		Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
		And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

		Set @dblMoveQty=@dblReqQty/@dblWeightPerUnit

		IF NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intLotId AND (intItemUOMId=@intPickUOMId OR intWeightUOMId =@intPickUOMId ))
		BEGIN
			SELECT @dblPickQuantity=@dblReqQty
			SELECT @intPickUOMId=@intQtyItemUOMId
		END

		If ISNULL(@intNewLotId,0) = 0 --Move
			Begin
				Exec [uspMFLotMove] @intLotId=@intLotId,
									@intNewSubLocationId=@intNewSubLocationId,
									@intNewStorageLocationId=@intBlendStagingLocationId,
									@dblMoveQty=@dblPickQuantity,
									@intMoveItemUOMId=@intPickUOMId,
									@intUserId=@intUserId

				Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
				And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

			End
		Else --Merge
			Exec [uspMFLotMerge] @intLotId=@intLotId,
						@intNewLotId=@intNewLotId,
						@dblMergeQty=@dblPickQuantity,
						@intMergeItemUOMId=@intPickUOMId,
						@intUserId=@intUserId
			
		Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
			Select @intWorkOrderId,@intNewLotId,@intItemId,@dblReqQty,intItemUOMId,
			CASE WHEN intItemUOMId=intItemIssuedUOMId THEN @dblReqQty ELSE @dblMoveQty End,intItemIssuedUOMId,null,
			@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null
			From @tblChildLot where intRowNo = @intMinChildLot

		If @ysnDirectTransferToBlendFloor=1
			Update tblMFPickListDetail set intStageLotId=@intNewLotId Where intPickListDetailId=@intPickListDetailId

		NEXT_RECORD:
		Select @intMinChildLot=Min(intRowNo) from @tblChildLot where intRowNo>@intMinChildLot
	End --End Loop Child Lots

	--If all the lots are staged from handheld individually then only add it to Consume lot table
	If Not Exists (Select 1 From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId) AND @ysnDirectTransferToBlendFloor=1
		Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
		dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
		Select @intWorkOrderId,pld.intStageLotId,pld.intItemId,pld.dblQuantity,pld.intItemUOMId,
		pld.dblIssuedQuantity,pld.intItemIssuedUOMId,null,
		@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null
		From tblMFPickListDetail pld where intPickListId = @intPickListId

	Exec [uspMFCreateLotReservation] @intWorkOrderId=@intWorkOrderId,@ysnReservationByParentLot=0,@strBulkItemXml=@strBulkItemXml

	Update tblMFWorkOrder Set intKitStatusId=8,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime,
	intStagingLocationId=@intBlendStagingLocationId,dtmStagedDate=@dtmCurrentDateTime Where intWorkOrderId=@intWorkOrderId

	--All the WOs for the pick list are transfered No
	If Exists (Select 1 From tblMFWorkOrder Where intPickListId=@intPickListId And intKitStatusId <> 8)
	Begin
		--Update Pick List Reservation
		print 'Update Reservation'
	End
	Else --Yes
	Begin
		--Delete Pick List Reservation
		Exec [uspMFDeleteLotReservationByPickList] @intPickListId

		Update tblMFPickList Set intKitStatusId=8,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime Where intPickListId=@intPickListId
	End

	Commit Tran

	return
End Try
Begin Catch
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
End Catch
End


--Multiple Work One Pick List
Select @intMinWorkOrder=Min(intRowNo) from @tblWorkOrder

While(@intMinWorkOrder is not null) --Loop WorkOrders
Begin
	Begin Try

	Select @intWorkOrderId=w.intWorkOrderId,@intPickListId=w.intPickListId,@intBlendItemId=w.intItemId 
	From @tblWorkOrder tw Join tblMFWorkOrder w on tw.intWorkOrderId=w.intWorkOrderId
	Where intRowNo=@intMinWorkOrder

	If @ysnBlendSheetRequired=0
	Begin
		--Add Parent Lots to Work Order Parent Lot Table
		Delete From tblMFWorkOrderInputParentLot Where intWorkOrderId=@intWorkOrderId

		Insert Into tblMFWorkOrderInputParentLot(intWorkOrderId,intParentLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
		dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId,dblWeightPerUnit,intLocationId,intStorageLocationId)
		Select @intWorkOrderId,intParentLotId,intItemId,SUM(dblQuantity),intItemUOMId,SUM(dblIssuedQuantity),intItemIssuedUOMId,null,
		@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null AS intRecipeItemId,
		(Select TOP 1 dblWeightPerQty From tblICLot Where intParentLotId=pl.intParentLotId) AS dblWeightPerUnit,@intBlendLocationId,null intStorageLocationId
		From tblMFPickListDetail pl 
		Where intPickListId=@intPickListId Group By intParentLotId,intItemId,intItemUOMId,intItemIssuedUOMId

		--Copy Recipe
		Exec uspMFCopyRecipe @intBlendItemId,@intBlendLocationId,@intUserId,@intWorkOrderId
	End

	--Validate Transfer
	Exec [uspMFValidateTransferKit] @intWorkOrderId=@intWorkOrderId,@intKitStagingLocationId=@intKitStagingLocationId

	--Get the parent Lots for the workorder
	Delete From @tblParentLot
	Insert Into @tblParentLot(intWorkOrderId,intParentLotId,dblReqQty,intItemUOMId,intItemIssuedUOMId,dblWeightPerUnit)
	Select wi.intWorkOrderId,wi.intParentLotId,wi.dblQuantity,wi.intItemUOMId,wi.intItemIssuedUOMId,wi.dblWeightPerUnit 
	From tblMFWorkOrderInputParentLot wi 
	Join tblMFPickListDetail pld on wi.intParentLotId=pld.intParentLotId
	Where wi.intWorkOrderId=@intWorkOrderId And pld.intPickListId=@intPickListId

	Select @intMinParentLot=Min(intRowNo) from @tblParentLot

	Begin Tran

	While(@intMinParentLot is not null) --Loop Parent Lots
	Begin
	Select @intParentLotId=intParentLotId,@dblReqQty=dblReqQty,--@dblReqQty=CASE WHEN intItemUOMId=intItemIssuedUOMId THEN dblReqQty ELSE dblReqQty * dblWeightPerUnit  End,
	@intItemUOMId=intItemUOMId,@intItemIssuedUOMId=intItemIssuedUOMId 
	From @tblParentLot Where intRowNo=@intMinParentLot

	--Get the child Lots for the Parent Lot
	Delete From @tblChildLot
	Insert Into @tblChildLot(intStageLotId,strStageLotNumber,intItemId,dblAvailableQty,intItemUOMId,intItemIssuedUOMId,dblWeightPerUnit)
	Select l.intLotId,l.strLotNumber,l.intItemId,l.dblWeight,@intItemUOMId,@intItemIssuedUOMId,--pld.intItemUOMId,pld.intItemIssuedUOMId,
	CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId
	Where pld.intPickListId=@intPickListId AND pld.intParentLotId=@intParentLotId AND l.intStorageLocationId=@intKitStagingLocationId AND l.dblWeight>0

	Select @intMinChildLot=Min(intRowNo) from @tblChildLot

	While(@intMinChildLot is not null) --Loop Child Lots
	Begin
		Select @intLotId=intStageLotId,@strLotNumber=strStageLotNumber,@dblAvailableQty=dblAvailableQty,@intItemId=intItemId,@dblWeightPerUnit=dblWeightPerUnit,@intItemUOMId =intItemUOMId
		From @tblChildLot Where intRowNo=@intMinChildLot

		If @dblReqQty <= 0 GOTO NextParentLot

		Set @intNewLotId=NULL
		Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
		And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

		If @dblAvailableQty >= @dblReqQty
		Begin
			Set @dblMoveQty=@dblReqQty/@dblWeightPerUnit

			If ISNULL(@intNewLotId,0) = 0 --Move
				Begin
					Exec [uspMFLotMove] @intLotId=@intLotId,
										@intNewSubLocationId=@intNewSubLocationId,
										@intNewStorageLocationId=@intBlendStagingLocationId,
										@dblMoveQty=@dblReqQty,
										@intMoveItemUOMId=@intItemUOMId,
										@intUserId=@intUserId

					Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
					And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

				End
			Else --Merge
				Exec [uspMFLotMerge] @intLotId=@intLotId,
							@intNewLotId=@intNewLotId,
							@dblMergeQty=@dblReqQty,
							@intMergeItemUOMId=@intItemUOMId,
							@intUserId=@intUserId

			
				Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
				dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
				Select @intWorkOrderId,@intNewLotId,@intItemId,@dblReqQty,intItemUOMId,
				CASE WHEN intItemUOMId=intItemIssuedUOMId THEN @dblReqQty ELSE @dblMoveQty End,intItemIssuedUOMId,null,
				@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null
				From @tblChildLot where intRowNo = @intMinChildLot

				GOTO NextParentLot
		End
		Else
		Begin
			Set @dblMoveQty=@dblAvailableQty/@dblWeightPerUnit

			If ISNULL(@intNewLotId,0) = 0 --Move
				Begin
					Exec [uspMFLotMove] @intLotId=@intLotId,
										@intNewSubLocationId=@intNewSubLocationId,
										@intNewStorageLocationId=@intBlendStagingLocationId,
										@dblMoveQty=@dblAvailableQty,
										@intMoveItemUOMId=@intItemUOMId,
										@intUserId=@intUserId

					Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
					And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

				End
			Else --Merge
				Exec [uspMFLotMerge] @intLotId=@intLotId,
							@intNewLotId=@intNewLotId,
							@dblMergeQty=@dblAvailableQty,
							@intMergeItemUOMId=@intItemUOMId,
							@intUserId=@intUserId

			Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
			Select @intWorkOrderId,@intNewLotId,@intItemId,@dblAvailableQty,intItemUOMId,
			CASE WHEN intItemUOMId=intItemIssuedUOMId THEN @dblAvailableQty ELSE @dblMoveQty End,intItemIssuedUOMId,null,
			@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null
			From @tblChildLot where intRowNo = @intMinChildLot

			Set @dblReqQty = @dblReqQty - @dblAvailableQty
		End

		Select @intMinChildLot=Min(intRowNo) from @tblChildLot where intRowNo>@intMinChildLot
	End --End Loop Child Lots

	NextParentLot:
	Select @intMinParentLot=Min(intRowNo) from @tblParentLot where intRowNo>@intMinParentLot
	End --Loop Parent Lots End

	--Create Reservation
	Exec [uspMFCreateLotReservation] @intWorkOrderId=@intWorkOrderId,@ysnReservationByParentLot=0

	Update tblMFWorkOrder Set intKitStatusId=8,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime,
	intStagingLocationId=@intBlendStagingLocationId,dtmStagedDate=@dtmCurrentDateTime Where intWorkOrderId=@intWorkOrderId

	--All the WOs for the pick list are transfered No
	If Exists (Select 1 From tblMFWorkOrder Where intPickListId=@intPickListId And intKitStatusId <> 8)
	Begin
		--Update Pick List Reservation
		print 'Update Reservation'
	End
	Else --Yes
	Begin
		--Delete Pick List Reservation
		Exec [uspMFDeleteLotReservationByPickList] @intPickListId

		Update tblMFPickList Set intKitStatusId=8,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime Where intPickListId=@intPickListId
	End

	Commit Tran
	
	END TRY  
  
	BEGIN CATCH  
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
	END CATCH  
	
Select @intMinWorkOrder=Min(intRowNo) from @tblWorkOrder where intRowNo>@intMinWorkOrder
End --Loop WorkOrders End

END TRY  
  
BEGIN CATCH  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  