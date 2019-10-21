CREATE FUNCTION [dbo].[fnGetFirstDateOfWeek]
(
       @intWeek INT,
       @intYear INT
)
RETURNS DATETIME
AS 
BEGIN
	   DECLARE @dtmNeedDate DATETIME       
       SET @dtmNeedDate = DATEADD(WEEK, @intWeek, DATEADD(YEAR, @intYear - 1900, 0)) 
						  - 4 
						  - DATEPART(dw, DATEADD(WEEK, @intWeek, DATEADD(YEAR, @intYear - 1900, 0)) - 4) 
						  + 1
      
RETURN @dtmNeedDate; 
END
