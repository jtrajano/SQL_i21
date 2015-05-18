﻿CREATE PROCEDURE testi21Database.[test fnDateLessThan date 1 higher than date 2]
AS 
BEGIN
	-- Arrange
	BEGIN 
		DECLARE @date1 AS DATETIME = '2014-01-02'
		DECLARE @date2 AS DATETIME = '2014-01-01'

		DECLARE @result AS BIT

		-- Act
		SELECT @result = dbo.fnDateLessThan(@date1, @date2);

		-- Assert the result is false
		EXEC tSQLt.AssertEquals 0, @result;
	END 

	BEGIN 
		-- Arrange 
		SET @date1 = '2014-01-02 14:12:05.860'
		SET @date2 = '2014-01-01 14:12:05.860'
		SET @result = NULL 

		-- Act
		SELECT @result = dbo.fnDateLessThan(@date1, @date2);

		-- Assert the result is false
		EXEC tSQLt.AssertEquals 0, @result;
	END

	BEGIN 
		-- Arrange 
		SET @date1 = '2014-01-02 14:12:05.861'
		SET @date2 = '2014-01-02 14:12:05.860'
		SET @result = NULL 

		-- Act
		SELECT @result = dbo.fnDateLessThan(@date1, @date2);

		-- Assert the result is false
		-- Time is ignored in the date
		EXEC tSQLt.AssertEquals 0, @result;
	END
END