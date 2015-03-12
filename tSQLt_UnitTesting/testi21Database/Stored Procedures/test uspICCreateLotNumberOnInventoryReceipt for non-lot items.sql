CREATE PROCEDURE [testi21Database].[test uspICCreateLotNumberOnInventoryReceipt for non-lot items]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for inventory receipt table]

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

		CREATE TABLE expectedICLot(
			intLotId INT NOT NULL
			,intItemLocationId INT NOT NULL
			,intItemUOMId INT NULL
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		)

		CREATE TABLE actualICLot(
			intLotId INT NOT NULL
			,intItemLocationId INT NOT NULL
			,intItemUOMId INT NULL
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		)

		CREATE TABLE expectedReceiptItemLot(
			intLotId INT NOT NULL
			,intInventoryReceiptItemId INT NOT NULL
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		)

		CREATE TABLE actualReceiptItemLot(
			intLotId INT NOT NULL
			,intInventoryReceiptItemId INT NOT NULL
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		)
	END 
	
	-- Act
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(20) = 'INVRCPT-XXXXX2'

		EXEC dbo.uspICCreateLotNumberOnInventoryReceipt
			@strTransactionId
			,1
			,1

		-- Get result and store it in the actual tables
		INSERT INTO actualICLot (
				intLotId
				,intItemLocationId
				,intItemUOMId
				,strLotNumber
		)
		SELECT	intLotId
				,intItemLocationId
				,intItemUOMId 
				,strLotNumber
		FROM	dbo.tblICLot

		INSERT INTO actualReceiptItemLot (
				intLotId
				,intInventoryReceiptItemId
				,strLotNumber
		)
		SELECT	intLotId
				,intInventoryReceiptItemId
				,strLotNumber
		FROM	dbo.actualReceiptItemLot
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expectedICLot', 'actualICLot';
		EXEC tSQLt.AssertEqualsTable 'expectedReceiptItemLot', 'actualReceiptItemLot';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END