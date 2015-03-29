CREATE PROCEDURE [testi21Database].[Fake transactions for item costing]
AS
BEGIN	
	EXEC testi21Database.[Fake inventory items];

	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemStockUOM', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemPricing', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICItemUOM', @Identity = 1;	

	-- Re-create the index
	CREATE CLUSTERED INDEX [IDX_tblICInventoryFIFO]
		ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryFIFOId] ASC);

	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5

	-- Declare the variables for the transaction types
	DECLARE @PurchaseType AS INT = 4
	DECLARE @SalesType AS INT = 5

	-- Fake data for tblICInventoryFIFO
	BEGIN
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@WetGrains, 1, @WetGrains_BushelUOMId, 'January 1, 2014', 100, 0, 22.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@StickyGrains, 2, @StickyGrains_BushelUOMId, 'January 1, 2014', 150, 0, 33.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@PremiumGrains, 3, @PremiumGrains_BushelUOMId, 'January 1, 2014', 200, 0, 44.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@ColdGrains, 4, @ColdGrains_BushelUOMId, 'January 1, 2014', 250, 0, 55.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@HotGrains, 5, @HotGrains_BushelUOMId, 'January 1, 2014', 300, 0, 66.00, 1)
	END 

	-- Fake data for item stock table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, 1, 100)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, 2, 150)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, 3, 200)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, 4, 250)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, 5, 300)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, 6, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, 7, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, 8, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, 9, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, 10, 0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, 11, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, 12, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, 13, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, 14, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, 15, 0)
	END

	-- Fake data for item stock UOM table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains,		1, @WetGrains_BushelUOMId,		100)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains,	2, @StickyGrains_BushelUOMId,	150)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains,	3, @PremiumGrains_BushelUOMId,	200)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains,		4, @ColdGrains_BushelUOMId,		250)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains,		5, @HotGrains_BushelUOMId,		300)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains,		6,	@WetGrains_BushelUOMId,			0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains,	7,	@StickyGrains_BushelUOMId,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains,	8,	@PremiumGrains_BushelUOMId,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains,		9,	@ColdGrains_BushelUOMId,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains,		10,	@HotGrains_BushelUOMId,			0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@WetGrains,		11,	@WetGrains_BushelUOMId,			0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@StickyGrains,	12,	@StickyGrains_BushelUOMId,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@PremiumGrains,	13,	@PremiumGrains_BushelUOMId,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@ColdGrains,		14,	@ColdGrains_BushelUOMId,		0)
		INSERT INTO dbo.tblICItemStockUOM (intItemId, intItemLocationId, intItemUOMId, dblOnHand) VALUES (@HotGrains,		15,	@HotGrains_BushelUOMId,			0)
	END

	-- Fake data for item pricing table
	BEGIN 
		-- Add pricing information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, 1, 22)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, 2, 33)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, 3, 44)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, 4, 55)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, 5, 66)

		-- Add pricing information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, 6, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, 7, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, 8, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, 9, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, 10, 0)

		-- Add pricing information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@WetGrains, 11, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@StickyGrains, 12, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@PremiumGrains, 13, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@ColdGrains, 14, 0)
		INSERT INTO dbo.tblICItemPricing (intItemId, intItemLocationId, dblAverageCost) VALUES (@HotGrains, 15, 0)
	END

	-- Fake data for tblICInventoryTransaction
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@WetGrains, 1, @WetGrains_BushelUOMId, 'January 1, 2014', 100, 1, 22.00, 0, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@StickyGrains, 2, @StickyGrains_BushelUOMId, 'January 1, 2014', 150, 1, 33.00, 0, 0, 1, 1, 2, 'PURCHASE-200000', 'BATCH-200000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@PremiumGrains, 3, @PremiumGrains_BushelUOMId, 'January 1, 2014', 200, 1, 44.00, 0, 0, 1, 1, 3, 'PURCHASE-300000', 'BATCH-300000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@ColdGrains, 4, @ColdGrains_BushelUOMId, 'January 1, 2014', 250, 1, 55.00, 0, 0, 1, 1, 4, 'PURCHASE-400000', 'BATCH-400000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, intItemUOMId, dtmDate, dblQty, dblUOMQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@HotGrains, 5, @HotGrains_BushelUOMId, 'January 1, 2014', 300, 1, 66.00, 0, 0, 1, 1, 5, 'PURCHASE-500000', 'BATCH-500000', @PurchaseType, NULL, 1)
	END 

	-- Create the fake table and data for the unit of measure
	BEGIN 
		DECLARE @UOMBushel AS INT = 1
		DECLARE @UOMPound AS INT = 2

		-- Unit of measure master table
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure) VALUES (@UOMBushel, 'Bushel')
		INSERT INTO dbo.tblICUnitMeasure (intUnitMeasureId, strUnitMeasure) VALUES (@UOMPound, 'Pound')
		
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@WetGrains, @UOMBushel, 1) -- 1
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@StickyGrains, @UOMBushel, 1) -- 2
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@PremiumGrains, @UOMBushel, 1) -- 3
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@ColdGrains, @UOMBushel, 1) -- 4
		INSERT INTO dbo.tblICItemUOM (intItemId, intUnitMeasureId, dblUnitQty) VALUES (@HotGrains, @UOMBushel, 1) -- 5
	END 
END 
