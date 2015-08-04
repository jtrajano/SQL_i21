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
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 

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

-- Do the reservations
BEGIN 
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
			,@intPickLotHeaderId
			,@intInventoryTransactionType	
	END 	

END 

