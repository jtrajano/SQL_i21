CREATE PROCEDURE [testi21Database].[Fake transactions for item costing]
AS
BEGIN	
	EXEC testi21Database.[Fake data for item costing];

	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFO', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryFIFOOut', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;

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
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 100, 0, 22.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@StickyGrains, @Default_Location, 'January 1, 2014', 150, 0, 33.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@PremiumGrains, @Default_Location, 'January 1, 2014', 200, 0, 44.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@ColdGrains, @Default_Location, 'January 1, 2014', 250, 0, 55.00, 1)
		INSERT INTO dbo.tblICInventoryFIFO (intItemId, intLocationId, dtmDate, dblStockIn, dblStockOut, dblCost, intConcurrencyId) VALUES (@HotGrains, @Default_Location, 'January 1, 2014', 300, 0, 66.00, 1)
	END 

	-- Fake data for tblICInventoryTransaction
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@WetGrains, @Default_Location, 'January 1, 2014', 100, 22.00, NULL, 0, 1, 1, 1, 'PURCHASE-100000', 'BATCH-100000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@StickyGrains, @Default_Location, 'January 1, 2014', 150, 33.00, NULL, 0, 1, 1, 2, 'PURCHASE-200000', 'BATCH-200000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@PremiumGrains, @Default_Location, 'January 1, 2014', 200, 44.00, NULL, 0, 1, 1, 3, 'PURCHASE-300000', 'BATCH-300000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@ColdGrains, @Default_Location, 'January 1, 2014', 250, 55.00, NULL, 0, 1, 1, 4, 'PURCHASE-400000', 'BATCH-400000', @PurchaseType, NULL, 1)
		INSERT INTO dbo.tblICInventoryTransaction (intItemId, intLocationId, dtmDate, dblUnitQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionId, strTransactionId, strBatchId, intTransactionTypeId, intLotId, intConcurrencyId) VALUES (@HotGrains, @Default_Location, 'January 1, 2014', 300, 66.00, NULL, 0, 1, 1, 5, 'PURCHASE-500000', 'BATCH-500000', @PurchaseType, NULL, 1)
	END 
END 
