CREATE PROCEDURE testi21Database.[test the fnGetItemGLAccounts function]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @intItemId AS INT
		DECLARE @intLocationId AS INT

		-- GL Account types used in inventory costing
		DECLARE @InventoryAccountId AS INT = 1;
		DECLARE @COGSAccountId AS INT = 2;
		DECLARE @SalesAccountId AS INT = 3;
		DECLARE @RevalueCostAccountId AS INT = 4;
		DECLARE @WriteOffCostAccountId AS INT = 5;
		DECLARE @AutoNegativeAccountId AS INT = 6;

		DECLARE @actual AS NVARCHAR(40);

		CREATE TABLE expected(
			intInventoryAccount INT
			,intCOGSAccount INT
			,intRevalueCostAccount INT
			,intWriteOffCostAccount INT
			,intAutoNegativeAccount INT
		)

		CREATE TABLE actual(
			intInventoryAccount INT
			,intCOGSAccount INT
			,intRevalueCostAccount INT
			,intWriteOffCostAccount INT
			,intAutoNegativeAccount INT
		)
	END 

	-- Test case
	-- 1. Will return empty table since item id and location id are NULL. 
	BEGIN 
		-- Act
		INSERT actual (
			intInventoryAccount
			,intCOGSAccount
			,intRevalueCostAccount
			,intWriteOffCostAccount
			,intAutoNegativeAccount
		)
		SELECT	*
		FROM	[dbo].[fnGetItemGLAccounts](@intItemId, @intLocationId)

		-- expects a row with NULL values on all fields. 
		INSERT expected (
			intInventoryAccount
			,intCOGSAccount
			,intRevalueCostAccount
			,intWriteOffCostAccount
			,intAutoNegativeAccount
		)
		SELECT				
			intInventoryAccount = NULL
			,intCOGSAccount = NULL
			,intRevalueCostAccount = NULL
			,intWriteOffCostAccount = NULL
			,intAutoNegativeAccount = NULL

		-- Assert
		EXEC tSQLt.AssertObjectExists 'actual';
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	BEGIN
		IF OBJECT_ID('actual') IS NOT NULL 
			DROP TABLE actual

		IF OBJECT_ID('expected') IS NOT NULL 
			DROP TABLE dbo.expected
	END 
END 