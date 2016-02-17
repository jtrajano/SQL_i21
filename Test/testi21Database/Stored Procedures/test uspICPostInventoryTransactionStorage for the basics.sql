CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransactionStorage for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionStorage', @Identity = 1;

		DECLARE 
				@intItemId INT								
				,@intItemLocationId INT						
				,@intItemUOMId INT							
				,@intSubLocationId INT						
				,@intStorageLocationId INT					
				,@dtmDate DATETIME							
				,@dblQty NUMERIC(38,20)						
				,@dblUOMQty NUMERIC(38,20)					
				,@dblCost NUMERIC(38,20)					
				,@dblValue NUMERIC(38,20)					
				,@dblSalesPrice NUMERIC(18, 6)				
				,@intCurrencyId INT							
				,@dblExchangeRate NUMERIC (38,20)			
				,@intTransactionId INT						
				,@intTransactionDetailId INT				
				,@strTransactionId NVARCHAR(40)				
				,@strBatchId NVARCHAR(20)					
				,@intTransactionTypeId INT					
				,@intLotId INT								
				,@intRelatedInventoryTransactionId INT		
				,@intRelatedTransactionId INT				
				,@strRelatedTransactionId NVARCHAR(40)		
				,@strTransactionForm NVARCHAR (255)			
				,@intEntityUserSecurityId INT				
				,@intCostingMethod INT						
				,@InventoryTransactionIdentityId INT		

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

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
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
		EXEC tSQLt.AssertEmptyTable 'tblICInventoryTransactionStorage';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END
