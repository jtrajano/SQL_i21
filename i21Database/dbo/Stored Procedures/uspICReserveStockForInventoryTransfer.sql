CREATE PROCEDURE dbo.uspICReserveStockForInventoryTransfer
	@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @intInventoryTransactionType AS INT

DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT 
		,@intReturn AS INT = 0 


DECLARE @Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2
		,@Ownership_Consigned AS INT = 3

-- Get the transaction type id
BEGIN 
	SELECT	TOP 1 
			@intInventoryTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Inventory Transfer'
END

-- Get the items to reserve
BEGIN 
	INSERT INTO @ItemsToReserve (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,dblQty
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		,intSubLocationId
		,intStorageLocationId
		,intOwnershipTypeId
	)
	SELECT 
		intItemId = td.intItemId 
		,intItemLocationId = il.intItemLocationId 
		,intItemUOMId = td.intItemUOMId
		,intLotId = td.intLotId 
		,dblQty = td.dblQuantity
		,intTransactionId = t.intInventoryTransferId
		,strTransactionId = t.strTransferNo 
		,intTransactionTypeId = @intInventoryTransactionType
		,intSubLocationId = td.intFromSubLocationId
		,intStorageLocationId = td.intFromStorageLocationId
		,intOwnershipTypeId = td.intOwnershipType
	FROM
		tblICInventoryTransfer t INNER JOIN tblICInventoryTransferDetail td
			ON t.intInventoryTransferId = td.intInventoryTransferId
		INNER JOIN tblICItem i 
			ON i.intItemId = td.intItemId 
		INNER JOIN tblICItemLocation il
			ON il.intItemId = i.intItemId
			AND il.intLocationId = t.intFromLocationId 
	WHERE
		t.intInventoryTransferId = @intTransactionId
		AND i.strType IN ('Inventory', 'Finished Good', 'Raw Material')
		AND td.intOwnershipType = @Ownership_Own
END

-- Do the reservations
BEGIN 
	-- Validate the reservation 
	EXEC @intReturn = dbo.uspICValidateStockReserves 
		@ItemsToReserve
		,@strInvalidItemNo OUTPUT 
		,@intInvalidItemId OUTPUT 

	IF @intReturn <> 0 
		RETURN @intReturn

	-- If there are enough stocks, let the system create the reservations
	IF (@intInvalidItemId IS NULL)	
	BEGIN 
		EXEC @intReturn = dbo.uspICCreateStockReservation
			@ItemsToReserve
			,@intTransactionId
			,@intInventoryTransactionType

		IF @intReturn <> 0 
			RETURN @intReturn
	END 
END

RETURN @intReturn