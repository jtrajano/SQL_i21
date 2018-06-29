CREATE PROCEDURE [dbo].[uspFRDBudgetMaintenance]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

	UPDATE tblFRBudget SET intPeriod1 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 1)
											WHERE intPeriod1 IS NULL

	UPDATE tblFRBudget SET intPeriod2 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 2)
											WHERE intPeriod2 IS NULL

	UPDATE tblFRBudget SET intPeriod3 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 3)
											WHERE intPeriod3 IS NULL

	UPDATE tblFRBudget SET intPeriod4 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 4)
											WHERE intPeriod4 IS NULL

	UPDATE tblFRBudget SET intPeriod5 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 5)
											WHERE intPeriod5 IS NULL

	UPDATE tblFRBudget SET intPeriod6 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 6)
											WHERE intPeriod6 IS NULL

	UPDATE tblFRBudget SET intPeriod7 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 7)
											WHERE intPeriod7 IS NULL

	UPDATE tblFRBudget SET intPeriod8 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 8)
											WHERE intPeriod8 IS NULL

	UPDATE tblFRBudget SET intPeriod9 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 9)
											WHERE intPeriod9 IS NULL

	UPDATE tblFRBudget SET intPeriod10 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 10)
											WHERE intPeriod10 IS NULL

	UPDATE tblFRBudget SET intPeriod11 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 11)
											WHERE intPeriod11 IS NULL

	UPDATE tblFRBudget SET intPeriod12 = (SELECT intGLFiscalYearPeriodId FROM 
											(select ROW_NUMBER() OVER (order by intGLFiscalYearPeriodId ASC) as ROWNUMBER, intGLFiscalYearPeriodId from tblGLFiscalYearPeriod 
														WHERE intFiscalYearId = (select intFiscalYearId from tblFRBudgetCode where intBudgetCode = tblFRBudget.intBudgetCode)) TBL WHERE ROWNUMBER = 12)
											WHERE intPeriod12 IS NULL

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDBudgetMaintenance]
