CREATE VIEW [dbo].[vyuGLFiscalYearPeriod]
AS
SELECT 
	A.*
	, B.[strFiscalYear]
	, dtmEndDateMDY = CONVERT(NVARCHAR(20), A.[dtmEndDate], 101)
	, ysnCurrent = CASE WHEN GETDATE() BETWEEN A.dtmStartDate AND dtmEndDate THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM tblGLFiscalYearPeriod A
INNER JOIN tblGLFiscalYear B
ON A.intFiscalYearId = B.intFiscalYearId