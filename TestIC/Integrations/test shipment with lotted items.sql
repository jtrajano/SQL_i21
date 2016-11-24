﻿CREATE PROCEDURE testIC.[test shipment with lotted items]
AS
BEGIN
	-- Fake data
	BEGIN 
		EXEC [testIC].[Fake IC Starting Numbers]; 
	END 

	CREATE TABLE expected_tblICInventoryShipmentItem (
		intItemId INT
		, intOwnershipType INT
		, dblQuantity NUMERIC(38, 20)
		, intItemUOMId INT
	)
		
	CREATE TABLE actual_tblICInventoryShipmentItem (
		intItemId INT
		, intOwnershipType INT
		, dblQuantity NUMERIC(38, 20)
		, intItemUOMId INT
	)

	DECLARE 
		@ExpectedShipmentNumber VARCHAR(50) = 'T-INVSHP-1001',
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
		
	DECLARE 
		-- Test Details Values		
		@intItemId INT = 32,
		@intOwnerShipType INT = @OWNERSHIP_TYPE_Storage, 
		@dblQuantity INT = 1, @intItemUOMId INT = 7,
		-- Test Header Values
		@intOrderType INT = @ORDER_TYPE_SalesOrder, -- Sales Order
		@intSourceType INT = @SOURCE_TYPE_None, -- No Source
		@intEntityCustomerId INT = 8, -- Apple Spice Sales
		@dtmShipDate DATETIME = GETDATE(), -- Today
		@intShipFromLocationId INT = 2, -- Fort Wayne
		@intShipToLocationId INT = 638, -- Apple Spice
		@intFreightTermId INT = 3 -- Pickup

	-- Insert Items
	INSERT INTO @ShipmentEntries(
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, strBOLNumber
		, strSourceScreenName
		, intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
		, intItemLotGroup
		, intOrderId
		, intSourceId
		, intLineNo
		, dblUnitPrice
		, intWeightUOMId
	)
	SELECT
		intOrderType = @intOrderType,
		intSourceType = @intSourceType,
		intEntityCustomerId = @intEntityCustomerId,
		dtmShipDate = @dtmShipDate,
		intShipFromLocationId = @intShipFromLocationId,
		intShipToLocationId = @intShipToLocationId,
		intFreightTermId = @intFreightTermId,
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

	-- Insert Lots
	INSERT INTO @ShipmentItemLots(
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intItemLotGroup
		, intLotId
		, dblQuantityShipped
		, dblGrossWeight
		, dblTareWeight
		, dblWeightPerQty
		, strWarehouseCargoNumber
	)
	SELECT 
		@intOrderType
		, @intSourceType
		, @intEntityCustomerId
		, @dtmShipDate
		, @intShipFromLocationId
		, @intShipToLocationId
		, @intFreightTermId
		, intItemLotGroup = 1
		, intLotId = 1221 -- LOT-45
		, dblQuantityShipped = 32.1
		, dblGrossWeight = 52.1
		, dblTareWeight = 11.2
		, dblWeightPerQty = 6.2
		, strWareHouseCargoNumber = 'CN-0001'
	UNION ALL
	SELECT 
		@intOrderType
		, @intSourceType
		, @intEntityCustomerId
		, @dtmShipDate
		, @intShipFromLocationId
		, @intShipToLocationId
		, @intFreightTermId
		, intItemLotGroup = 1
		, intLotId = 1221 -- LOT-45
		, dblQuantityShipped = 32.1
		, dblGrossWeight = 1052.1
		, dblTareWeight = 111.2
		, dblWeightPerQty = 62.2
		, strWareHouseCargoNumber = 'CwN-0001'
		 
	EXEC dbo.uspICAddItemShipment @ShipmentEntries, @ShipmentCharges, @ShipmentItemLots, @intUserId

	SELECT TOP 1 
			@ActualShipmentNumber = strShipmentNumber
	FROM	tblICInventoryShipment
	ORDER BY intInventoryShipmentId DESC

	EXEC tSQLt.AssertEqualsString @ExpectedShipmentNumber, @ActualShipmentNumber, N'Error creating shipment.'
	
	-- Expected
	INSERT INTO expected_tblICInventoryShipmentItem(
		intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
	)
	SELECT 
		intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
	FROM @ShipmentEntries

	-- Actual
	INSERT INTO actual_tblICInventoryShipmentItem(
		intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
	)
	SELECT TOP 1 
		intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
	FROM tblICInventoryShipmentItem
	ORDER BY intInventoryShipmentId DESC 

	EXEC tSQLt.AssertEqualsTable 
		@Expected = 'expected_tblICInventoryShipmentItem',
		@Actual = 'actual_tblICInventoryShipmentItem'

	DECLARE @HeaderCount INT
	SELECT @HeaderCount = COUNT(*) FROM tblICInventoryShipment WHERE strShipmentNumber = @ActualShipmentNumber

	EXEC tSQLt.AssertEquals 1, @HeaderCount, 'Error. Multiple headers found.'

	DECLARE @LotCount INT
	
	SELECT	@LotCount = COUNT(*)
	FROM	tblICInventoryShipmentItem i INNER JOIN tblICInventoryShipmentItemLot l 
				ON l.intInventoryShipmentItemId = i.intInventoryShipmentItemId
			INNER JOIN tblICInventoryShipment s 
				ON s.intInventoryShipmentId = i.intInventoryShipmentId
	WHERE	s.strShipmentNumber = @ActualShipmentNumber

	DECLARE @ItemCount INT
	SELECT	@ItemCount = COUNT(*)
	FROM	tblICInventoryShipmentItem i INNER JOIN tblICInventoryShipment s 
				ON s.intInventoryShipmentId = i.intInventoryShipmentId
	WHERE	s.strShipmentNumber = @ActualShipmentNumber

	EXEC tSQLt.AssertNotEquals 0, @LotCount, 'No item lots inserted.'

	--PRINT 'There are: ' + CAST(@HeaderCount AS VARCHAR(50)) + ' headers(s).'
	--PRINT 'There are: ' + CAST(@ItemCount AS VARCHAR(50)) + ' items(s).'
	--PRINT 'There are: ' + CAST(@LotCount AS VARCHAR(50)) + ' lot(s).'

	IF OBJECT_ID('actual_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE actual_tblICInventoryShipmentItem

	IF OBJECT_ID('expected_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE expected_tblICInventoryShipmentItem
END
