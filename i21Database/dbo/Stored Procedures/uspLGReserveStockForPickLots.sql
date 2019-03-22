CREATE PROCEDURE dbo.uspLGReserveStockForPickLots
	@intPickLotHeaderId AS INT = NULL
	,@intLoadDetailId AS INT = NULL
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
DECLARE @intLoadId INT

-- Get the transaction type id
SELECT TOP 1 
		@intInventoryTransactionType = intTransactionTypeId
FROM	dbo.tblICInventoryTransactionType
WHERE	strName = CASE WHEN (@intLoadDetailId IS NULL) THEN 'Pick Lots' ELSE 'Outbound Shipment' END

-- Get the items to reserve
IF (@intLoadDetailId IS NULL)
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
			,strTransactionId = CAST(PLHeader.[strPickLotNumber] AS VARCHAR(100))
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblLGPickLotDetail PLDetail
			JOIN tblLGPickLotHeader PLHeader ON PLHeader.intPickLotHeaderId = PLDetail.intPickLotHeaderId
			JOIN tblICLot Lot ON Lot.intLotId = PLDetail.intLotId
	WHERE	PLHeader.intPickLotHeaderId = @intPickLotHeaderId
END
ELSE
BEGIN
	SELECT @intLoadId = intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId 

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
			,dblQty = LDLot.dblLotQuantity
			,intTransactionId = L.intLoadId
			,strTransactionId = CAST(L.strLoadNumber AS VARCHAR(100))
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	tblLGLoadDetail LD
			JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			JOIN tblLGLoadDetailLot LDLot ON LD.intLoadDetailId = LDLot.intLoadDetailId
			JOIN tblICLot Lot ON Lot.intLotId = LDLot.intLotId
	WHERE	LD.intLoadDetailId = @intLoadDetailId
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
		IF (@intLoadId IS NOT NULL)
			EXEC dbo.uspICCreateStockReservation
				@ItemsToReserve
				,@intLoadId
				,@intInventoryTransactionType	
		ELSE
			EXEC dbo.uspICCreateStockReservation
				@ItemsToReserve
				,@intPickLotHeaderId
				,@intInventoryTransactionType	
	END 	

END 