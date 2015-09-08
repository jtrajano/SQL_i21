CREATE PROCEDURE [dbo].[uspMFCreateLotReservation]
	@intWorkOrderId int,
	@ysnReservationByParentLot bit=0
AS

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT=8
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 

If @ysnReservationByParentLot=0
Begin
	INSERT INTO @ItemsToReserve (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
	)
	SELECT	intItemId = wcl.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = wcl.intItemUOMId
			,intLotId = wcl.intLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = wcl.dblQuantity
			,intTransactionId = wcl.intWorkOrderId
			,strTransactionId = w.strWorkOrderNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFWorkOrderConsumedLot wcl
			JOIN tblMFWorkOrder w ON w.intWorkOrderId = wcl.intWorkOrderId
			JOIN tblICLot l ON l.intLotId = wcl.intLotId
	WHERE	wcl.intWorkOrderId = @intWorkOrderId
End
--Else
--Begin

--End

	-- Validate the reservation 
	EXEC dbo.uspICValidateStockReserves 
		@ItemsToReserve
		,@strInvalidItemNo OUTPUT 
		,@intInvalidItemId OUTPUT 

	-- If there are enough stocks, let the system create the reservations
	IF (@intInvalidItemId IS NULL)	
	BEGIN 
		EXEC dbo.uspICCreateStockReservation
			@ItemsToReserve
			,@intWorkOrderId
			,@intInventoryTransactionType	
	END 	