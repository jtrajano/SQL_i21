CREATE PROCEDURE testi21Database.[test fnRemoveTimeOnDate for the basics]
AS 
BEGIN
	-- Arrange
	DECLARE @dtmDate AS DATETIME 
	DECLARE @result AS DATETIME 
	DECLARE @expected AS DATETIME 

	-- Act
	SELECT @result = dbo.fnRemoveTimeOnDate(@dtmDate);

	-- Assert 
	-- Result is the samve value of the current average cost. In this case, it is NULL. 
	EXEC tSQLt.AssertEquals @expected, @result;
END 