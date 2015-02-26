CREATE PROCEDURE [testi21Database].[test uspICValidateStockReserves for the high stocks and lot item]
AS
BEGIN
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

	DECLARE @InventoryReceipt AS INT = 4
			,@InventoryShipment AS INT = 5
			,@PurchaseOrder AS INT = 6
			,@SalesOrder AS INT = 7

	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items]

		DECLARE @ItemsToValidate AS ItemReservationTableType
		DECLARE @strItemNo AS NVARCHAR(50) 
		DECLARE @intItemId AS INT 

		-- Mark all items as "Do not allow negative"
		DECLARE @AllowNegativeInventory_NoOption AS INT = 3
		UPDATE	dbo.tblICItemLocation
		SET		intAllowNegativeInventory = @AllowNegativeInventory_NoOption

		INSERT INTO @ItemsToValidate (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intTransactionId
				,strTransactionId
				,intTransactionTypeId
		)
		-- Manual grains has high stocks. 
		SELECT 	intItemId = @ManualLotGrains
				,intItemLocationId = @ManualLotGrains_DefaultLocation
				,intItemUOMId = @ManualLotGrains_BushelUOMId
				,intLotId = 1
				,dblQty = 100 
				,intTransactionId = 1 
				,strTransactionId = 'test transaction'
				,intTransactionTypeId = @InventoryReceipt
		UNION ALL 
		SELECT 	intItemId = @ManualLotGrains
				,intItemLocationId = @ManualLotGrains_DefaultLocation
				,intItemUOMId = @ManualLotGrains_BushelUOMId
				,intLotId = 1
				,dblQty = 20
				,intTransactionId = 2				
				,strTransactionId = 'test transaction'
				,intTransactionTypeId = @InventoryReceipt

		-- Serial grains has just enough stocks 
		UNION ALL
		SELECT 	intItemId = @SerializedLotGrains
				,intItemLocationId = @SerializedLotGrains_DefaultLocation
				,intItemUOMId = @SerializedLotGrains_BushelUOMId
				,intLotId = 2
				,dblQty = 100
				,intTransactionId = 3 
				,strTransactionId = 'test transaction'
				,intTransactionTypeId = @InventoryReceipt
		UNION ALL 
		SELECT 	intItemId = @SerializedLotGrains
				,intItemLocationId = @SerializedLotGrains_DefaultLocation
				,intItemUOMId = @SerializedLotGrains_BushelUOMId
				,intLotId = 2
				,dblQty = 8
				,intTransactionId = 4
				,strTransactionId = 'test transaction'
				,intTransactionTypeId = @InventoryReceipt

		-- Add Fake Stock UOM
		-- Since the items are lot, ignore the stock qty at stock uom. 	
		INSERT INTO dbo.tblICItemStockUOM (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dblOnHand
		)
		SELECT	intItemId = @ManualLotGrains
				,intItemLocationId = @ManualLotGrains_DefaultLocation
				,intItemUOMId = @ManualLotGrains_BushelUOMId
				,dblOnHand = 0
		UNION ALL 
		SELECT	intItemId = @SerializedLotGrains
				,intItemLocationId = @SerializedLotGrains_DefaultLocation
				,intItemUOMId = @SerializedLotGrains_BushelUOMId
				,dblOnHand = 0

		-- Add Fake stock quantities on Lot master table. 
		EXEC tSQLt.FakeTable 'dbo.tblICLot';	
		INSERT INTO dbo.tblICLot (
				intItemLocationId
				,intItemUOMId
				,intLotId
				,dblOnHand
		)
		SELECT	intItemLocationId = @ManualLotGrains_DefaultLocation
				,intItemUOMId = @ManualLotGrains_BushelUOMId
				,intLotId = 1
				,dblOnHand = 500
		UNION ALL 
		SELECT	intItemLocationId = @SerializedLotGrains_DefaultLocation
				,intItemUOMId = @SerializedLotGrains_BushelUOMId
				,intLotId = 2
				,dblOnHand = 108
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICValidateStockReserves
			@ItemsToValidate
			,@strItemNo OUTPUT 
			,@intItemId OUTPUT 
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals NULL, @intItemId;
	END
END 
