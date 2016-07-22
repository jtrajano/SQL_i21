CREATE PROCEDURE testi21Database.[test shipment with duplicate items]
AS
BEGIN
	CREATE TABLE expected_tblICInventoryShipmentItem (intItemId INT, intOwnershipType INT, 
		dblQuantity NUMERIC(38, 20), intItemUOMId INT)
		
	CREATE TABLE actual_tblICInventoryShipmentItem (intItemId INT, intOwnershipType INT, 
		dblQuantity NUMERIC(38, 20), intItemUOMId INT)

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

		-- Test Values
		DECLARE @intItemId INT = 2,	@intOwnerShipType INT = @OWNERSHIP_TYPE_Storage, 
		@dblQuantity INT = 1, @intItemUOMId INT = 7

	INSERT INTO @ShipmentEntries(
		intOrderType, intSourceType, intEntityCustomerId, dtmShipDate,
		intShipFromLocationId, intShipToLocationId, intFreightTermId, 
		strBOLNumber, strSourceScreenName,
		
		intItemId, intOwnershipType,
		dblQuantity, intItemUOMId, intItemLotGroup,

		intOrderId, intSourceId, intLineNo, dblUnitPrice, intWeightUOMId)
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
		
		intItemId = @intItemId, 
		intOwnershipType = @intOwnerShipType,
		dblQuantity = @dblQuantity, -- Quantity should be greater than zero.
		intItemUOMId = @intItemUOMId,
		intItemLotGroup = 1,

		intOrderId = 89,
		intSourceId = NULL,
		intLineNo = 100,
		dblUnitPrice = 10.0,
		intWeightUOMId = 7
	UNION ALL
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
		
		intItemId = @intItemId, 
		intOwnershipType = @intOwnerShipType,
		dblQuantity = @dblQuantity, -- Quantity should be greater than zero.
		intItemUOMId = @intItemUOMId,
		intItemLotGroup = 2,

		intOrderId = 89,
		intSourceId = NULL,
		intLineNo = 100,
		dblUnitPrice = 10.0,
		intWeightUOMId = 7

	EXEC dbo.uspICAddItemShipment @ShipmentEntries, @ShipmentCharges, @ShipmentItemLots, @intUserId

	SELECT TOP 1 @ActualShipmentNumber = strShipmentNumber
	FROM tblICInventoryShipment
	ORDER BY intInventoryShipmentId DESC

	EXEC tSQLt.AssertEqualsString @ExpectedShipmentNumber, @ActualShipmentNumber, N'Error creating shipment.'
	
	-- Expected
	INSERT INTO expected_tblICInventoryShipmentItem(intItemId, intOwnershipType, dblQuantity, intItemUOMId)
	SELECT intItemId, intOwnershipType, dblQuantity, intItemUOMId
	FROM @ShipmentEntries
	-- Actual
	INSERT INTO actual_tblICInventoryShipmentItem(intItemId, intOwnershipType, dblQuantity, intItemUOMId)
	SELECT TOP 2 intItemId, intOwnershipType, dblQuantity, intItemUOMId
	FROM tblICInventoryShipmentItem
	ORDER BY intInventoryShipmentId DESC 

	EXEC tSQLt.AssertEqualsTable @Expected = 'expected_tblICInventoryShipmentItem',
		@Actual = 'actual_tblICInventoryShipmentItem'

	DECLARE @HeaderCount INT
	SELECT @HeaderCount = COUNT(*) FROM tblICInventoryShipment WHERE intInventoryShipmentId > 2355
	
	EXEC tSQLt.AssertEquals 1, @HeaderCount, 'Error. Multiple headers found.'

	IF OBJECT_ID('actual_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE actual_tblICInventoryShipmentItem

	IF OBJECT_ID('expected_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE expected_tblICInventoryShipmentItem
END
