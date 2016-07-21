CREATE PROCEDURE dbo.uspICReserveStockForInventoryShipment
	@intTransactionId AS INT
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

DECLARE @LotType_No AS INT = 0
		,@LotType_YesManual AS INT = 1
		,@LotType_YesSerialNumber AS INT = 2
		-- Value of 0: No
		-- Value of 1: Yes - Manual
		-- Value of 2: Yes - Serial Number

-- Check if Source Type is Pick Lot
IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryShipment WHERE intInventoryShipmentId = @intTransactionId AND intOrderType = 1 AND intSourceType = 3)
BEGIN
	DECLARE @intInventoryTransactionType_PickLot AS INT = 21

	DELETE FROM tblICStockReservation
	WHERE intInventoryTransactionType = @intInventoryTransactionType_PickLot
		AND intTransactionId IN (
			SELECT intSourceId FROM tblICInventoryShipmentItem
			WHERE intInventoryShipmentId = @intTransactionId
		)
END

-- Get the transaction type id
BEGIN 
	SELECT TOP 1 
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
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItems
				ON Shipment.intInventoryShipmentId = ShipmentItems.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Shipment.intShipFromLocationId = ItemLocation.intLocationId
				AND ShipmentItems.intItemId = ItemLocation.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ShipmentItems.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICStorageLocation StorageLocation 
				ON StorageLocation.intStorageLocationId = ShipmentItems.intStorageLocationId
	WHERE	Shipment.intInventoryShipmentId = @intTransactionId
			AND dbo.fnGetItemLotType(ShipmentItems.intItemId) = @LotType_No

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
			,intSubLocationId = ISNULL(ShipmentItems.intSubLocationId, StorageLocation.intSubLocationId) 
			,intStorageLocationId = ShipmentItems.intStorageLocationId
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
			LEFT JOIN dbo.tblICStorageLocation StorageLocation 
				ON StorageLocation.intStorageLocationId = ShipmentItems.intStorageLocationId
	WHERE	Shipment.intInventoryShipmentId = @intTransactionId
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
			,@intTransactionId
			,@intInventoryTransactionType
	END 
END