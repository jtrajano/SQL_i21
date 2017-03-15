CREATE FUNCTION fnGLValidateRevaluePeriod(@intConsolidationId INT)
RETURNS @errTable TABLE(errorCode INT, strModule NVARCHAR(50), strStatus NVARCHAR(10))
AS 

BEGIN
    DECLARE @intGLFiscalYearPeriodId INT, @intGLFiscalYearPeriodIdReverse INT , @dtmReverseDate DATETIME, @strTransactionType NVARCHAR(4)

    SELECT TOP 1 @intGLFiscalYearPeriodId= intGLFiscalYearPeriodId, @dtmReverseDate = dtmReverseDate,@strTransactionType = strTransactionType FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId
    SELECT TOP 1 @intGLFiscalYearPeriodIdReverse = intGLFiscalYearPeriodId  FROM tblGLFiscalYearPeriod WHERE dtmStartDate = @dtmReverseDate
    --dont post if period is closed
    INSERT INTO @errTable
    SELECT 60011,'Accounts Receivable' ,'open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AR' OR @strTransactionType = 'All')) AND ysnAROpen = 1 UNION ALL
    SELECT 60011,'Accounts Payable', 'open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AP' OR @strTransactionType = 'All')) AND ysnAPOpen = 1 UNION ALL
    SELECT 60011,'Inventory', 'open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'INV' OR @strTransactionType = 'All')) AND ysnINVOpen = 1 UNION ALL
    SELECT 60011,'Contract','open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CT' OR @strTransactionType = 'All')) AND ysnCTOpen = 1
    -- dont post if period is already revalued
    IF EXISTS (SELECT TOP 1 1 FROM @errTable) RETURN
    INSERT INTO @errTable
    SELECT 60011, 'Accounts Receivable','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AR' OR @strTransactionType = 'All') AND ysnARRevalued = 1 UNION ALL
    SELECT 60011, 'Accounts Payable','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AP' OR @strTransactionType = 'All') AND ysnAPRevalued = 1 UNION ALL
    SELECT 60011, 'Inventory','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'INV'OR @strTransactionType = 'All') AND ysnINVRevalued = 1 UNION ALL
    SELECT 60011, 'Contract','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CT' OR @strTransactionType = 'All') AND ysnCTRevalued = 1

    IF EXISTS (SELECT TOP 1 1 FROM @errTable) RETURN
    -- dont post if reverse period is closed
    INSERT INTO @errTable
    SELECT 60012, 'Accounts Receivable','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'AR' OR @strTransactionType = 'All')) AND ysnAROpen = 0 UNION ALL
    SELECT 60012, 'Accounts Payable','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'AP' OR @strTransactionType = 'All')) AND ysnAPOpen = 0 UNION ALL
    SELECT 60012, 'Inventory','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'INV'OR @strTransactionType = 'All')) AND ysnINVOpen = 0 UNION ALL
    SELECT 60012, 'Contract','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'CT' OR @strTransactionType = 'All')) AND ysnCTOpen = 0
    RETURN
END

