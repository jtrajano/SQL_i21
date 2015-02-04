CREATE PROCEDURE testi21Database.[test the fnGetItemsToUnpost function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		CREATE TABLE expected (
			intItemId INT
			,intLocationId INT
			,dtmDate  DATETIME
			,dblUnitQty NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
			,dblSalesPrice NUMERIC(18,6)
			,intCurrencyId INT 
			,dblExchangeRate NUMERIC(18,6)
			,intTransactionId INT
			,strTransactionId NVARCHAR(40)
			,intTransactionTypeId INT 
			,intLotId INT 
		)

		CREATE TABLE actual (
			intItemId INT
			,intLocationId INT
			,dtmDate  DATETIME
			,dblUnitQty NUMERIC(18,6)
			,dblCost NUMERIC(18,6)
			,dblSalesPrice NUMERIC(18,6)
			,intCurrencyId INT 
			,dblExchangeRate NUMERIC(18,6)
			,intTransactionId INT
			,strTransactionId NVARCHAR(40)
			,intTransactionTypeId INT 
			,intLotId INT 
		)

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

		-- Create the mock data 
		EXEC testi21Database.[Fake data for inventory transaction table];

		-- Create the expected data
		INSERT INTO expected (
			intItemId
			,intLocationId
			,dtmDate
			,dblUnitQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
		)
		SELECT 			
			intItemId = @ColdGrains
			,intLocationId = @BetterHaven
			,dtmDate = '10/11/2014'
			,dblUnitQty = 1
			,dblCost = 100
			,dblSalesPrice = 2000
			,intCurrencyId = 1
			,dblExchangeRate = 1
			,intTransactionId = 2
			,strTransactionId = 'TRANSACTIONID-XXX2'
			,intTransactionTypeId = 11
			,intLotId = NULL
		UNION ALL 
		SELECT 			
			intItemId = @HotGrains
			,intLocationId = @BetterHaven
			,dtmDate = '10/11/2014'
			,dblUnitQty = 2
			,dblCost = 15.11
			,dblSalesPrice = 781.20
			,intCurrencyId = 1
			,dblExchangeRate = 1
			,intTransactionId = 2
			,strTransactionId = 'TRANSACTIONID-XXX2'
			,intTransactionTypeId = 11
			,intLotId = NULL
	END

	-- Act
	BEGIN 
		INSERT INTO actual (
			intItemId
			,intLocationId
			,dtmDate
			,dblUnitQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
		)
		SELECT 
			intItemId
			,intLocationId
			,dtmDate
			,dblUnitQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
		FROM dbo.fnGetItemsToUnpost(2, 11); 
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
	
END 
