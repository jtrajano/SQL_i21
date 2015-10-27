﻿CREATE PROCEDURE testi21Database.[test fnGetItemCostingOnPostErrors if it blocks negative stock on non-lot and reserved qty.sql]
AS 
BEGIN
	-- Arrange
	BEGIN 
		-- Create the mock data 
		EXEC testi21Database.[Fake data for item stock table]

		-- Flag all items as phased out
		UPDATE dbo.tblICItem
		SET strStatus = 'Phased Out'

		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@ManualLotGrains AS INT = 6
				,@SerializedLotGrains AS INT = 7
				,@InvalidItem AS INT = -1

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

		-- SubLocation 
		DECLARE @WetGrains_DefaultLocation_SubLocation AS INT

		-- Storage Location 
		DECLARE @WetGrains_DefaultLocation_StorageLocation AS INT
				
		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,strText
				,intErrorCode
		)
		-- Negative stock is not allowed 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_DefaultLocation
				,strText = FORMATMESSAGE(80003, 'WET GRAINS')
				,intErrorCode = 80003	
				
		DECLARE @SubLocation AS INT 
		DECLARE @StorageLocation AS INT 
		DECLARE @LotId AS INT
		DECLARE @dblQty AS NUMERIC(18,6) = -100
	END

	-- Setup reservation data
	BEGIN 
		INSERT INTO dbo.tblICStockReservation (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[intLotId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[dblQty] 
				,[intTransactionId] 
				,[strTransactionId] 
				,[intSort] 
				,[intInventoryTransactionType] 
				,[intConcurrencyId] 
				,[ysnPosted] 
		)
		SELECT 
				[intItemId]						= @WetGrains
				,[intItemLocationId]			= @WetGrains_DefaultLocation
				,[intItemUOMId]					= @WetGrains_BushelUOMId
				,[intLotId]						= NULL 
				,[intSubLocationId]				= @SubLocation
				,[intStorageLocationId]			= @StorageLocation
				,[dblQty]						= 100
				,[intTransactionId]				= 1
				,[strTransactionId]				= 'DUMMY TRANSACTION'
				,[intSort]						= 1
				,[intInventoryTransactionType]	= 1
				,[intConcurrencyId]				= 1
				,[ysnPosted]					= 0
	END 

	-- Act
	BEGIN 
		INSERT INTO actual	
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @WetGrains_DefaultLocation, @WetGrains_BushelUOMId, @SubLocation, @StorageLocation, @dblQty, @LotId)
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected	
END