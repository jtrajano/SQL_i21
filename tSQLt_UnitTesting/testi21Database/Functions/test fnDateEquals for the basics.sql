CREATE PROCEDURE testi21Database.[test fnDateEquals for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @date1 AS DATETIME
	DECLARE @date2 AS DATETIME 

	DECLARE @result AS BIT


	-- Act
	SELECT @result = dbo.fnDateEquals(@date1, @date2);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals 0, @result;
END 