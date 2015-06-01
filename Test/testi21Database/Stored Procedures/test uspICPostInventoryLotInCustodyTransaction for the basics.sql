CREATE PROCEDURE [testi21Database].[test uspICPostInventoryLotInCustodyTransaction for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotInCustodyTransaction', @Identity = 1;

		DECLARE	@intItemId INT
				,@intItemLocationId INT
				,@intItemUOMId INT 
				,@intSubLocationId INT
				,@intStorageLocationId INT
				,@dtmDate DATETIME
				,@dblQty NUMERIC(18, 6)
				,@dblUOMQty NUMERIC(18, 6)
				,@dblCost NUMERIC(18, 6)
				,@dblValue NUMERIC(18, 6)
				,@dblSalesPrice NUMERIC(18, 6)	
				,@intCurrencyId INT
				,@dblExchangeRate NUMERIC (38, 20)
				,@intTransactionId INT
				,@strTransactionId NVARCHAR(40)
				,@strBatchId NVARCHAR(20)
				,@intTransactionTypeId INT
				,@intLotId INT
				,@strTransactionForm NVARCHAR (255)
				,@intUserId INT
				,@InventoryLotInCustodyTransactionId INT

		-- Declare the variables for the Item UOM Ids
		DECLARE @WetGrains_BushelUOMId AS INT = 1
				,@StickyGrains_BushelUOMId AS INT = 2
				,@PremiumGrains_BushelUOMId AS INT = 3
				,@ColdGrains_BushelUOMId AS INT = 4
				,@HotGrains_BushelUOMId AS INT = 5

		CREATE TABLE expected (
			intInventoryTransactionId INT
			,intItemId INT
			,intItemLocationId INT
			,intItemUOMId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,dtmDate DATETIME
			,dblQty NUMERIC(18, 6)
			,dblCost NUMERIC(18, 6)
			,dblValue NUMERIC(18, 6)
			,dblSalesPrice NUMERIC(18, 6)
			,intCurrencyId INT
			,dblExchangeRate NUMERIC (38, 20)
			,intTransactionId INT
			,intTransactionDetailId INT
			,strTransactionId NVARCHAR(40)
			,strBatchId NVARCHAR(20)
			,intTransactionTypeId INT
			,intLotId INT
			,ysnIsUnposted BIT
			,intRelatedInventoryTransactionId INT
			,intRelatedTransactionId INT
			,strRelatedTransactionId NVARCHAR(40)
			,strTransactionForm NVARCHAR (255)
			,intUserId INT
		)

		CREATE TABLE actual (
			intInventoryTransactionId INT
			,intItemId INT
			,intItemLocationId INT
			,intItemUOMId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,dtmDate DATETIME
			,dblQty NUMERIC(18, 6)
			,dblCost NUMERIC(18, 6)
			,dblValue NUMERIC(18, 6)
			,dblSalesPrice NUMERIC(18, 6)
			,intCurrencyId INT
			,dblExchangeRate NUMERIC (38, 20)
			,intTransactionId INT
			,intTransactionDetailId INT
			,strTransactionId NVARCHAR(40)
			,strBatchId NVARCHAR(20)
			,intTransactionTypeId INT
			,intLotId INT
			,ysnIsUnposted BIT
			,intRelatedInventoryTransactionId INT
			,intRelatedTransactionId INT
			,strRelatedTransactionId NVARCHAR(40)
			,strTransactionForm NVARCHAR (255)
			,intUserId INT
		)
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
			,@strTransactionId 
			,@strBatchId 
			,@intTransactionTypeId 
			,@intLotId 
			,@strTransactionForm 
			,@intUserId 
			,@InventoryLotInCustodyTransactionId OUTPUT 
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
		EXEC tSQLt.AssertEmptyTable 'tblICInventoryLotInCustodyTransaction';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END