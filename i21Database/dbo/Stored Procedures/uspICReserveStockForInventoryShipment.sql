CREATE PROCEDURE dbo.uspICReserveStockForInventoryShipment
	@intTransactionId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToReserve AS dbo.ItemReservationTableType;
DECLARE @InventoryTransactionType AS INT
DECLARE @strItemNo AS NVARCHAR(50) 
DECLARE @intItemId AS INT 

-- Get the transaction type id
BEGIN 
	SELECT TOP 1 
			@InventoryTransactionType = intTransactionTypeId
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
	)
	SELECT	intItemId = ShipmentItems.intItemId
			,intItemLocationId = ItemLocation.intItemLocationId
			,intItemUOMId = ItemUOM.intItemUOMId
			,intLotId = ShipmentItemLots.intLotId
			,dblQty = ShipmentItems.dblQuantity
			,intTransactionId = Shipment.intInventoryShipmentId
			,strTransactionId = Shipment.strReferenceNumber
			,intTransactionTypeId = @InventoryTransactionType
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItems
				ON Shipment.intInventoryShipmentId = ShipmentItems.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Shipment.intShipFromLocationId = ItemLocation.intLocationId
				AND ShipmentItems.intItemId = ItemLocation.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ShipmentItems.intUnitMeasureId = ItemUOM.intItemUOMId
			LEFT JOiN dbo.tblICInventoryShipmentItemLot ShipmentItemLots
				ON ShipmentItems.intInventoryShipmentItemId = ShipmentItemLots.intInventoryShipmentItemId
	WHERE	Shipment.intInventoryShipmentId = @intTransactionId
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
END 