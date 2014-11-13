CREATE PROCEDURE testi21Database.[test fnGetCredit for negative value]
AS 
BEGIN
	-- Arrange
	CREATE TABLE expected (
		Value NUMERIC(18,6)
	)

	CREATE TABLE actual (
		Value NUMERIC(18,6)
	)
	
	-- Expect it to return the absolute of value;
	DECLARE @value AS NUMERIC(18,6) = -665;
	INSERT INTO expected VALUES (ABS(@value));

	-- Act
	INSERT INTO actual 
	SELECT * FROM dbo.fnGetCredit(@value);

	-- Assert 
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	BEGIN
		IF OBJECT_ID('actual') IS NOT NULL 
			DROP TABLE actual

		IF OBJECT_ID('expected') IS NOT NULL 
			DROP TABLE dbo.expected
	END 
END 