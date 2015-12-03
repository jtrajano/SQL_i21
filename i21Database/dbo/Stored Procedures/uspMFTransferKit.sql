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
Declare @dblReqQty numeric(18,6)
Declare @dblAvailableQty numeric(18,6)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @index int
Declare @id int
Declare @ysnBlendSheetRequired bit
Declare @intBlendItemId int
Declare @dblWeightPerUnit numeric(18,6)
Declare @dblMoveQty numeric(18,6)
Declare @intItemUOMId int
Declare @intItemIssuedUOMId int
 
Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2

Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLoggedOnLocationId 
and at.strAttributeName='Kit Staging Location'

If ISNULL(@intKitStagingLocationId ,0)=0
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
	dblReqQty numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(18,6)
)

Declare @tblChildLot table
(
	intRowNo int Identity(1,1),
	intStageLotId int,
	strStageLotNumber nvarchar(50),
	intItemId int,
	dblAvailableQty numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(18,6)
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
	Select DISTINCT wi.intWorkOrderId,wi.intParentLotId,wi.dblIssuedQuantity,wi.intItemUOMId,wi.intItemIssuedUOMId,wi.dblWeightPerUnit 
	From tblMFWorkOrderInputParentLot wi 
	Join tblMFPickListDetail pld on wi.intParentLotId=pld.intParentLotId
	Where wi.intWorkOrderId=@intWorkOrderId And pld.intPickListId=@intPickListId

	Select @intMinParentLot=Min(intRowNo) from @tblParentLot

	Begin Tran

	While(@intMinParentLot is not null) --Loop Parent Lots
	Begin
	Select @intParentLotId=intParentLotId,@dblReqQty=CASE WHEN intItemUOMId=intItemIssuedUOMId THEN dblReqQty ELSE dblReqQty * dblWeightPerUnit  End,
	@intItemUOMId=intItemUOMId,@intItemIssuedUOMId=intItemIssuedUOMId 
	From @tblParentLot Where intRowNo=@intMinParentLot

	--Get the child Lots for the Parent Lot
	Delete From @tblChildLot
	Insert Into @tblChildLot(intStageLotId,strStageLotNumber,intItemId,dblAvailableQty,intItemUOMId,intItemIssuedUOMId,dblWeightPerUnit)
	Select DISTINCT l.intLotId,l.strLotNumber,l.intItemId,l.dblWeight,@intItemUOMId,@intItemIssuedUOMId,--pld.intItemUOMId,pld.intItemIssuedUOMId,
	CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId
	Where pld.intPickListId=@intPickListId AND pld.intParentLotId=@intParentLotId AND l.intStorageLocationId=@intKitStagingLocationId

	Select @intMinChildLot=Min(intRowNo) from @tblChildLot

	While(@intMinChildLot is not null) --Loop Child Lots
	Begin
		Select @intLotId=intStageLotId,@strLotNumber=strStageLotNumber,@dblAvailableQty=dblAvailableQty,@intItemId=intItemId,@dblWeightPerUnit=dblWeightPerUnit
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
										@dblMoveQty=@dblMoveQty,
										@intUserId=@intUserId

					Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
					And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

				End
			Else --Merge
				Exec [uspMFLotMerge] @intLotId=@intLotId,
							@intNewLotId=@intNewLotId,
							@dblMergeQty=@dblMoveQty,
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
										@dblMoveQty=@dblMoveQty,
										@intUserId=@intUserId

					Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intBlendLocationId 
					And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intBlendStagingLocationId --And dblQty > 0

				End
			Else --Merge
				Exec [uspMFLotMerge] @intLotId=@intLotId,
							@intNewLotId=@intNewLotId,
							@dblMergeQty=@dblMoveQty,
							@intUserId=@intUserId

			Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
			dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId)
			Select @intWorkOrderId,@intNewLotId,@intItemId,@dblAvailableQty,intItemUOMId,
			CASE WHEN intItemUOMId=intItemIssuedUOMId THEN @dblReqQty ELSE @dblMoveQty End,intItemIssuedUOMId,null,
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