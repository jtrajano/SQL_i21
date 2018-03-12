CREATE PROCEDURE [dbo].[uspFRDBudgetSummary]
	@intBudgetCode		AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

	DELETE tblFRBudgetSummary WHERE intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget1, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod1) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod1) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget2, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod2) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod2) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget3, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod3) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod3) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget4, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod4) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod4) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget5, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod5) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod5) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget6, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod6) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod6) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget7, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod7) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod7) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget8, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod8) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod8) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget9, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod9) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod9) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget10, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod10) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod10) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget11, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod11) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod11) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget12, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod12) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod12) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode

	INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
	SELECT intBudgetCode, 
		   intBudgetId, 
		   intAccountId, 
		   dblBudget13, 
		   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod13) as dtmStartDate,  
		   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod13) as dtmEndDate
	FROM tblFRBudget where intBudgetCode = @intBudgetCode and intPeriod13 IS NOT NULL


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDBudgetSummary] 111
