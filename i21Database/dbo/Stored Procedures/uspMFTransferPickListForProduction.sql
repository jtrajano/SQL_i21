CREATE PROCEDURE [dbo].[uspMFTransferPickListForProduction]
	@intWorkOrderId int,
	@intLocationId int,
	@intProductionStagingLocationId int,
	@intUserId int
AS
Begin Try

Declare @intPickListId int
Declare @intManufacturingProcessId int
Declare @intLotId int
Declare @intNewSubLocationId int
Declare @strLotNumber nvarchar(50)
Declare @intNewLotId int
Declare @intItemId int
Declare @ErrMsg nvarchar(max)
Declare @intMinWorkOrder int
Declare @intMinParentLot int
Declare @intMinChildLot int
Declare @intParentLotId int
Declare @dblReqQty numeric(38,20)
Declare @dblAvailableQty numeric(38,20)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @index int
Declare @id int
Declare @intBlendItemId int
Declare @dblWeightPerUnit numeric(38,20)
Declare @intItemUOMId int
Declare @intItemIssuedUOMId int
DECLARE @strInActiveLots NVARCHAR(MAX) 
Declare @intPickListDetailId int

Declare @strBulkItemXml nvarchar(max)
		,@dblPickQuantity numeric(38,20)
		,@intPickUOMId int
		,@intQtyItemUOMId int
 
If ISNULL(@intProductionStagingLocationId ,0)=0
	RaisError('Blend Staging Location is not defined.',16,1)

Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intProductionStagingLocationId

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

Select @intPickListId=intPickListId,@intBlendItemId=intItemId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 8
Begin
	Set @ErrMsg='The Work Order is already transferred.'
	RaisError(@ErrMsg,16,1)
End

If (Select intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 13
Begin
	Set @ErrMsg='The Work Order is already completed.'
	RaisError(@ErrMsg,16,1)
End

--Only Active lots are allowed to transfer
SELECT @strInActiveLots = COALESCE(@strInActiveLots + ', ', '') + l.strLotNumber
FROM tblMFPickListDetail tpl Join tblICLot l on tpl.intLotId=l.intLotId 
Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId Where tpl.intPickListId=@intPickListId AND ls.strPrimaryStatus<>'Active'

If ISNULL(@strInActiveLots,'')<>''
Begin
	Set @ErrMsg='Lots ' + @strInActiveLots + ' are not active. Unable to perform transfer operation.'
	RaisError(@ErrMsg,16,1)
End
	
	--validate shortage of inventory
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

	--Get the child Lots attached to Pick List
	Delete From @tblChildLot
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
			Exec uspMFKitItemMove @intPickListDetailId,@intProductionStagingLocationId,@intUserId

			Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId,intStorageLocationId)
			Select @intWorkOrderId,NULL,@intItemId,@dblPickQuantity,@intPickUOMId,
			@dblPickQuantity,@intPickUOMId,null,
			@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null,@intProductionStagingLocationId

			GOTO NEXT_RECORD
		End

		Set @intNewLotId=NULL
		Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intLocationId 
		And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intProductionStagingLocationId --And dblQty > 0

		--IF NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intLotId AND (intItemUOMId=@intPickUOMId OR intWeightUOMId =@intPickUOMId ))
		--BEGIN
		--	SELECT @dblPickQuantity=@dblReqQty
		--	SELECT @intPickUOMId=@intQtyItemUOMId
		--END

		If ISNULL(@intNewLotId,0) = 0 --Move
			Begin
				Exec [uspMFLotMove] @intLotId=@intLotId,
									@intNewSubLocationId=@intNewSubLocationId,
									@intNewStorageLocationId=@intProductionStagingLocationId,
									@dblMoveQty=@dblPickQuantity,
									@intMoveItemUOMId=@intPickUOMId,
									@intUserId=@intUserId

				Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intLocationId 
				And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intProductionStagingLocationId --And dblQty > 0

			End
		Else --Merge
			Exec [uspMFLotMerge] @intLotId=@intLotId,
						@intNewLotId=@intNewLotId,
						@dblMergeQty=@dblPickQuantity,
						@intMergeItemUOMId=@intPickUOMId,
						@intUserId=@intUserId
			
		Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
			Select @intWorkOrderId,@intNewLotId,@intItemId,dblPickQuantity,intPickUOMId,
			dblPickQuantity,intPickUOMId,null,
			@dtmCurrentDateTime,@intUserId,@dtmCurrentDateTime,@intUserId,null
			From @tblChildLot where intRowNo = @intMinChildLot

		Update tblMFPickListDetail set intStageLotId=@intNewLotId Where intPickListDetailId=@intPickListDetailId

		NEXT_RECORD:
		Select @intMinChildLot=Min(intRowNo) from @tblChildLot where intRowNo>@intMinChildLot
	End --End Loop Child Lots

	Exec [uspMFCreateLotReservation] @intWorkOrderId=@intWorkOrderId,@ysnReservationByParentLot=0,@strBulkItemXml=@strBulkItemXml

	Update tblMFWorkOrder Set intKitStatusId=8,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime,
	intStagingLocationId=@intProductionStagingLocationId,dtmStagedDate=@dtmCurrentDateTime Where intWorkOrderId=@intWorkOrderId

	Commit Tran

End Try
Begin Catch
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
End Catch
