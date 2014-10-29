CREATE PROCEDURE testi21Database.[test the fnGetItemCostingOnPostErrors function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		CREATE TABLE expected (
			intItemId INT
			,intLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		CREATE TABLE actual (
			intItemId INT
			,intLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
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

		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intLocationId
				,strText
				,intErrorCode
		)
		-- 2: Invalid item and valid location
		SELECT	intItemId = @InvalidItem
				,intLocationId = @Default_Location
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027
		UNION ALL
		SELECT	intItemId = @InvalidItem
				,intLocationId = @Default_Location
				,strText = FORMATMESSAGE(50028)
				,intErrorCode = 50028

		-- 3: Valid item and invalid location
		UNION ALL
		SELECT	intItemId = @StickyGrains
				,intLocationId = @InvalidLocation
				,strText = FORMATMESSAGE(50028)
				,intErrorCode = 50028

		-- 4: Invalid item and invalid location
		UNION ALL		
		SELECT	intItemId = @InvalidItem
				,intLocationId = @InvalidLocation
				,strText = FORMATMESSAGE(50027)
				,intErrorCode = 50027
		UNION ALL
		SELECT	intItemId = @InvalidItem
				,intLocationId = @InvalidLocation
				,strText = FORMATMESSAGE(50028)
				,intErrorCode = 50028

		-- 6: Negative stock is not allowed 
		UNION ALL
		SELECT	intItemId = @WetGrains
				,intLocationId = @BetterHaven
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029

		-- Create the mock data 
		EXEC testi21Database.[Fake data for simple Items];
	END

	-- Act
	BEGIN 
		INSERT INTO actual
		-- 1: Valid item and valid location. 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @Default_Location, NULL)
		
		-- 2: Invalid item and valid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@InvalidItem, @Default_Location, NULL)

		-- 3: Valid item and invalid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@StickyGrains, @InvalidLocation, NULL)

		-- 4: Invalid item and invalid location
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@InvalidItem, @InvalidLocation, NULL)

		-- 5: Postive stock 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @NewHaven, 10)

		-- 6: Negative stock is not allowed 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @BetterHaven, -10)

		-- 7: Negative stock is allowed
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @NewHaven, -10)
		
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
	
END 
