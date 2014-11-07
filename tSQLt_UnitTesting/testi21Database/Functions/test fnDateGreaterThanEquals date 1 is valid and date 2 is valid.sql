CREATE PROCEDURE testi21Database.[test fnDateGreaterThanEquals date 1 is valid and date 1 is valid]
AS 
BEGIN
	
	BEGIN 
		-- Arrange
		DECLARE @date1 AS DATETIME = '2014-01-01'
		DECLARE @date2 AS DATETIME = '2014-01-01'

		DECLARE @result AS BIT

		-- Act
		SELECT @result = dbo.fnDateGreaterThanEquals(@date1, @date2);

		-- Assert the result is true
		EXEC tSQLt.AssertEquals 1, @result;
	END

	BEGIN 
		-- Arrange
		SET @date1 = '2014-01-01 14:12:05.860'
		SET @date2 = '2014-01-01 14:12:05.860'

		SET @result = NULL

		-- Act
		SELECT @result = dbo.fnDateGreaterThanEquals(@date1, @date2);

		-- Assert the result is true
		EXEC tSQLt.AssertEquals 1, @result;
	END
END 