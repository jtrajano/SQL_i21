CREATE PROCEDURE [testi21Database].[test uspICPostInventoryLotTransactionInCustody for inserting the supplied arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items];
				
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustody', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionType', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;			

		DECLARE @intItemId INT
				,@intLotId INT
				,@intItemLocationId INT				
				,@intItemUOMId INT 
				,@intSubLocationId INT
				,@intStorageLocationId INT
				,@dtmDate DATETIME
				,@dblQty NUMERIC(18, 6)
				,@dblCost NUMERIC(18, 6)
				,@intTransactionId INT
				,@intTransactionDetailId INT 
				,@strTransactionId NVARCHAR(40)
				,@strBatchId NVARCHAR(20)
				,@intLotStatusId INT 
				,@intTransactionTypeId INT	
				,@strTransactionForm NVARCHAR (255)
				,@intUserId INT
				,@SourceInventoryLotInCustodyId INT 
				,@InventoryLotTransactionInCustodyId INT  
				,@intLocationId INT 
			
		SELECT	@intItemId				= 1
				,@intLotId				= 2 
				,@intItemLocationId		= 3
				,@intItemUOMId			= 4
				,@intSubLocationId		= 5
				,@intStorageLocationId	= 6
				,@dtmDate				= dbo.fnRemoveTimeOnDate(GETDATE())
				,@dblQty				= 7
				,@dblCost				= 8
				,@intTransactionId		= 9 
				,@intTransactionDetailId = 10
				,@strTransactionId		= '11'
				,@strBatchId			= '12'
				,@intLotStatusId		= 13
				,@intTransactionTypeId	= 14
				,@strTransactionForm	= '15'
				,@intUserId				= 16
				,@SourceInventoryLotInCustodyId			= 17
				,@InventoryLotTransactionInCustodyId	= 18 
				,@intLocationId			= 1

		CREATE TABLE expected (
			[intInventoryLotTransactionInCustodyId] INT, 
			[intItemId] INT ,		
			[intLotId] INT , 
			[intLocationId] INT ,
			[intItemLocationId] INT ,
			[intSubLocationId] INT ,
			[intStorageLocationId] INT ,
			[dtmDate] DATETIME , 
			[dblQty] NUMERIC(18, 6) , 
			[intItemUOMId] INT ,
			[dblCost] NUMERIC(18, 6) , 
			[intTransactionId] INT , 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intTransactionTypeId] INT, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS, 
			[intLotStatusId] INT,
			[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS,
			[ysnIsUnposted] BIT,
			[intInventoryCostBucketInCustodyId] INT, 
			[dtmCreated] DATETIME, 
			[intCreatedUserId] INT, 
			[intConcurrencyId] INT 
		)

		CREATE TABLE actual (
			[intInventoryLotTransactionInCustodyId] INT, 
			[intItemId] INT ,		
			[intLotId] INT , 
			[intLocationId] INT ,
			[intItemLocationId] INT ,
			[intSubLocationId] INT ,
			[intStorageLocationId] INT ,
			[dtmDate] DATETIME , 
			[dblQty] NUMERIC(18, 6) , 
			[intItemUOMId] INT ,
			[dblCost] NUMERIC(18, 6) , 
			[intTransactionId] INT , 
			[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS, 
			[intTransactionTypeId] INT, 
			[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS, 
			[intLotStatusId] INT,
			[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS,
			[ysnIsUnposted] BIT,
			[intInventoryCostBucketInCustodyId] INT, 
			[dtmCreated] DATETIME, 
			[intCreatedUserId] INT, 
			[intConcurrencyId] INT
		)

		INSERT INTO expected (
			[intInventoryLotTransactionInCustodyId]
			,[intItemId]
			,[intLotId]
			,[intLocationId]
			,[intItemLocationId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dtmDate]
			,[dblQty]
			,[intItemUOMId]
			,[dblCost]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[strBatchId]
			,[intLotStatusId]
			,[strTransactionForm]
			,[ysnIsUnposted]
			,[intInventoryCostBucketInCustodyId]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT 
			[intInventoryLotTransactionInCustodyId]		= 1
			,[intItemId]								= @intItemId
			,[intLotId]									= @intLotId
			,[intLocationId]							= @intLocationId
			,[intItemLocationId]						= @intItemLocationId
			,[intSubLocationId]							= @intSubLocationId
			,[intStorageLocationId]						= @intStorageLocationId
			,[dtmDate]									= @dtmDate
			,[dblQty]									= @dblQty
			,[intItemUOMId]								= @intItemUOMId
			,[dblCost]									= @dblCost
			,[intTransactionId]							= @intTransactionId
			,[strTransactionId]							= @strTransactionId
			,[intTransactionTypeId]						= @intTransactionTypeId
			,[strBatchId]								= @strBatchId
			,[intLotStatusId]							= @intLotStatusId
			,[strTransactionForm]						= @strTransactionForm
			,[ysnIsUnposted]							= 0
			,[intInventoryCostBucketInCustodyId]		= @SourceInventoryLotInCustodyId
			,[dtmCreated]								= dbo.fnRemoveTimeOnDate(GETDATE())
			,[intCreatedUserId]							= @intUserId
			,[intConcurrencyId]							= 1
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostInventoryLotTransactionInCustody		
			@intItemId 
			,@intLotId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@intSubLocationId 
			,@intStorageLocationId 
			,@dtmDate 
			,@dblQty 
			,@dblCost 
			,@intTransactionId 
			,@intTransactionDetailId 
			,@strTransactionId 
			,@strBatchId 
			,@intLotStatusId 
			,@intTransactionTypeId 
			,@strTransactionForm 
			,@intUserId 
			,@SourceInventoryLotInCustodyId  
			,@InventoryLotTransactionInCustodyId OUTPUT 

	END 

	-- Assert
	BEGIN
		INSERT INTO actual (
			[intInventoryLotTransactionInCustodyId]
			,[intItemId]
			,[intLotId]
			,[intLocationId]
			,[intItemLocationId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dtmDate]
			,[dblQty]
			,[intItemUOMId]
			,[dblCost]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[strBatchId]
			,[intLotStatusId]
			,[strTransactionForm]
			,[ysnIsUnposted]
			,[intInventoryCostBucketInCustodyId]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
		)
		SELECT
			[intInventoryLotTransactionInCustodyId]
			,[intItemId]
			,[intLotId]
			,[intLocationId]
			,[intItemLocationId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dtmDate]
			,[dblQty]
			,[intItemUOMId]
			,[dblCost]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[strBatchId]
			,[intLotStatusId]
			,[strTransactionForm]
			,[ysnIsUnposted]
			,[intInventoryCostBucketInCustodyId]
			,dbo.fnRemoveTimeOnDate(dtmCreated)
			,[intCreatedUserId]
			,[intConcurrencyId]
		FROM dbo.tblICInventoryLotTransactionInCustody

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END