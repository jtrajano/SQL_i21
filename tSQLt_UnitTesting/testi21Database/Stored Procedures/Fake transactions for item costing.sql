CREATE PROCEDURE [testi21Database].[Fake transactions for item costing]
AS
BEGIN	
	EXEC testi21Database.[Fake inventory items];

	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

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

	-- Declare the variables for the transaction types
	DECLARE @PurchaseType AS INT = 4
	DECLARE @SalesType AS INT = 5

	-- Fake data for tblICInventoryFIFO
	BEGIN
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@WetGrains, 1, 'January 1, 2014', 100, 0, 22.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@StickyGrains, 2, 'January 1, 2014', 150, 0, 33.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@PremiumGrains, 3, 'January 1, 2014', 200, 0, 44.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@ColdGrains, 4, 'January 1, 2014', 250, 0, 55.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intItemLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@HotGrains, 5, 'January 1, 2014', 300, 0, 66.00, 1)
	END 

	-- Fake data for item stock table
	BEGIN 
		-- Add stock information for items under location 1 ('Default')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, 1, 100, 22)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, 2, 150, 33)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, 3, 200, 44)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, 4, 250, 55)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, 5, 300, 66)

		-- Add stock information for items under location 2 ('NEW HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, 6, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, 7, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, 8, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, 9, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, 10, 0, 0)

		-- Add stock information for items under location 3 ('BETTER HAVEN')
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, 11, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, 12, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, 13, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, 14, 0, 0)
		INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, 15, 0, 0)
	END

	-- Fake data for tblICInventoryTransaction
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@WetGrains, 1, 'January 1, 2014', 100, 22.00, NULL, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@StickyGrains, 2, 'January 1, 2014', 150, 33.00, NULL, 0, 1, 1, 2, 'PURCHASE-200000', 'BATCH-200000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@PremiumGrains, 3, 'January 1, 2014', 200, 44.00, NULL, 0, 1, 1, 3, 'PURCHASE-300000', 'BATCH-300000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@ColdGrains, 4, 'January 1, 2014', 250, 55.00, NULL, 0, 1, 1, 4, 'PURCHASE-400000', 'BATCH-400000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intItemLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@HotGrains, 5, 'January 1, 2014', 300, 66.00, NULL, 0, 1, 1, 5, 'PURCHASE-500000', 'BATCH-500000', @PurchaseType, NULL, 1)
	END 
END 
