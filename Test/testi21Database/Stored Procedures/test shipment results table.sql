﻿CREATE PROCEDURE testi21Database.[test shipment results table]
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemShipmentResult (
			intInventoryShipmentId INT
		)
	END

	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;	

	DECLARE 
		@ExpectedShipmentNumber VARCHAR(50) = 'IS-75',
		@ActualShipmentNumber VARCHAR(50),
		@intUserId INT = 1,
		@ShipmentEntries ShipmentStagingTable,
		@ShipmentCharges ShipmentChargeStagingTable,
		@ShipmentItemLots ShipmentItemLotStagingTable,
		@ShipmentItemLotsOnlyStagingTable ShipmentItemLotsOnlyStagingTable,
		
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

	-- Setup the next starting number for the shipment 
	UPDATE	s
	SET		intNumber = 75
	FROM	tblSMStartingNumber s
	where	strTransactionType = 'Inventory Shipment'
	
	EXEC dbo.uspICAddItemShipment @ShipmentEntries, @ShipmentCharges, @ShipmentItemLots, @ShipmentItemLotsOnlyStagingTable, @intUserId

	IF NOT EXISTS(SELECT * FROM #tmpAddItemShipmentResult)
	BEGIN
		EXEC tSQLt.Fail 'No results returned by the temp table #tblAddItemShipment'
	END

	SELECT TOP 1 @ActualShipmentNumber = strShipmentNumber
	FROM tblICInventoryShipment
	ORDER BY intInventoryShipmentId DESC

	EXEC tSQLt.AssertEqualsString @ExpectedShipmentNumber, @ActualShipmentNumber, N'Error creating shipment.'
END
