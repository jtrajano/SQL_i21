CREATE VIEW [dbo].[vyuARReserve]
AS
SELECT
	 [intReserveId]
	,ARR.[intFiscalYearId]
	,GLFY.[strFiscalYear]
	,ARR.[intGLFiscalYearPeriodId]
	,GLFYP.[strPeriod]
	,ARR.[intReserveAccountId]
	,strReserveAccountId			= GLAR.[strAccountId]
	,ARR.[intExpenseAccountId]
	,strExpenseAccountId			= GLAE.[strAccountId]
	,[dtmPostDate]
	,[dblReserveBucket30Percentage]
	,[dblReserveBucket60Percentage]
	,[dblReserveBucket90Percentage]
	,[dblReserveBucket120Percentage]
	,ARR.intConcurrencyId
FROM tblARReserve ARR
LEFT JOIN tblGLFiscalYearPeriod GLFYP ON ARR.intGLFiscalYearPeriodId = GLFYP.intGLFiscalYearPeriodId
LEFT JOIN tblGLFiscalYear GLFY ON ARR.intFiscalYearId = GLFY.intFiscalYearId
LEFT JOIN tblGLAccount GLAR ON ARR.intReserveAccountId = GLAR.intAccountId
LEFT JOIN tblGLAccount GLAE ON ARR.intExpenseAccountId = GLAE.intAccountId