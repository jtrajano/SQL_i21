CREATE PROCEDURE [testi21Database].[test uspICPostInventoryLotTransactionStorage for inserting the supplied arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items];
				
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransactionStorage', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotStorage', @Identity = 1;
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
				,@intEntityUserSecurityId INT
				,@SourceInventoryLotStorageId INT 
				,@InventoryLotTransactionStorageId INT  
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
				,@intEntityUserSecurityId				= 16
				,@SourceInventoryLotStorageId			= 17
				,@InventoryLotTransactionStorageId	= 18 
				,@intLocationId			= 1

		CREATE TABLE expected (
			[intInventoryLotTransactionStorageId] INT, 
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
			[intInventoryCostBucketStorageId] INT, 
			[dtmCreated] DATETIME, 
			[intCreatedEntityId] INT, 
			[intConcurrencyId] INT 
		)

		CREATE TABLE actual (
			[intInventoryLotTransactionStorageId] INT, 
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
			[intInventoryCostBucketStorageId] INT, 
			[dtmCreated] DATETIME, 
			[intCreatedEntityId] INT, 
			[intConcurrencyId] INT
		)

		INSERT INTO expected (
			[intInventoryLotTransactionStorageId]
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
			,[intInventoryCostBucketStorageId]
			,[dtmCreated]
			,[intCreatedEntityId]
			,[intConcurrencyId]
		)
		SELECT 
			[intInventoryLotTransactionStorageId]		= 1
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
			,[intInventoryCostBucketStorageId]		= @SourceInventoryLotStorageId
			,[dtmCreated]								= dbo.fnRemoveTimeOnDate(GETDATE())
			,[intCreatedEntityId]							= @intEntityUserSecurityId
			,[intConcurrencyId]							= 1
	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostInventoryLotTransactionStorage		
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
			,@intEntityUserSecurityId 
			,@SourceInventoryLotStorageId  
			,@InventoryLotTransactionStorageId OUTPUT 

	END 

	-- Assert
	BEGIN
		INSERT INTO actual (
			[intInventoryLotTransactionStorageId]
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
			,[intInventoryCostBucketStorageId]
			,[dtmCreated]
			,[intCreatedEntityId]
			,[intConcurrencyId]
		)
		SELECT
			[intInventoryLotTransactionStorageId]
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
			,[intInventoryCostBucketStorageId]
			,dbo.fnRemoveTimeOnDate(dtmCreated)
			,[intCreatedEntityId]
			,[intConcurrencyId]
		FROM dbo.tblICInventoryLotTransactionStorage

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END