CREATE PROCEDURE [testi21Database].[Fake data for inventory transaction table]
AS
BEGIN
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction';

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
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

		-- Declare the variables for the transaction 
		DECLARE @intTransactionId AS INT = 1;
		DECLARE @strTransactionId AS NVARCHAR(40) = 'TRANSACTIONID-XXX1';
		DECLARE @strBatchId AS NVARCHAR(40) = 'BATCH-YYYY1';
		DECLARE @BaseCurrencyId AS INT = 1;
		DECLARE @dblExchangeRate AS NUMERIC(18,6) = 1;
		DECLARE @dtmDate AS DATETIME = '10/10/2014';
		DECLARE @intTransactionTypeId AS INT = 10;
		
		-- Add 3 items (Wet, Sticky, and Premium Grains) for the 1st transaction. 
		INSERT INTO tblICInventoryTransaction (intTransactionId, strTransactionId, strBatchId, dtmDate, intItemId, intItemLocationId, dblQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionTypeId)
		SELECT	intTransactionId = @intTransactionId
				, strTransactionId = @strTransactionId
				, strBatchId = @strBatchId
				, dtmDate = @dtmDate
				, intItemId = @WetGrains
				, intItemLocationId = @NewHaven
				, dblQty = 1
				, dblCost = 100
				, dblValue = 0
				, dblSalesPrice = 2000
				, intCurrencyId = @BaseCurrencyId
				, dblExchangeRate = @dblExchangeRate
				, intTransactionTypeId = @intTransactionTypeId
		UNION ALL 
		SELECT	intTransactionId = @intTransactionId
				, strTransactionId = @strTransactionId
				, strBatchId = @strBatchId
				, dtmDate = @dtmDate
				, intItemId = @StickyGrains
				, intItemLocationId = @NewHaven
				, dblQty = 2
				, dblCost = 100
				, dblValue = 0
				, dblSalesPrice = 2000
				, intCurrencyId = @BaseCurrencyId
				, dblExchangeRate = @dblExchangeRate
				, intTransactionTypeId = @intTransactionTypeId
		UNION ALL 
		SELECT	intTransactionId = @intTransactionId
				, strTransactionId = @strTransactionId
				, strBatchId = @strBatchId
				, dtmDate = @dtmDate
				, intItemId = @PremiumGrains
				, intItemLocationId = @NewHaven
				, dblQty = 2
				, dblCost = 100
				, dblValue = 0
				, dblSalesPrice = 2000
				, intCurrencyId = @BaseCurrencyId
				, dblExchangeRate = @dblExchangeRate
				, intTransactionTypeId = @intTransactionTypeId

		-- Add 2 items (Cold and Hot grains) for the 2nd transaction. 
		SET @intTransactionId = 2;
		SET @strTransactionId = 'TRANSACTIONID-XXX2';
		SET @strBatchId = 'BATCH-YYYY2';
		SET @BaseCurrencyId = 1;
		SET @dblExchangeRate = 1;
		SET @dtmDate = '10/11/2014';
		SET @intTransactionTypeId = 11;

		INSERT INTO tblICInventoryTransaction (intTransactionId, strTransactionId, strBatchId, dtmDate, intItemId, intItemLocationId, dblQty, dblCost, dblValue, dblSalesPrice, intCurrencyId, dblExchangeRate, intTransactionTypeId)
		SELECT	intTransactionId = @intTransactionId
				, strTransactionId = @strTransactionId
				, strBatchId = @strBatchId
				, dtmDate = @dtmDate
				, intItemId = @ColdGrains
				, intItemLocationId = @BetterHaven
				, dblQty = 1
				, dblCost = 100
				, dblValue = 0
				, dblSalesPrice = 2000
				, intCurrencyId = @BaseCurrencyId
				, dblExchangeRate = @dblExchangeRate
				, intTransactionTypeId = @intTransactionTypeId
		UNION ALL 
		SELECT	intTransactionId = @intTransactionId
				, strTransactionId = @strTransactionId
				, strBatchId = @strBatchId
				, dtmDate = @dtmDate
				, intItemId = @HotGrains
				, intItemLocationId = @BetterHaven
				, dblQty = 2
				, dblCost = 15.11
				, dblValue = 0
				, dblSalesPrice = 781.20
				, intCurrencyId = @BaseCurrencyId
				, dblExchangeRate = @dblExchangeRate
				, intTransactionTypeId = @intTransactionTypeId
END 
