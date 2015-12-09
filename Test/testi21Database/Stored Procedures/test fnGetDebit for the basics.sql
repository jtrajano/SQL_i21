﻿CREATE PROCEDURE testi21Database.[test fnGetDebit for the basics]
AS 
BEGIN
	-- Arrange
	CREATE TABLE expected (
		Value NUMERIC(18,6)
	)

	CREATE TABLE actual (
		Value NUMERIC(18,6)
	)
	
	-- Expect it to return zero when value is NULL 
	INSERT INTO expected VALUES (0);	
	DECLARE @value AS NUMERIC(18,6);

	-- Act
	INSERT INTO actual 
	SELECT * FROM dbo.fnGetDebit(@value);

	-- Assert 
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	-- Clean-up: remove the tables used in the unit test
	BEGIN
		IF OBJECT_ID('actual') IS NOT NULL 
			DROP TABLE actual

		IF OBJECT_ID('expected') IS NOT NULL 
			DROP TABLE expected
	END 
END