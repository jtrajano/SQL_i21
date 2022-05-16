CREATE VIEW [dbo].[vyuAPReserve]
AS
SELECT
	 [intReserveId]
	,APR.[intFiscalYearId]
	,GLFY.[strFiscalYear]
	,APR.[intGLFiscalYearPeriodId]
	,GLFYP.[strPeriod]
	,APR.[intReserveAccountId]
	,strReserveAccountId			= GLAR.[strAccountId]
	,APR.[intExpenseAccountId]
	,strExpenseAccountId			= GLAE.[strAccountId]
	,[dtmPostDate]
	,[dblReserveBucket30Percentage]
	,[dblReserveBucket60Percentage]
	,[dblReserveBucket90Percentage]
	,[dblReserveBucket120Percentage]
	,APR.intConcurrencyId
FROM tblAPReserve APR
LEFT JOIN tblGLFiscalYearPeriod GLFYP ON APR.intGLFiscalYearPeriodId = GLFYP.intGLFiscalYearPeriodId
LEFT JOIN tblGLFiscalYear GLFY ON APR.intFiscalYearId = GLFY.intFiscalYearId
LEFT JOIN tblGLAccount GLAR ON APR.intReserveAccountId = GLAR.intAccountId
LEFT JOIN tblGLAccount GLAE ON APR.intExpenseAccountId = GLAE.intAccountId