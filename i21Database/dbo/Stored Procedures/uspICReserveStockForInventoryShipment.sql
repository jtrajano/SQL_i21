﻿CREATE PROCEDURE dbo.uspICReserveStockForInventoryShipment
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

DECLARE @LotType_No AS INT = 0
		,@LotType_YesManual AS INT = 1
		,@LotType_YesSerialNumber AS INT = 2
		-- Value of 0: No
		-- Value of 1: Yes - Manual
		-- Value of 2: Yes - Serial Number

DECLARE @Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2
		,@Ownership_Consigned AS INT = 3


-- Check if Source Type is Pick Lot
IF EXISTS(
	SELECT	TOP 1 1 
	FROM	tblICInventoryShipment 
	WHERE	intInventoryShipmentId = @intTransactionId 
			AND intOrderType = 1 
			AND intSourceType = 3
)
BEGIN
	DECLARE @intInventoryTransactionType_PickLot AS INT = 21

	-- Delete the reservation for the Pick Lot transaction 	
	DELETE	StockReservation
	FROM	tblICStockReservation StockReservation INNER JOIN tblICInventoryShipmentItem si
				ON StockReservation.intTransactionId = si.intSourceId
	WHERE	si.intInventoryShipmentId = @intTransactionId
			AND StockReservation.intInventoryTransactionType =  @intInventoryTransactionType_PickLot
END

-- Get the transaction type id
BEGIN 
	SELECT	TOP 1 
			@intInventoryTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Inventory Shipment'
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
	-- Non-Lot Tracked Items
	SELECT	intItemId = ShipmentItems.intItemId
			,intItemLocationId = ItemLocation.intItemLocationId
			,intItemUOMId = ItemUOM.intItemUOMId
			,intLotId = NULL 
			,dblQty = ShipmentItems.dblQuantity
			,intTransactionId = Shipment.intInventoryShipmentId
			,strTransactionId = Shipment.strShipmentNumber
			,intTransactionTypeId = @intInventoryTransactionType
			,intSubLocationId = ISNULL(ShipmentItems.intSubLocationId, StorageLocation.intSubLocationId) 
			,intStorageLocationId = ShipmentItems.intStorageLocationId
			,intOwnershipTypeId = ShipmentItems.intOwnershipType
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItems
				ON Shipment.intInventoryShipmentId = ShipmentItems.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Shipment.intShipFromLocationId = ItemLocation.intLocationId
				AND ShipmentItems.intItemId = ItemLocation.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ShipmentItems.intItemUOMId = ItemUOM.intItemUOMId
			INNER JOIN tblICItem Item 
				ON Item.intItemId = ShipmentItems.intItemId
			LEFT JOIN dbo.tblICStorageLocation StorageLocation 
				ON StorageLocation.intStorageLocationId = ShipmentItems.intStorageLocationId
	WHERE	Shipment.intInventoryShipmentId = @intTransactionId
			AND dbo.fnGetItemLotType(ShipmentItems.intItemId) = @LotType_No
			AND ISNULL(ShipmentItems.intOwnershipType, @Ownership_Own) = @Ownership_Own
			AND Item.strType <> 'Bundle' -- Do not make reservations on bundle types			

	-- Lot Tracked items 
	UNION ALL 
	SELECT	intItemId = ShipmentItems.intItemId
			,intItemLocationId = ItemLocation.intItemLocationId
			,intItemUOMId = ISNULL(Lot.intItemUOMId, ItemUOM.intItemUOMId)
			,intLotId = Lot.intLotId
			,dblQty = ISNULL(ShipmentItemLots.dblQuantityShipped, ShipmentItems.dblQuantity)
			,intTransactionId = Shipment.intInventoryShipmentId
			,strTransactionId = Shipment.strShipmentNumber
			,intTransactionTypeId = @intInventoryTransactionType
			,intSubLocationId = Lot.intSubLocationId  
			,intStorageLocationId = Lot.intStorageLocationId 
			,intOwnershipTypeId = ShipmentItems.intOwnershipType
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItems
				ON Shipment.intInventoryShipmentId = ShipmentItems.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Shipment.intShipFromLocationId = ItemLocation.intLocationId
				AND ShipmentItems.intItemId = ItemLocation.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ShipmentItems.intItemUOMId = ItemUOM.intItemUOMId
			INNER JOIN dbo.tblICInventoryShipmentItemLot ShipmentItemLots
				ON ShipmentItems.intInventoryShipmentItemId = ShipmentItemLots.intInventoryShipmentItemId
			INNER JOIN dbo.tblICLot Lot
				ON Lot.intLotId = ShipmentItemLots.intLotId
				AND Lot.intItemLocationId = ItemLocation.intItemLocationId
			INNER JOIN tblICItem Item
				ON Item.intItemId = ShipmentItems.intItemId
	WHERE	Shipment.intInventoryShipmentId = @intTransactionId
			AND ISNULL(ShipmentItems.intOwnershipType, @Ownership_Own) = @Ownership_Own
			AND Item.strType <> 'Bundle' -- Do not make reservations on bundle types
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