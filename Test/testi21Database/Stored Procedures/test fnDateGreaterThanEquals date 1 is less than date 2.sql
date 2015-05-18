﻿CREATE PROCEDURE testi21Database.[test fnDateGreaterThanEquals date 1 is less than date 2]
AS 
BEGIN	
	BEGIN 
		-- Arrange
		DECLARE @date1 AS DATETIME = '2014-01-02'
		DECLARE @date2 AS DATETIME = '2014-01-03'

		DECLARE @result AS BIT

		-- Act
		SELECT @result = dbo.fnDateGreaterThanEquals(@date1, @date2);

		-- Assert the result is false
		EXEC tSQLt.AssertEquals 0, @result;
	END
	BEGIN 
		-- Arrange
		SET @date1 = '2014-01-02 14:12:05.860' 
		SET @date2 = '2014-01-03 14:12:05.860'
		SET @result = NULL

		-- Act
		SELECT @result = dbo.fnDateGreaterThanEquals(@date1, @date2);

		-- Assert the result is false
		EXEC tSQLt.AssertEquals 0, @result;
	END 

	BEGIN 
		-- Arrange
		SET @date1 = '2014-01-01 14:12:05.60' 
		SET @date2 = '2014-01-01 14:12:05.860'
		SET @result = NULL

		-- Act
		SELECT @result = dbo.fnDateGreaterThanEquals(@date1, @date2);

		-- Assert the result is true
		-- Date 1 time-part is less than date 2. Since time-part is ignored, result should be true 
		EXEC tSQLt.AssertEquals 1, @result;
	END 
END