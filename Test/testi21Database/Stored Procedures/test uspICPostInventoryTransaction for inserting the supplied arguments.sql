CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransaction for inserting the supplied arguments]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC testi21Database.[Fake inventory items];
				
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryLotTransaction', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransactionType', @Identity = 1;
		EXEC tSQLt.FakeTable 'dbo.tblICLot', @Identity = 1;			

		DECLARE	@intItemId AS INT							= 1
				,@intItemLocationId AS INT					= 2
				,@intItemUOMId AS INT						= 3
				,@intSubLocationId AS INT					= 4
				,@intStorageLocationId AS INT				= 5
				,@dtmDate AS DATETIME						= '01/01/2011'
				,@dblQty AS NUMERIC(18, 6)					= 6
				,@dblUOMQty AS NUMERIC(18, 6)				= 7
				,@dblCost AS NUMERIC(18, 6)					= 8
				,@dblValue AS NUMERIC(18, 6)				= 9
				,@dblSalesPrice AS NUMERIC(18, 6)			= 10
				,@intCurrencyId AS INT						= 11
				,@dblExchangeRate AS NUMERIC (38, 20)		= 12
				,@intTransactionId AS INT					= 13
				,@intTransactionDetailId AS INT				= 13
				,@strTransactionId AS NVARCHAR(40)			= '14'
				,@strBatchId AS NVARCHAR(20)				= '15'
				,@intTransactionTypeId AS INT				= 16
				,@intLotId AS INT							= 17
				,@intRelatedInventoryTransactionId AS INT	= 18
				,@intRelatedTransactionId AS INT			= 19
				,@strRelatedTransactionId AS NVARCHAR(40)	= '20'
				,@strTransactionForm AS NVARCHAR (255)		= '21'
				,@intUserId AS INT							= 22
				,@InventoryTransactionIdentityId AS INT		= 23

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
			,intCreatedUserId INT
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
			,intCreatedUserId INT
		)

		INSERT INTO expected (
			intInventoryTransactionId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dtmDate
			,dblQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,intTransactionDetailId 
			,strTransactionId
			,strBatchId
			,intTransactionTypeId
			,intLotId
			,ysnIsUnposted
			,intRelatedInventoryTransactionId
			,intRelatedTransactionId
			,strRelatedTransactionId
			,strTransactionForm 
			,intCreatedUserId
		)
		SELECT			
			intInventoryTransactionId			= 1
			,intItemId							= @intItemId
			,intItemLocationId					= @intItemLocationId
			,intItemUOMId						= @intItemUOMId
			,intSubLocationId					= @intSubLocationId
			,intStorageLocationId				= @intStorageLocationId
			,dtmDate							= @dtmDate
			,dblQty								= @dblQty
			,dblCost							= @dblCost
			,dblValue							= @dblValue
			,dblSalesPrice						= @dblSalesPrice
			,intCurrencyId						= @intCurrencyId
			,dblExchangeRate					= @dblExchangeRate
			,intTransactionId					= @intTransactionId
			,intTransactionDetailId				= @intTransactionDetailId
			,strTransactionId					= @strTransactionId
			,strBatchId							= @strBatchId
			,intTransactionTypeId				= @intTransactionTypeId
			,intLotId							= @intLotId
			,ysnIsUnposted						= 0
			,intRelatedInventoryTransactionId	= @intRelatedInventoryTransactionId
			,intRelatedTransactionId			= @intRelatedTransactionId
			,strRelatedTransactionId			= @strRelatedTransactionId
			,strTransactionForm					= @strTransactionForm
			,intCreatedUserId					= @intUserId

	END 
	
	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICPostInventoryTransaction
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
				,@intUserId
				,@InventoryTransactionIdentityId OUTPUT 
	END 

	-- Assert
	BEGIN
		INSERT INTO actual (
			intInventoryTransactionId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dtmDate
			,dblQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,strBatchId
			,intTransactionTypeId
			,intLotId
			,ysnIsUnposted
			,intRelatedInventoryTransactionId
			,intRelatedTransactionId
			,strRelatedTransactionId
			,strTransactionForm 
			,intCreatedUserId		
		)
		SELECT
			intInventoryTransactionId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dtmDate
			,dblQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,strBatchId
			,intTransactionTypeId
			,intLotId
			,ysnIsUnposted
			,intRelatedInventoryTransactionId
			,intRelatedTransactionId
			,strRelatedTransactionId
			,strTransactionForm 
			,intCreatedUserId
		FROM dbo.tblICInventoryTransaction

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END
