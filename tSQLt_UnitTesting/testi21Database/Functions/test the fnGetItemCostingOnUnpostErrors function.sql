CREATE PROCEDURE testi21Database.[test the fnGetItemCostingOnUnpostErrors function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		CREATE TABLE expected (
			intItemId INT
			,intItemLocationId INT
			,strText NVARCHAR(MAX) NULL
			,intErrorCode INT
		)

		CREATE TABLE actual (
			intItemId INT
			,intItemLocationId INT
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

		-- Create the mock data 
		EXEC testi21Database.[Fake inventory items]

		-- Fake data for item stock table
		BEGIN 
			EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;

			-- Add stock information for items under location 1 ('Default')
			DECLARE @intItemLocationId_1 AS INT 
			SELECT @intItemLocationId_1 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @Default_Location
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_1, 100, 22)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @Default_Location, 150, 33)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @Default_Location, 200, 44)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @Default_Location, 250, 55)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @Default_Location, 300, 66)

			-- Add stock information for items under location 2 ('NEW HAVEN')
			DECLARE @intItemLocationId_2 AS INT 
			SELECT @intItemLocationId_2 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @NewHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_2, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @NewHaven, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @NewHaven, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @NewHaven, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @NewHaven, 0, 0)

			-- Add stock information for items under location 3 ('BETTER HAVEN')
			DECLARE @intItemLocationId_3 AS INT 
			SELECT @intItemLocationId_3 = intItemLocationId FROM dbo.tblICItemLocation WHERE intItemId = @WetGrains AND intLocationId = @BetterHaven
			INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@WetGrains, @intItemLocationId_3, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@StickyGrains, @BetterHaven, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@PremiumGrains, @BetterHaven, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@ColdGrains, @BetterHaven, 0, 0)
			--INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand, dblAverageCost) VALUES (@HotGrains, @BetterHaven, 0, 0)
		END

		-- Setup the expected data
		INSERT INTO expected (
				intItemId
				,intItemLocationId
				,strText
				,intErrorCode
		)
		-- 2: Negative stock is not allowed 
		SELECT	intItemId = @WetGrains
				,intItemLocationId = @intItemLocationId_3
				,strText = FORMATMESSAGE(50029)
				,intErrorCode = 50029
	END

	-- Act
	BEGIN 
		INSERT INTO actual
		-- 1: Postive stock 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_2, 10)

		-- 2: Negative stock is not allowed 
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_3, -10)

		-- 3: Negative stock is allowed
		UNION ALL 
		SELECT * FROM dbo.fnGetItemCostingOnPostErrors(@WetGrains, @intItemLocationId_2, -10)
		
	END

	-- Assert
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
	
END 
