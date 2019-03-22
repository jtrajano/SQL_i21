
CREATE FUNCTION [dbo].isOpenAccountingDate(@dtmDate DATETIME)
RETURNS BIT 
AS
BEGIN

DECLARE @isOpen BIT = 0 

SELECT TOP 1 @isOpen = 1 
FROM	dbo.tblGLFiscalYearPeriod 
WHERE	dbo.fnDateGreaterThanEquals(@dtmDate, dtmStartDate) = 1
		AND dbo.fnDateLessThanEquals(@dtmDate, dtmEndDate) = 1
		AND ISNULL(ysnOpen, 0) = 1
RETURN @isOpen

END