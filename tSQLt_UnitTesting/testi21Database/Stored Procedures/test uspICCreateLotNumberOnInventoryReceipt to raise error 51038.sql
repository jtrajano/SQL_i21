CREATE PROCEDURE [testi21Database].[test uspICCreateLotNumberOnInventoryReceipt to raise error 51038]
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

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				
		-- Declare the variables for the item location location
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
			intLotId INT NULL
			,intInventoryReceiptItemId INT NOT NULL
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		)

		CREATE TABLE actualReceiptItemLot(
			intLotId INT NULL
			,intInventoryReceiptItemId INT NOT NULL
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		)

	END 

	-- Assert
	BEGIN 
		-- The lot Quantity(ies) on %s must match its Open Receive Quantity.
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51038 
	END

	-- Act
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(20) = 'INVRCPT-XXXXX7'

		EXEC dbo.uspICCreateLotNumberOnInventoryReceipt
			@strTransactionId
			,1
			,1
	END 	

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END
