CREATE PROCEDURE [testi21Database].[test uspICCreateLotNumberOnInventoryReceipt for lot items]
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
			,strLotId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		)

		CREATE TABLE actualReceiptItemLot(
			intLotId INT NULL
			,intInventoryReceiptItemId INT NOT NULL
			,strLotId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		)

		-- Setup the expected data for Lot master table 
		INSERT INTO expectedICLot (
				intLotId
				,intItemLocationId
				,intItemUOMId
				,strLotNumber
		)
		SELECT	intLotId = 1
				,intItemLocationId  = @SerializedLotGrains_DefaultLocation
				,intItemUOMId = @SerializedLotGrains_BushelUOMId
				,strLotNumber = 'LOT-10000'
		UNION ALL 
		SELECT	intLotId = 2
				,intItemLocationId  = @SerializedLotGrains_DefaultLocation
				,intItemUOMId = @SerializedLotGrains_BushelUOMId
				,strLotNumber = 'LOT-10001'

		-- Setup expected data for Receipt Item Lot
		INSERT INTO expectedReceiptItemLot (
				intLotId
				,intInventoryReceiptItemId
				,strLotId
		)
		SELECT	intLotId = NULL 
				,intInventoryReceiptItemId = 13
				,strLotId = NULL 
		UNION ALL
		SELECT	intLotId = NULL 
				,intInventoryReceiptItemId = 13
				,strLotId = NULL 
		UNION ALL 
		SELECT	intLotId = 1
				,intInventoryReceiptItemId = 14
				,strLotId = 'LOT-10000'
		UNION ALL
		SELECT	intLotId = 2
				,intInventoryReceiptItemId = 14
				,strLotId = 'LOT-10001'
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51037 
	END

	-- Act
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(20) = 'INVRCPT-XXXXX3'

		EXEC dbo.uspICCreateLotNumberOnInventoryReceipt
			@strTransactionId
		
		-- Get the actual result from Lot master table
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

		-- Get the actual result from Receipt Item Lot table 
		INSERT INTO actualReceiptItemLot (
				intLotId
				,intInventoryReceiptItemId
				,strLotId
		)
		SELECT	ItemLots.intLotId
				,ItemLots.intInventoryReceiptItemId
				,ItemLots.strLotId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItems
					ON Receipt.intInventoryReceiptId = ReceiptItems.intInventoryReceiptId
				INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLots
					ON ReceiptItems.intInventoryReceiptItemId = ItemLots.intInventoryReceiptItemId
		WHERE	Receipt.strReceiptNumber = @strTransactionId
	END 	

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END
