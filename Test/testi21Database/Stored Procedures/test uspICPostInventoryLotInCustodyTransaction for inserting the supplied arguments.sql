CREATE PROCEDURE [testi21Database].[test uspICPostInventoryLotInCustodyTransaction for inserting the supplied arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items];
				
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustodyTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionType', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;			

		DECLARE 
			@intInventoryLotInCustodyTransactionId AS INT
			,@intItemId AS INT 
			,@intItemLocationId AS INT 
			,@intItemUOMId AS INT 
			,@intSubLocationId AS INT 
			,@intStorageLocationId AS INT 
			,@intLotId AS INT 
			,@dtmDate AS DATETIME 
			,@dblQty AS NUMERIC(18, 6) 
			,@dblUOMQty AS NUMERIC(18, 6) 
			,@dblCost AS NUMERIC(18, 6) 
			,@dblValue AS NUMERIC(18, 6) 
			,@dblSalesPrice AS NUMERIC(18, 6) 
			,@intCurrencyId AS INT 
			,@dblExchangeRate AS DECIMAL (38, 20) 
			,@intTransactionId AS INT 
			,@intTransactionDetailId AS INT 
			,@strTransactionId AS NVARCHAR(40) 
			,@strBatchId AS NVARCHAR(20) 
			,@intTransactionTypeId AS INT 
			,@strTransactionForm AS NVARCHAR (255) 
			,@intCreatedUserId AS INT
			,@intUserId AS INT 
			,@intInventoryLotInCustodyId AS INT
			,@InventoryLotInCustodyTransactionId AS INT
			
		SELECT 
			@intItemId = 1
			,@intItemLocationId = 2
			,@intItemUOMId = 3
			,@intSubLocationId = 4
			,@intStorageLocationId = 5
			,@intLotId = 6
			,@dtmDate = '01/01/2015'
			,@dblQty = 7
			,@dblUOMQty = 8
			,@dblCost = 9
			,@dblValue = 10
			,@dblSalesPrice = 11
			,@intCurrencyId = 12
			,@dblExchangeRate = 13
			,@intTransactionId = 14
			,@intTransactionDetailId = 13
			,@strTransactionId = '15'
			,@strBatchId = '16'
			,@intTransactionTypeId = 17
			,@strTransactionForm = '18'
			,@intInventoryLotInCustodyId = 19
			,@intUserId = 20

		CREATE TABLE expected (
			[intInventoryLotInCustodyTransactionId] INT 
			,[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[intSubLocationId] INT 
			,[intStorageLocationId] INT 
			,[intLotId] INT 
			,[dtmDate] DATETIME 
			,[dblQty] NUMERIC(18, 6) 
			,[dblUOMQty] NUMERIC(18, 6) 
			,[dblCost] NUMERIC(18, 6) 
			,[dblValue] NUMERIC(18, 6) 
			,[dblSalesPrice] NUMERIC(18, 6) 
			,[intCurrencyId] INT 
			,[dblExchangeRate] DECIMAL (38, 20) 
			,[intTransactionId] INT 
			,[intTransactionDetailId] INT 
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS 
			,[intInventoryLotInCustodyId] INT
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS 
			,[intTransactionTypeId] INT 
			,[ysnIsUnposted] BIT 
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS 
			,[dtmCreated] DATETIME 
			,[intCreatedUserId] INT 
			,[intConcurrencyId] INT 
		)

		CREATE TABLE actual (
			[intInventoryLotInCustodyTransactionId] INT 
			,[intItemId] INT 
			,[intItemLocationId] INT 
			,[intItemUOMId] INT 
			,[intSubLocationId] INT 
			,[intStorageLocationId] INT 
			,[intLotId] INT 
			,[dtmDate] DATETIME 
			,[dblQty] NUMERIC(18, 6) 
			,[dblUOMQty] NUMERIC(18, 6) 
			,[dblCost] NUMERIC(18, 6) 
			,[dblValue] NUMERIC(18, 6) 
			,[dblSalesPrice] NUMERIC(18, 6) 
			,[intCurrencyId] INT 
			,[dblExchangeRate] DECIMAL (38, 20) 
			,[intTransactionId] INT 
			,[intTransactionDetailId] INT 
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS 
			,[intInventoryLotInCustodyId] INT
			,[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS 
			,[intTransactionTypeId] INT 
			,[ysnIsUnposted] BIT 
			,[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS 
			,[dtmCreated] DATETIME 
			,[intCreatedUserId] INT 
			,[intConcurrencyId] INT
		)

		INSERT INTO expected (
			[intInventoryLotInCustodyTransactionId]
			,[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intLotId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId] 
			,[intInventoryLotInCustodyId]
			,[strTransactionId]
			,[strBatchId]
			,[intTransactionTypeId]
			,[ysnIsUnposted]
			,[strTransactionForm]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT			
			[intInventoryLotInCustodyTransactionId]	= 1
			,[intItemId]							= @intItemId
			,[intItemLocationId]					= @intItemLocationId
			,[intItemUOMId]							= @intItemUOMId
			,[intSubLocationId]						= @intSubLocationId
			,[intStorageLocationId]					= @intStorageLocationId
			,[intLotId]								= @intLotId
			,[dtmDate]								= @dtmDate
			,[dblQty]								= @dblQty
			,[dblUOMQty]							= @dblUOMQty
			,[dblCost]								= @dblCost
			,[dblValue]								= @dblValue
			,[dblSalesPrice]						= @dblSalesPrice
			,[intCurrencyId]						= @intCurrencyId
			,[dblExchangeRate]						= @dblExchangeRate
			,[intTransactionId]						= @intTransactionId
			,[intTransactionDetailId]				= @intTransactionDetailId
			,[intInventoryLotInCustodyId]			= @intInventoryLotInCustodyId
			,[strTransactionId]						= @strTransactionId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= @intTransactionTypeId
			,[ysnIsUnposted]						= 0
			,[strTransactionForm]					= @strTransactionForm
			,[dtmCreated]							= dbo.fnRemoveTimeOnDate(GETDATE())
			,[intCreatedUserId]						= @intUserId
			,[intConcurrencyId]						= 1

	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostInventoryLotInCustodyTransaction		
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblValue
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId 
			,@intTransactionTypeId 
			,@intLotId 
			,@strTransactionForm 
			,@intUserId 
			,@intInventoryLotInCustodyId 
			,@InventoryLotInCustodyTransactionId OUTPUT 
	END 

	-- Assert
	BEGIN
		INSERT INTO actual (
			[intInventoryLotInCustodyTransactionId]
			,[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intLotId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[intInventoryLotInCustodyId]
			,[strTransactionId]
			,[strBatchId]
			,[intTransactionTypeId]
			,[ysnIsUnposted]
			,[strTransactionForm]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]	
		)
		SELECT
			[intInventoryLotInCustodyTransactionId]
			,[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intLotId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[intInventoryLotInCustodyId]
			,[strTransactionId]
			,[strBatchId]
			,[intTransactionTypeId]
			,[ysnIsUnposted]
			,[strTransactionForm]
			,dbo.fnRemoveTimeOnDate([dtmCreated])
			,[intCreatedUserId]
			,[intConcurrencyId]
		FROM dbo.tblICInventoryLotInCustodyTransaction

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END