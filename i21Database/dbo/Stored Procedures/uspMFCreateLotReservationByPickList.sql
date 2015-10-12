CREATE PROCEDURE [dbo].[uspMFCreateLotReservationByPickList]
	@intPickListId int
AS

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT=22
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 
DECLARE @intMinWO int
DECLARE @intWorkOrderId int

	--Delete all Reservation against all WorkOrders for the Pick List
	Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder Where intPickListId=@intPickListId

	While(@intMinWO is not null)
	Begin
		Select @intWorkOrderId=intWorkOrderId from tblMFWorkOrder Where intWorkOrderId=@intMinWO

		EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intWorkOrderId
		,8

		Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder where intPickListId=@intPickListId And intWorkOrderId>@intWorkOrderId
	End

	--Delete Reservation against Pick List
	EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intPickListId
		,@intInventoryTransactionType

	--Create Reservation against Pick List
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
	SELECT	intItemId = pld.intItemId
			,intItemLocationId = l.intItemLocationId
			,intItemUOMId = pld.intItemUOMId
			,intLotId = pld.intStageLotId
			,intSubLocationId = l.intSubLocationId
			,intStorageLocationId = l.intStorageLocationId
			,dblQty = pld.dblPickQuantity * (CASE WHEN ISNULL(l.dblWeightPerQty,0) = 0 THEN 1 ELSE l.dblWeightPerQty END)
			,intTransactionId = pld.intPickListId
			,strTransactionId = pl.strPickListNo
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblMFPickListDetail pld 
			Join tblMFPickList pl on pld.intPickListId=pl.intPickListId
			JOIN tblICLot l ON l.intLotId = pld.intLotId
	WHERE	pld.intPickListId = @intPickListId

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
			,@intPickListId
			,@intInventoryTransactionType	
	END 	
