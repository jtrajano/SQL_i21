CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransactionStorage for inserting the supplied arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionType', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;			

		DECLARE 
				@intItemId INT								= 1
				,@intItemLocationId INT						= 2
				,@intItemUOMId INT							= 3
				,@intSubLocationId INT						= 4
				,@intStorageLocationId INT					= 5
				,@dtmDate DATETIME							= '01/06/2015'
				,@dblQty NUMERIC(38,20)						= 7
				,@dblUOMQty NUMERIC(38,20)					= 8
				,@dblCost NUMERIC(38,20)					= 9
				,@dblValue NUMERIC(38,20)					= 10
				,@dblSalesPrice NUMERIC(18, 6)				= 11
				,@intCurrencyId INT							= 12
				,@dblExchangeRate NUMERIC (38,20)			= 13
				,@intTransactionId INT						= 14
				,@intTransactionDetailId INT				= 15
				,@strTransactionId NVARCHAR(40)				= '16'
				,@strBatchId NVARCHAR(20)					= '17'
				,@intTransactionTypeId INT					= 18
				,@intLotId INT								= 19
				,@intRelatedInventoryTransactionId INT		= 20
				,@intRelatedTransactionId INT				= 21
				,@strRelatedTransactionId NVARCHAR(40)		= '22'
				,@strTransactionForm NVARCHAR (255)			= '23'
				,@intEntityUserSecurityId INT				= 24
				,@intCostingMethod INT						= 25
				,@InventoryTransactionIdentityId INT		= 26

		CREATE TABLE expected (
			[intInventoryTransactionStorageId] INT, 
			[intItemId] INT,
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[intLotId] INT, 
			[dtmDate] DATETIME,	
			[dblQty] NUMERIC(38, 20), 
			[dblUOMQty] NUMERIC(38, 20), 		
			[dblCost] NUMERIC(38, 20), 
			[dblValue] NUMERIC(38, 20), 
			[dblSalesPrice] NUMERIC(18, 6), 
			[intCurrencyId] INT,
			[dblExchangeRate] DECIMAL (38, 20),
			[intTransactionId] INT, 
			[intTransactionDetailId] INT, 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intInventoryCostBucketStorageId] INT, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS, 
			[intTransactionTypeId] INT, 		
			[ysnIsUnposted] BIT,
			[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS,
			[intRelatedInventoryTransactionId] INT, 
			[intRelatedTransactionId] INT, 
			[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intCostingMethod] INT, 
			[dtmCreated] DATETIME, 
			[intCreatedUserId] INT,
			[intCreatedEntityId] INT,		
			[intConcurrencyId] INT, 
		)

		CREATE TABLE actual (
			[intInventoryTransactionStorageId] INT, 
			[intItemId] INT,
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[intLotId] INT, 
			[dtmDate] DATETIME,	
			[dblQty] NUMERIC(38, 20), 
			[dblUOMQty] NUMERIC(38, 20), 		
			[dblCost] NUMERIC(38, 20), 
			[dblValue] NUMERIC(38, 20), 
			[dblSalesPrice] NUMERIC(18, 6), 
			[intCurrencyId] INT,
			[dblExchangeRate] DECIMAL (38, 20),
			[intTransactionId] INT, 
			[intTransactionDetailId] INT, 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intInventoryCostBucketStorageId] INT, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS, 
			[intTransactionTypeId] INT, 		
			[ysnIsUnposted] BIT,
			[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS,
			[intRelatedInventoryTransactionId] INT, 
			[intRelatedTransactionId] INT, 
			[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intCostingMethod] INT, 
			[dtmCreated] DATETIME, 
			[intCreatedUserId] INT,
			[intCreatedEntityId] INT,		
			[intConcurrencyId] INT, 
		)

		INSERT INTO expected (
			[intItemId]
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
			,[strTransactionId] 
			,[intInventoryCostBucketStorageId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[ysnIsUnposted] 
			,[strTransactionForm] 
			,[intRelatedInventoryTransactionId] 
			,[intRelatedTransactionId] 
			,[strRelatedTransactionId] 
			,[intCostingMethod] 
			,[intCreatedEntityId] 
			,[intConcurrencyId] 
		)
		SELECT 
			[intItemId]								= @intItemId
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
			,[strTransactionId]						= @strTransactionId
			,[intInventoryCostBucketStorageId]		= NULL 
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= @intTransactionTypeId
			,[ysnIsUnposted]						= NULL 
			,[strTransactionForm]					= @strTransactionForm
			,[intRelatedInventoryTransactionId]		= @intRelatedInventoryTransactionId
			,[intRelatedTransactionId]				= @intRelatedTransactionId
			,[strRelatedTransactionId]				= @strRelatedTransactionId
			,[intCostingMethod]						= @intCostingMethod
			,[intCreatedEntityId]					= @intEntityUserSecurityId
			,[intConcurrencyId]						= 1
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostInventoryTransactionStorage
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
				,@intRelatedInventoryTransactionId 
				,@intRelatedTransactionId 
				,@strRelatedTransactionId 
				,@strTransactionForm 
				,@intEntityUserSecurityId 
				,@intCostingMethod 
				,@InventoryTransactionIdentityId OUTPUT 
	END 

	-- Assert
	BEGIN
		INSERT INTO actual (
			[intItemId]
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
			,[strTransactionId] 
			,[intInventoryCostBucketStorageId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[strTransactionForm] 
			,[intRelatedInventoryTransactionId] 
			,[intRelatedTransactionId] 
			,[strRelatedTransactionId] 
			,[intCostingMethod] 
			,[intCreatedEntityId] 
			,[intConcurrencyId] 	
		)
		SELECT
			[intItemId]
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
			,[strTransactionId] 
			,[intInventoryCostBucketStorageId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[strTransactionForm] 
			,[intRelatedInventoryTransactionId] 
			,[intRelatedTransactionId] 
			,[strRelatedTransactionId] 
			,[intCostingMethod] 
			,[intCreatedEntityId] 
			,[intConcurrencyId] 
		FROM dbo.tblICInventoryTransactionStorage

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 


	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END