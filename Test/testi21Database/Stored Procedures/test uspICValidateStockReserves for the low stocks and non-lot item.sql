CREATE PROCEDURE [testi21Database].[test uspICValidateStockReserves for the low stocks and non-lot item]
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

		-- Mark all items as "Do not allow negative"
		DECLARE @AllowNegativeInventory_NoOption AS INT = 3
		UPDATE	dbo.tblICItemLocation
		SET		intAllowNegativeInventory = @AllowNegativeInventory_NoOption

		DECLARE @ItemsToValidate AS ItemReservationTableType
		DECLARE @strItemNo AS NVARCHAR(50) 
		DECLARE @intItemId AS INT 

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
		-- Wet grains does not have any stock uom records
		-- Note: Use the Better haven location because it does not allow negative stocks.
		SELECT 	intItemId = @WetGrains
				,intItemLocationId = @WetGrains_BetterHaven
				,intItemUOMId = @WetGrains_BushelUOMId
				,intLotId = NULL 
				,dblQty = 100 
				,intTransactionId = 1 
				,strTransactionId = 'test transaction'
				,intTransactionTypeId = @InventoryReceipt
		-- Sticky grains has a record in the stock uom but it is not enough 
		UNION ALL 
		SELECT 	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,intItemUOMId = @StickyGrains_BushelUOMId
				,intLotId = NULL 
				,dblQty = 12
				,intTransactionId = 2				
				,strTransactionId = 'test transaction'
				,intTransactionTypeId = @InventoryReceipt

		-- Add Fake Stock UOM
		INSERT INTO dbo.tblICItemStockUOM (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dblOnHand
		)
		SELECT	intItemId = @StickyGrains
				,intItemLocationId = @StickyGrains_BetterHaven
				,intItemUOMId = @StickyGrains_BushelUOMId
				,dblOnHand = 0
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
		EXEC tSQLt.AssertEquals @WetGrains, @intItemId;
	END
END 
