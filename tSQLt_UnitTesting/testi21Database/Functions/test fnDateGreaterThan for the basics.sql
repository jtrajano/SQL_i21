CREATE PROCEDURE testi21Database.[test fnDateGreaterThan for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @date1 AS DATETIME
	DECLARE @date2 AS DATETIME 

	DECLARE @result AS BIT


	-- Act
	SELECT @result = dbo.fnDateGreaterThan(@date1, @date2);

	-- Assert the null dates are not equal dates
	EXEC tSQLt.AssertEquals 0, @result;
END 