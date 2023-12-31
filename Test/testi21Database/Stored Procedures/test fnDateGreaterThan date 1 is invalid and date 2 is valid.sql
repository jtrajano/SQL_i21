﻿CREATE PROCEDURE testi21Database.[test fnDateGreaterThan date 1 is invalid and date 2 is valid]
AS 
BEGIN
	
	BEGIN 
		-- Arrange
		DECLARE @date1 AS DATETIME 
		DECLARE @date2 AS DATETIME = '2014-01-01'

		DECLARE @result AS BIT


		-- Act
		SELECT @result = dbo.fnDateGreaterThan(@date1, @date2);

		-- Assert the result is false
		EXEC tSQLt.AssertEquals 0, @result;
	END 

	BEGIN 
		-- Arrange
		SET @date1 = NULL 
		SET @date2 = '2014-01-01 14:12:05.860'
		SET @result = NULL

		-- Act
		SELECT @result = dbo.fnDateGreaterThan(@date1, @date2);

		-- Assert the result is true
		EXEC tSQLt.AssertEquals 0, @result;
	END 

END