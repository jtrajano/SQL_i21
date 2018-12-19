CREATE VIEW [dbo].[vyuGLFiscalYearPeriod]
AS

SELECT A.[intGLFiscalYearPeriodId]
	,A.[intFiscalYearId]
	,A.[strPeriod] COLLATE Latin1_General_CI_AS strPeriod
	,A.[dtmStartDate]
	,A.[dtmEndDate]
	,A.[ysnOpen]
	,A.[intConcurrencyId]
	,B.[strFiscalYear] COLLATE Latin1_General_CI_AS strFiscalYear
FROM tblGLFiscalYearPeriod A
INNER JOIN tblGLFiscalYear B
ON A.intFiscalYearId = B.intFiscalYearId