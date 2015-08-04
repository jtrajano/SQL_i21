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
	)
	SELECT	intItemId = ShipmentItems.intItemId
			,intItemLocationId = ItemLocation.intItemLocationId
			,intItemUOMId = ItemUOM.intItemUOMId
			,intLotId = ShipmentItemLots.intLotId
			,dblQty = ShipmentItems.dblQuantity
			,intTransactionId = Shipment.intInventoryShipmentId
			,strTransactionId = Shipment.strShipmentNumber
			,intTransactionTypeId = @intInventoryTransactionType
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItems
				ON Shipment.intInventoryShipmentId = ShipmentItems.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Shipment.intShipFromLocationId = ItemLocation.intLocationId
				AND ShipmentItems.intItemId = ItemLocation.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ShipmentItems.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOiN dbo.tblICInventoryShipmentItemLot ShipmentItemLots
				ON ShipmentItems.intInventoryShipmentItemId = ShipmentItemLots.intInventoryShipmentItemId
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

