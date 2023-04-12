CREATE FUNCTION [dbo].[fnGLFiscalPeriodExists](@dtmDate DATETIME)
RETURNS BIT 
AS
BEGIN

DECLARE @exists BIT = 0 

SELECT @exists = 1 
FROM	dbo.tblGLFiscalYearPeriod 
WHERE	dbo.fnDateGreaterThanEquals(@dtmDate, dtmStartDate) = 1
		AND dbo.fnDateLessThanEquals(@dtmDate, dtmEndDate) = 1
AND @dtmDate IS NOT NULL
		
RETURN @exists

END