CREATE PROCEDURE dbo.uspLGReserveStockForPickLots
	@intPickLotHeaderId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT
DECLARE @strItemNo AS NVARCHAR(50) 
DECLARE @intItemId AS INT 

-- Get the transaction type id
BEGIN 
	SELECT TOP 1 
			@intInventoryTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Pick Lots'
END

-- Get the items to reserve
BEGIN 
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
	SELECT	intItemId = Lot.intItemId
			,intItemLocationId = Lot.intItemLocationId
			,intItemUOMId = Lot.intItemUOMId
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId
			,intStorageLocationId = Lot.intStorageLocationId
			,dblQty = PLDetail.dblLotPickedQty
			,intTransactionId = PLHeader.intPickLotHeaderId
			,strTransactionId = CAST(PLHeader.intReferenceNumber AS VARCHAR(100))
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblLGPickLotDetail PLDetail
			JOIN tblLGPickLotHeader PLHeader ON PLHeader.intPickLotHeaderId = PLDetail.intPickLotHeaderId
			JOIN tblICLot Lot ON Lot.intLotId = PLDetail.intLotId
	WHERE	PLHeader.intPickLotHeaderId = @intPickLotHeaderId
END

-- Validate the reservation 
BEGIN 
	EXEC dbo.uspICValidateStockReserves 
		@ItemsToReserve
		,@strItemNo OUTPUT 
		,@intItemId OUTPUT 
END 

-- If item id is not null, then the reservation is invalid. 
-- The error should be handled by the caller and rollback any data changes. 
IF (@intItemId IS NOT NULL)
BEGIN 
	-- There is not enough stocks for %s
	RAISERROR(51040, 11, 1, @strItemNo)   
END 
ELSE 
BEGIN 
	-- Otherwise, there are enough stocks and let the system create the reservations
	EXEC dbo.uspICCreateStockReservation
		@ItemsToReserve
		,@intPickLotHeaderId
		,@intInventoryTransactionType
END 