CREATE PROCEDURE [testi21Database].[test the uspICCreateStockReservation to insert non-lot items into tblICStockReservation]
AS
BEGIN
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@InvalidItem AS INT = -1

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5
			,@ManualLotGrains_BushelUOMId AS INT = 6
			,@SerializedLotGrains_BushelUOMId AS INT = 7

			,@WetGrains_PoundUOMId AS INT = 8
			,@StickyGrains_PoundUOMId AS INT = 9
			,@PremiumGrains_PoundUOMId AS INT = 10
			,@ColdGrains_PoundUOMId AS INT = 11
			,@HotGrains_PoundUOMId AS INT = 12
			,@ManualLotGrains_PoundUOMId AS INT = 13
			,@SerializedLotGrains_PoundUOMId AS INT = 14

	-- Declare Item-Locations
	DECLARE @WetGrains_DefaultLocation AS INT = 1
			,@StickyGrains_DefaultLocation AS INT = 2
			,@PremiumGrains_DefaultLocation AS INT = 3
			,@ColdGrains_DefaultLocation AS INT = 4
			,@HotGrains_DefaultLocation AS INT = 5

			,@WetGrains_NewHaven AS INT = 6
			,@StickyGrains_NewHaven AS INT = 7
			,@PremiumGrains_NewHaven AS INT = 8
			,@ColdGrains_NewHaven AS INT = 9
			,@HotGrains_NewHaven AS INT = 10

			,@WetGrains_BetterHaven AS INT = 11
			,@StickyGrains_BetterHaven AS INT = 12
			,@PremiumGrains_BetterHaven AS INT = 13
			,@ColdGrains_BetterHaven AS INT = 14
			,@HotGrains_BetterHaven AS INT = 15

			,@ManualLotGrains_DefaultLocation AS INT = 16
			,@SerializedLotGrains_DefaultLocation AS INT = 17

	-- ARRANGE 
	BEGIN 
		EXEC testi21Database.[Fake inventory items];

		EXEC tSQLt.FakeTable 'dbo.tblICStockReservation', @Identity = 1;
		
		-- Create the actual table
		CREATE TABLE actual (
			intItemId INT 
			,intItemLocationId INT 
			,intItemUOMId INT 
			,intLotId INT 
			,dblQuantity NUMERIC(18,6)
			,intTransactionId INT
			,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,intInventoryTransactionType INT
		)

		-- Create the expected table
		CREATE TABLE expected (
			intItemId INT 
			,intItemLocationId INT 
			,intItemUOMId INT 
			,intLotId INT 
			,dblQuantity NUMERIC(18,6)
			,intTransactionId INT
			,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,intInventoryTransactionType INT
		)

		DECLARE @ItemsToReserve AS dbo.ItemReservationTableType

		-- Setup the data to insert. 
		INSERT @ItemsToReserve (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,intLotId = NULL 
				,dblQty = 100
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-000001'
				,intTransactionTypeId = 1
		UNION ALL
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_PoundUOMId
				,intLotId = NULL 
				,dblQuantity = 100
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-000001'
				,intInventoryTransactionType = 1
		UNION ALL
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,intLotId = NULL 
				,dblQuantity = 15
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-000001'
				,intInventoryTransactionType = 1

		-- Setup the expected data
		INSERT INTO expected (
				intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,intLotId 
				,dblQuantity 
				,intTransactionId 
				,strTransactionId 
				,intInventoryTransactionType 
		)
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_BushelUOMId
				,intLotId = NULL 
				,dblQuantity = 115
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-000001'
				,intInventoryTransactionType = 1 
		UNION ALL 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,intItemUOMId = @WetGrains_PoundUOMId
				,intLotId = NULL 
				,dblQuantity = 100
				,intTransactionId = 1
				,strTransactionId = 'TRANSACTION-000001'
				,intInventoryTransactionType = 1 
	END 

	-- ACT
	BEGIN 
		EXEC dbo.uspICCreateStockReservation 
			@ItemsToReserve
	END 
			
	-- ASSERT
	BEGIN 
		-- Get the actual data
		INSERT INTO actual (
				intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,intLotId 
				,dblQuantity 
				,intTransactionId 
				,strTransactionId 
				,intInventoryTransactionType 		
		)
		SELECT	intItemId 
				,intItemLocationId 
				,intItemUOMId 
				,intLotId 
				,dblQuantity 
				,intTransactionId 
				,strTransactionId 
				,intInventoryTransactionType 
		FROM	dbo.tblICStockReservation

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 
	
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 