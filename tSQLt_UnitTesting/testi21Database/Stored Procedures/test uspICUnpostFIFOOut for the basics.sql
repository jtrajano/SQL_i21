CREATE PROCEDURE [testi21Database].[test uspICUnpostFIFOOut for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @strTransactionId AS NVARCHAR(40)
		DECLARE @intTransactionId AS INT

		CREATE TABLE actual (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)

		CREATE TABLE expected (
			strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
			,intTransactionId INT
			,dblStockIn NUMERIC(18,6)
			,dblStockOut NUMERIC(18,6)
		)
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICUnpostFIFOOut @strTransactionId, @intTransactionId
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

END