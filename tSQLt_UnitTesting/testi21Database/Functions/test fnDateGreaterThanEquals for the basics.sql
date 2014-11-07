CREATE PROCEDURE testi21Database.[test fnDateGreaterThanEquals for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @date1 AS DATETIME
	DECLARE @date2 AS DATETIME 

	DECLARE @result AS BIT


	-- Act
	SELECT @result = dbo.fnDateGreaterThanEquals(@date1, @date2);

	-- Assert 
	EXEC tSQLt.AssertEquals 0, @result;
END 