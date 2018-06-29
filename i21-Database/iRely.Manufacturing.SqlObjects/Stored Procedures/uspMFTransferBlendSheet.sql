CREATE PROCEDURE [dbo].[uspMFTransferBlendSheet]
	@strWorkOrderIds nvarchar(max),
	@intLoggedOnLocationId int,
	@intDestinationLocationId int,
	@intDestinationCellId int,
	@intDestinationStagingLocationId int,
	@intUserId int
AS
Begin Try

Declare @intSourceLocationId int
Declare @intLotId int
Declare @intNewSubLocationId int
Declare @strLotNumber nvarchar(50)
Declare @intNewLotId int
Declare @intBlendItemId int
Declare @strBlendItemNo nvarchar(50)
Declare @intItemId int
Declare @ErrMsg nvarchar(max)
Declare @intMinWorkOrder int
Declare @intMinConsumedLot int
Declare @intWorkOrderId int
Declare @intParentLotId int
Declare @intWorkOrderConsumedLotId int
Declare @dblQuantity numeric(18,6)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @index int
Declare @id int
Declare @strWorkOrderNo nvarchar(50)
Declare @intStatusId int
		,@intItemUOMId int

Declare @tblWorkOrder table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int
)

Declare @tblConsumedLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderConsumedLotId int,
	intLotId int,
	intItemId int,
	dblQuantity numeric(18,6),
	intItemUOMId int
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

Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intDestinationStagingLocationId

Select @intMinWorkOrder=Min(intRowNo) from @tblWorkOrder

While(@intMinWorkOrder is not null) --Loop WorkOrders
Begin
	Begin Try

	Select @intWorkOrderId=w.intWorkOrderId,@strWorkOrderNo=w.strWorkOrderNo,@intStatusId=w.intStatusId,@intSourceLocationId=w.intLocationId,
	@intBlendItemId=w.intItemId,@strBlendItemNo=i.strItemNo 
	From @tblWorkOrder tw Join tblMFWorkOrder w on tw.intWorkOrderId=w.intWorkOrderId 
	Join tblICItem i on w.intItemId=i.intItemId
	Where intRowNo=@intMinWorkOrder

	--Validate Transfer
	If @intStatusId <> 9 
		BEGIN
			SET @ErrMsg='Blend sheet '''+ @strWorkOrderNo +''' transfer cannot be performed, since it is already started.'
			RAISERROR(@ErrMsg,16,1)
		END

	IF EXISTS(SELECT 1 FROM tblMFRecipe r 
			JOIN tblMFRecipeItem ri ON r.intRecipeId=ri.intRecipeId
			AND r.ysnActive=1
			AND r.intLocationId=@intSourceLocationId
			AND r.intItemId=@intBlendItemId
			AND ri.intItemId NOT IN (SELECT ri1.intItemId
									FROM tblMFRecipe r1
									JOIN tblMFRecipeItem ri1 ON r1.intRecipeId=ri1.intRecipeId
									AND r1.ysnActive=1
									AND r1.intLocationId=@intDestinationLocationId
									AND r1.intItemId=@intBlendItemId))
			BEGIN
				SET @ErrMsg='The Input Item(s) configured in the recipe for the Blend '''+ @strBlendItemNo +''' is not same as the recipe configured in the destination location.'
				RAISERROR(@ErrMsg,16,1)
			END

    IF NOT EXISTS(Select 1 From tblMFRecipe Where intItemId=@intBlendItemId AND intLocationId=@intDestinationLocationId AND ysnActive=1)													
	BEGIN
		SET @ErrMsg='The item ' + @strBlendItemNo + ' is not configured in the receipe configuration for the destination location. Please configure this item in Recipe configuration to proceed.'
		RAISERROR(@ErrMsg,16,1)
	END

	IF NOT EXISTS (Select 1 from tblICItemFactoryManufacturingCell fc Join tblICItemFactory il on fc.intItemFactoryId=il.intItemFactoryId 
	Where il.intFactoryId=@intDestinationLocationId AND il.intItemId=@intBlendItemId AND fc.intManufacturingCellId=@intDestinationCellId)
	BEGIN
		SET @ErrMsg='The item ' + @strBlendItemNo + ' is not configured for the selected production line.'
		RAISERROR(@ErrMsg,16,1)
	END

	--Get the consumed Lots for the workorder
	Delete From @tblConsumedLot
	Insert Into @tblConsumedLot(intWorkOrderConsumedLotId,intLotId,intItemId,dblQuantity,intItemUOMId)
	Select wc.intWorkOrderConsumedLotId,wc.intLotId,wc.intItemId,wc.dblQuantity,wc.intItemUOMId
	From tblMFWorkOrderConsumedLot wc 
	Where wc.intWorkOrderId=@intWorkOrderId

	Select @intMinConsumedLot=Min(intRowNo) from @tblConsumedLot

	Begin Tran

	UPDATE tblMFWorkOrder SET intLocationId=@intDestinationLocationId, intManufacturingCellId=@intDestinationCellId WHERE intWorkOrderId=@intWorkOrderId
	UPDATE tblMFWorkOrderRecipe SET intLocationId=@intDestinationLocationId Where intWorkOrderId=@intWorkOrderId

	While(@intMinConsumedLot is not null) --Loop WO Consumed Lots
	Begin
	Select @intWorkOrderConsumedLotId=intWorkOrderConsumedLotId,@intLotId=intLotId,@intItemId=intItemId ,@dblQuantity=dblQuantity,@intItemUOMId=intItemUOMId
	From @tblConsumedLot Where intRowNo=@intMinConsumedLot

	Exec [uspMFLotMove] @intLotId=@intLotId,
						@intNewSubLocationId=@intNewSubLocationId,
						@intNewStorageLocationId=@intDestinationStagingLocationId,
						@dblMoveQty=@dblQuantity,
						@intMoveItemUOMId=@intItemUOMId,
						@intUserId=@intUserId

	Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intDestinationLocationId
	And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intDestinationStagingLocationId --And dblQty > 0

	Update tblMFWorkOrderConsumedLot Set intLotId=@intNewLotId,dtmLastModified=@dtmCurrentDateTime,intLastModifiedUserId=@intUserId 
	Where intWorkOrderConsumedLotId=@intWorkOrderConsumedLotId

	Update tblMFWorkOrder Set intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime,
	intStagingLocationId=@intDestinationStagingLocationId,dtmStagedDate=@dtmCurrentDateTime Where intWorkOrderId=@intWorkOrderId

	--Update Reservation
	Update tblICStockReservation Set intLotId=@intNewLotId 
	Where intTransactionId=@intWorkOrderId AND intInventoryTransactionType=8 AND intLotId=@intLotId

	Select @intMinConsumedLot=Min(intRowNo) from @tblConsumedLot where intRowNo>@intMinConsumedLot
	End --Loop WO Consumed Lots End

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
