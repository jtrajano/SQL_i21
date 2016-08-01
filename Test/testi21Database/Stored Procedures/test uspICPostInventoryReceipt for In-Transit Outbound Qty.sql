CREATE PROCEDURE [testi21Database].[test uspICPostInventoryReceipt for In-Transit Outbound Qty]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items];
		EXEC testi21Database.[Fake open fiscal year and accounting periods];

		-- Declare the variables for grains (item)
		DECLARE @ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1

		-- Declare the variables for the Item UOM Ids
		DECLARE @ManualLotGrains_BushelUOMId AS INT = 6
				,@SerializedLotGrains_BushelUOMId AS INT = 7

				,@ManualLotGrains_PoundUOMId AS INT = 13
				,@SerializedLotGrains_PoundUOMId AS INT = 14

		-- Declare Item-Locations
		DECLARE @ManualLotGrains_DefaultLocation AS INT = 16
				,@SerializedLotGrains_DefaultLocation AS INT = 17

				-- Source Types
				,@SOURCE_TYPE_NONE AS INT = 0
				,@SOURCE_TYPE_SCALE AS INT = 1
				,@SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
				,@SOURCE_TYPE_TRANSPORT AS INT = 3

		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'Dummy-000001'
		DECLARE @intEntityId AS INT = 1
		DECLARE @dtmDate AS DATETIME = GETDATE()

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceipt', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItem', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemLot', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptItemTax', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryReceiptCharge', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblGLDetailRecap', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary', @Identity = 1;	
		EXEC tSQLt.FakeTable 'dbo.tblAPBill', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblAPBillDetail', @Identity = 1;

		INSERT INTO tblICInventoryReceipt (
			strReceiptNumber
			,intLocationId
			,dtmReceiptDate
			,strReceiptType
			,intSourceType
			,intTransferorId
		)
		VALUES (
			@strTransactionId
			,@Default_Location
			,@dtmDate	
			,'Transfer Order'
			,@SOURCE_TYPE_NONE
			,@Default_Location
		);	
	
		INSERT INTO tblICInventoryReceiptItem(intInventoryReceiptId, intItemId, dblOrderQty, dblOpenReceive, dblUnitCost, intUnitMeasureId, intOwnershipType) VALUES (1, @ManualLotGrains,		10,	10,	12.50, @ManualLotGrains_BushelUOMId, 1);

		-- @ManualLotGrains: 1
		INSERT INTO tblICInventoryReceiptItemLot(intInventoryReceiptItemId, intItemUnitMeasureId, intLotId, strLotNumber, dblQuantity) VALUES (1, @ManualLotGrains_BushelUOMId, 1, 'ManualLot-0001', 3)
		INSERT INTO tblICInventoryReceiptItemLot(intInventoryReceiptItemId, intItemUnitMeasureId, intLotId, strLotNumber, dblQuantity) VALUES (1, @ManualLotGrains_BushelUOMId, 1, 'ManualLot-0002', 7)

		-- Fake data for the lot numbers
		INSERT INTO tblICLot (intItemLocationId, intItemUOMId, strLotNumber) VALUES (@ManualLotGrains_DefaultLocation, @ManualLotGrains_BushelUOMId, 'ManualLot-0001')
		INSERT INTO tblICLot (intItemLocationId, intItemUOMId, strLotNumber) VALUES (@ManualLotGrains_DefaultLocation, @ManualLotGrains_BushelUOMId, 'ManualLot-0002')
		
		CREATE TABLE actual_tblICItemStock (
			intItemId INT
			,intItemLocationId INT 
			,dblInTransitOutbound NUMERIC(38, 20)
		)

		CREATE TABLE actual_tblICItemStockUOM (
			intItemId INT
			,intItemLocationId INT 
			,intItemUOMId INT 
			,dblInTransitOutbound NUMERIC(38, 20)
		)
		
		CREATE TABLE expected_tblICItemStock (
			intItemId INT
			,intItemLocationId INT 
			,dblInTransitOutbound NUMERIC(38, 20)
		)

		CREATE TABLE expected_tblICItemStockUOM (
			intItemId INT
			,intItemLocationId INT 
			,intItemUOMId INT 
			,dblInTransitOutbound NUMERIC(38, 20)
		)

		-- Expected tblICItemStock
		INSERT INTO expected_tblICItemStock VALUES (@ManualLotGrains, @ManualLotGrains_DefaultLocation, -10)
		INSERT INTO expected_tblICItemStockUOM VALUES (@ManualLotGrains, @ManualLotGrains_DefaultLocation, @ManualLotGrains_BushelUOMId, -10)
		INSERT INTO expected_tblICItemStockUOM VALUES (@ManualLotGrains, @ManualLotGrains_DefaultLocation, @ManualLotGrains_PoundUOMId, -10)

	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryReceipt
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intEntityId
			
		INSERT INTO actual_tblICItemStock (intItemId, intItemLocationId, dblInTransitOutbound) 
		SELECT	intItemId, intItemLocationId, SUM(dblInTransitOutbound)
		FROM	dbo.tblICItemStock
		GROUP BY intItemId, intItemLocationId

		INSERT INTO actual_tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblInTransitOutbound) 
		SELECT intItemId, intItemLocationId, intItemUOMId, SUM(ISNULL(dblInTransitOutbound , 0)) 
		FROM dbo.tblICItemStockUOM
		GROUP BY intItemId, intItemLocationId, intItemUOMId
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected_tblICItemStock', 'actual_tblICItemStock', 'Failed on tblICItemStock';
		EXEC tSQLt.AssertEqualsTable 'expected_tblICItemStockUOM', 'actual_tblICItemStockUOM', 'Failed on tblICItemStockUOM';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual_tblICItemStock') IS NOT NULL 
		DROP TABLE actual_tblICItemStock

	IF OBJECT_ID('actual_tblICItemStockUOM') IS NOT NULL 
		DROP TABLE actual_tblICItemStockUOM

	IF OBJECT_ID('expected_tblICItemStock') IS NOT NULL 
		DROP TABLE expected_tblICItemStock

	IF OBJECT_ID('expected_tblICItemStockUOM') IS NOT NULL 
		DROP TABLE expected_tblICItemStockUOM
END