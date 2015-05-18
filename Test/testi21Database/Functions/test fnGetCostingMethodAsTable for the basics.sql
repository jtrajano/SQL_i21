CREATE PROCEDURE testi21Database.[test fnGetCostingMethodAsTable for the basics]
AS 
BEGIN
	-- Arrange
	BEGIN
		CREATE TABLE expected(
			CostingMethod INT NULL
		)

		CREATE TABLE actual(
			CostingMethod INT NULL
		)

		DECLARE @intItemId AS INT
		DECLARE @intItemLocationId AS INT

	END


	-- Act
	BEGIN 		
		INSERT INTO actual
		SELECT CostingMethod 
		FROM dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)
	END 

	-- Assert 
	BEGIN 			
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