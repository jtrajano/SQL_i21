CREATE VIEW vyuGLEliminate
AS
SELECT 
	 GLE.intEliminateId
	,GLE.intFiscalYearId
	,GLFY.strFiscalYear
	,GLE.intGLFiscalYearPeriodId
	,GLE.intLedgerId
	,GLL.strLedgerName
	,GLFYP.strPeriod
	,GLE.dtmPostDate
	,GLE.dtmReverseDate
	,GLE.intConcurrencyId
FROM tblGLEliminate GLE
INNER JOIN tblGLFiscalYearPeriod GLFYP ON GLE.intGLFiscalYearPeriodId = GLFYP.intGLFiscalYearPeriodId
INNER JOIN tblGLFiscalYear GLFY ON GLE.intFiscalYearId = GLFY.intFiscalYearId
INNER JOIN tblGLLedger GLL ON GLE.intLedgerId = GLL.intLedgerId
