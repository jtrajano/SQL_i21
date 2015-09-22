﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransactionStorage for inserting the supplied arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items];
				
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionType', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;			

		DECLARE	@intItemId INT								= 1
				,@intItemLocationId INT						= 2
				,@intItemUOMId INT							= 3
				,@intSubLocationId INT						= 4
				,@intStorageLocationId INT					= 5
				,@dtmDate DATETIME							= '01/06/2015'
				,@dblQty NUMERIC(18, 6)						= 7
				,@dblUOMQty NUMERIC(18, 6)					= 8
				,@dblCost NUMERIC(38, 20)					= 9
				,@dblValue NUMERIC(18, 6)					= 10
				,@dblSalesPrice NUMERIC(18, 6)				= 11
				,@intCurrencyId INT							= 12
				,@dblExchangeRate NUMERIC (38, 20)			= 13
				,@intTransactionId INT						= 14
				,@intTransactionDetailId INT				= 15
				,@strTransactionId NVARCHAR(40)				= '16'
				,@strBatchId NVARCHAR(20)					= '17'
				,@intTransactionTypeId INT					= 18
				,@intLotId INT								= 19
				,@strTransactionForm NVARCHAR (255)			= '20'
				,@intUserId INT								= 21
				,@SourceCostBucketStorageId INT			= 22
				,@InventoryTransactionIdStorageId INT		= 23

		CREATE TABLE expected (
			[intInventoryTransactionStorageId] INT, 
			[intItemId] INT,
			[intItemLocationId] INT,
			[intItemUOMId] INT,
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[intLotId] INT, 
			[dtmDate] DATETIME,	
			[dblQty] NUMERIC(18, 6), 
			[dblUOMQty] NUMERIC(18, 6), 		
			[dblCost] NUMERIC(38, 20), 
			[dblValue] NUMERIC(18, 6), 
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
			[dtmCreated] DATETIME, 
			[intCreatedUserId] INT, 
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
			[dblQty] NUMERIC(18, 6), 
			[dblUOMQty] NUMERIC(18, 6), 		
			[dblCost] NUMERIC(38, 20), 
			[dblValue] NUMERIC(18, 6), 
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
			[dtmCreated] DATETIME, 
			[intCreatedUserId] INT, 
			[intConcurrencyId] INT, 
		)

		INSERT INTO expected (
			[intInventoryTransactionStorageId]
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
			,[strTransactionId] 
			,[intInventoryCostBucketStorageId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[ysnIsUnposted] 
			,[strTransactionForm] 
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 
		)
		SELECT 
			[intInventoryTransactionStorageId]	= 1
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
			,[strTransactionId]						= @strTransactionId
			,[intInventoryCostBucketStorageId]	= @SourceCostBucketStorageId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= @intTransactionTypeId
			,[ysnIsUnposted]						= 0
			,[strTransactionForm]					= @strTransactionForm
			,[dtmCreated]							= dbo.fnRemoveTimeOnDate(GETDATE())
			,[intCreatedUserId]						= @intUserId
			,[intConcurrencyId] 					= 1
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
				,@strTransactionForm 
				,@intUserId 
				,@SourceCostBucketStorageId 
				,@InventoryTransactionIdStorageId OUTPUT 
	END 

	-- Assert
	BEGIN
		INSERT INTO actual (
			[intInventoryTransactionStorageId]
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
			,[strTransactionId] 
			,[intInventoryCostBucketStorageId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[ysnIsUnposted] 
			,[strTransactionForm] 
			,[dtmCreated] 
			,[intCreatedUserId] 
			,[intConcurrencyId] 		
		)
		SELECT
			[intInventoryTransactionStorageId]
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
			,[strTransactionId] 
			,[intInventoryCostBucketStorageId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[ysnIsUnposted] 
			,[strTransactionForm] 
			,dbo.fnRemoveTimeOnDate(dtmCreated)
			,[intCreatedUserId] 
			,[intConcurrencyId] 
		FROM dbo.tblICInventoryTransactionStorage

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	select * from tblICInventoryTransactionStorage

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END