﻿CREATE PROCEDURE testi21Database.[test fnRemoveTimeOnDate on a date with time]
AS 
BEGIN
	-- Arrange
	DECLARE @dtmDate AS DATETIME = '2014-12-04 15:58:24.147'
	DECLARE @result AS DATETIME 
	DECLARE @Expected AS DATETIME = '2014-12-04' 

	-- Act
	SELECT @result = dbo.fnRemoveTimeOnDate(@dtmDate);

	-- Assert 
	-- Result is the samve value of the current average cost. In this case, it is NULL. 
	EXEC tSQLt.AssertEquals @Expected, @result;
END