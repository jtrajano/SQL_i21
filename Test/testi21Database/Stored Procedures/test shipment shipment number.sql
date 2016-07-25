CREATE PROCEDURE testi21Database.[test shipment shipment number]
AS
BEGIN
	DECLARE 
		@ExpectedShipmentNumber VARCHAR(50) = 'IS-75',
		@ActualShipmentNumber VARCHAR(50),
		@intUserId INT = 1,
		@ShipmentEntries ShipmentStagingTable,
		@ShipmentCharges ShipmentChargeStagingTable,
		@ShipmentItemLots ShipmentItemLotStagingTable,
		
		@OWNERSHIP_TYPE_Own INT = 1,
		@OWNERSHIP_TYPE_Storage INT = 2,
		@OWNERSHIP_TYPE_ConsignedPurchase INT = 3,

		@ORDER_TYPE_SalesContract INT = 1,
		@ORDER_TYPE_SalesOrder INT = 2,
		@ORDER_TYPE_TransferOrder INT = 3,
		@ORDER_TYPE_Direct INT = 4,

		@SOURCE_TYPE_None INT = 0,
		@SOURCE_TYPE_Scale INT = 1,
		@SOURCE_TYPE_InboundShipment INT = 2,
		@SOURCE_TYPE_PickLot INT = 3

	INSERT INTO @ShipmentEntries(
		intOrderType, intSourceType, intEntityCustomerId, dtmShipDate,
		intShipFromLocationId, intShipToLocationId, intFreightTermId, 
		strBOLNumber, strSourceScreenName,
		
		intItemId, intOwnershipType,
		dblQuantity, intItemUOMId, intItemLotGroup,

		intOrderId, intSourceId, intLineNo)
	SELECT
		intOrderType = @ORDER_TYPE_SalesOrder, -- Sales Order
		intSourceType = @SOURCE_TYPE_None, -- No Source
		intEntityCustomerId = 8, -- Apple Spice Sales
		dtmShipDate = GETDATE(), -- Today
		intShipFromLocationId = 2, -- Fort Wayne
		intShipToLocationId = 638, -- Apple Spice
		intFreightTermId = 3, -- Pickup
		strBOLNumber = 'BOL-1',
		strSourceScreenName = 'Inventory Shipment',
		
		intItemId = 2, 
		intOwnershipType = @OWNERSHIP_TYPE_Storage,
		dblQuantity = 8.5,
		intItemUOMId = 3,
		intItemLotGroup = 1,

		intOrderId = 89,
		intSourceId = NULL,
		intLineNo = NULL

	EXEC dbo.uspICAddItemShipment @ShipmentEntries, @ShipmentCharges, @ShipmentItemLots, @intUserId

	SELECT TOP 1 @ActualShipmentNumber = strShipmentNumber
	FROM tblICInventoryShipment
	ORDER BY intInventoryShipmentId DESC

	EXEC tSQLt.AssertEqualsString @ExpectedShipmentNumber, @ActualShipmentNumber, N'Error creating shipment.'
END
