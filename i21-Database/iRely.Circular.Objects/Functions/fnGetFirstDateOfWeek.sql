CREATE FUNCTION [dbo].[fnGetFirstDateOfWeek]
(
       @intWeek INT,
       @intYear INT
)
RETURNS DATETIME
AS 
BEGIN
    DECLARE @dtmNeedDate DATETIME
       SET @dtmNeedDate = DATEADD(YEAR, @intYear - 1900, 0)
       SET @dtmNeedDate =DATEADD(DAY, (@@DATEFIRST - DATEPART(WEEKDAY, @dtmNeedDate) + (8 - @@DATEFIRST) * 2) % 7, @dtmNeedDate)
       SET @dtmNeedDate=@dtmNeedDate+(@intWeek-1)*7  
       
RETURN @dtmNeedDate; 
END
