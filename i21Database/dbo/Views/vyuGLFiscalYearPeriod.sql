CREATE VIEW [dbo].[vyuGLFiscalYearPeriod]
AS

SELECT A.[intGLFiscalYearPeriodId]
	,A.[intFiscalYearId]
	,A.[strPeriod]
	,A.[dtmStartDate]
	,A.[dtmEndDate]
	,A.[ysnOpen]
	,A.[intConcurrencyId]
	,B.[strFiscalYear]

FROM tblGLFiscalYearPeriod A
INNER JOIN tblGLFiscalYear B
ON A.intFiscalYearId = B.intFiscalYearId