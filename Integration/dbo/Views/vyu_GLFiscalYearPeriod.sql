CREATE VIEW [dbo].[vyu_GLFiscalYearPeriod]
AS

SELECT A.[intGLFiscalYearPeriodID]
	,A.[intFiscalYearID]
	,A.[strPeriod]
	,A.[dtmStartDate]
	,A.[dtmEndDate]
	,A.[ysnOpen]
	,A.[intConcurrencyId]
	,B.[strFiscalYear]

FROM tblGLFiscalYearPeriod A
INNER JOIN tblGLFiscalYear B
ON A.intFiscalYearID = B.intFiscalYearID