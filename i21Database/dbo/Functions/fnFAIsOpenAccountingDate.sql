
CREATE FUNCTION [dbo].fnFAIsOpenAccountingDate(@dtmDate DATETIME)
RETURNS BIT 
AS
BEGIN
DECLARE @isOpen BIT = 0 
SELECT @isOpen = ISNULL(ysnOpen,0) & ISNULL(ysnFAOpen,0)
FROM dbo.tblGLFiscalYearPeriod 
WHERE @dtmDate BETWEEN dtmStartDate AND dtmEndDate		
RETURN @isOpen

END