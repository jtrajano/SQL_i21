CREATE FUNCTION [dbo].[fnGLGetFiscalPeriod] (
	@dtmDate AS DATETIME
)
RETURNS TABLE 
AS 
RETURN 
SELECT TOP 1 intGLFiscalYearPeriodId, strPeriod FROM tblGLFiscalYearPeriod WHERE @dtmDate BETWEEN dtmStartDate AND dtmEndDate
