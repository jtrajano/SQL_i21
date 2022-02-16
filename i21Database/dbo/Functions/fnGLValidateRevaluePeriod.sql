CREATE FUNCTION fnGLValidateRevaluePeriod(@intConsolidationId INT, @ysnPost BIT )
RETURNS NVARCHAR(MAX)
AS 
BEGIN
    DECLARE @errTable TABLE(errorCode INT, strModule NVARCHAR(50) COLLATE Latin1_General_CI_AS, strStatus NVARCHAR(10) COLLATE Latin1_General_CI_AS)
    DECLARE @intGLFiscalYearPeriodId INT, @intGLFiscalYearPeriodIdReverse INT , @dtmReverseDate DATETIME, @strTransactionType NVARCHAR(4)

    SELECT TOP 1 @intGLFiscalYearPeriodId= intGLFiscalYearPeriodId, @dtmReverseDate = dtmReverseDate,@strTransactionType = strTransactionType FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId
    SELECT TOP 1 @intGLFiscalYearPeriodIdReverse = intGLFiscalYearPeriodId  FROM tblGLFiscalYearPeriod WHERE dtmStartDate = @dtmReverseDate
    --dont post if period is closed
    IF @ysnPost = 1
    BEGIN
        INSERT INTO @errTable
        SELECT 60011,'Accounts Receivable' ,'open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AR' OR @strTransactionType = 'All')) AND ysnAROpen = 1 UNION ALL
        SELECT 60011,'Accounts Payable', 'open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AP' OR @strTransactionType = 'All')) AND ysnAPOpen = 1 UNION ALL
        SELECT 60011,'Inventory', 'open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'INV' OR @strTransactionType = 'All')) AND ysnINVOpen = 1 UNION ALL
        SELECT 60011,'Contract','open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CT' OR @strTransactionType = 'All')) AND ysnCTOpen = 1 UNION ALL
        SELECT 60011,'Cash Account','open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CM' OR @strTransactionType = 'All')) AND ysnCMOpen = 1 UNION ALL
        SELECT 60011,'Fixed Assets','open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'FA' OR @strTransactionType = 'All')) AND ysnFAOpen = 1 UNION ALL
        SELECT 60011,'General Ledger','open' from tblGLFiscalYearPeriod WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'GL' OR @strTransactionType = 'All')) AND ysnOpen = 1
        -- dont post if period is already revalued
        IF EXISTS (SELECT 1 FROM @errTable)
        GOTO _end

        INSERT INTO @errTable
        SELECT 60011, 'Accounts Receivable','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AR' OR @strTransactionType = 'All') AND ysnARRevalued = 1 UNION ALL
        SELECT 60011, 'Accounts Payable','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AP' OR @strTransactionType = 'All') AND ysnAPRevalued = 1 UNION ALL
        SELECT 60011, 'Inventory','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'INV'OR @strTransactionType = 'All') AND ysnINVRevalued = 1 UNION ALL
        SELECT 60011, 'Contract','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CT' OR @strTransactionType = 'All') AND ysnCTRevalued = 1 UNION ALL
        SELECT 60011, 'Cash Account','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CM' OR @strTransactionType = 'All') AND ysnCMRevalued = 1 UNION ALL
        SELECT 60011, 'Fixed Assets','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'FA' OR @strTransactionType = 'All') AND ysnFARevalued = 1  UNION ALL
        SELECT 60011, 'General Ledger','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'GL' OR @strTransactionType = 'All') AND ysnRevalued = 1
    END
    ELSE
    BEGIN
        INSERT INTO @errTable
        SELECT 60011, 'Accounts Receivable','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AR' OR @strTransactionType = 'All') AND ISNULL(ysnARRevalued,0) = 0 UNION ALL
        SELECT 60011, 'Accounts Payable','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'AP' OR @strTransactionType = 'All') AND ISNULL(ysnAPRevalued,0) = 0 UNION ALL
        SELECT 60011, 'Inventory','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'INV'OR @strTransactionType = 'All') AND ISNULL(ysnINVRevalued,0) = 0 UNION ALL
        SELECT 60011, 'Contract','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CT' OR @strTransactionType = 'All') AND ISNULL(ysnCTRevalued,0) = 0 UNION ALL
        SELECT 60011, 'Cash Account','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'CM' OR @strTransactionType = 'All') AND ISNULL(ysnCMRevalued,0) = 0 UNION ALL
        SELECT 60011, 'Fixed Assets','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'FA' OR @strTransactionType = 'All') AND ISNULL(ysnFARevalued,0) = 0 UNION
        SELECT 60011, 'General Ledger','revalued' from tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId AND (@strTransactionType = 'GL' OR @strTransactionType = 'All') AND ISNULL(ysnRevalued,0) = 0
    END

    IF EXISTS (SELECT 1 FROM @errTable)
        GOTO _end
        -- dont post/unpost if reverse period is closed
    INSERT INTO @errTable
    SELECT 60012, 'Accounts Receivable','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'AR' OR @strTransactionType = 'All')) AND ISNULL(ysnAROpen,0) = 0 UNION ALL
    SELECT 60012, 'Accounts Payable','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'AP' OR @strTransactionType = 'All')) AND ISNULL(ysnAPOpen,0) = 0 UNION ALL
    SELECT 60012, 'Inventory','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'INV'OR @strTransactionType = 'All')) AND ISNULL(ysnINVOpen,0) = 0 UNION ALL
    SELECT 60012, 'Contract','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'CT' OR @strTransactionType = 'All')) AND ISNULL(ysnCTOpen,0) = 0 UNION ALL
    SELECT 60012, 'Cash Account','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'CM' OR @strTransactionType = 'All')) AND ISNULL(ysnCMOpen,0) = 0 UNION ALL
    SELECT 60012, 'Fixed Assets','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'FA' OR @strTransactionType = 'All')) AND ISNULL(ysnFAOpen,0) = 0 UNION ALL
    SELECT 60012, 'General Ledger','closed' from tblGLFiscalYearPeriod B WHERE (intGLFiscalYearPeriodId = @intGLFiscalYearPeriodIdReverse AND (@strTransactionType = 'GL' OR @strTransactionType = 'All')) AND ISNULL(ysnOpen,0) = 0
    
    _end:

    DECLARE @tbl TABLE(id int IDENTITY(1,1), strError NVARCHAR(MAX))
    INSERT INTO @tbl(strError)
    SELECT REPLACE(REPLACE(strMessage,'{0}',strModule), '{1}',strStatus) FROM @errTable A
	JOIN  dbo.[fnGLGetGLEntriesErrorMessage]() B ON A.errorCode = B.intErrorCode


    DECLARE @str NVARCHAR(MAX) = '', @strError NVARCHAR(200)
    DECLARE @i int

    WHILE EXISTS (SELECT 1 FROM @tbl)
    BEGIN
        SELECT TOP 1 @i = id, @strError = strError FROM @tbl
        SET @str += '<li>' + @strError + '</li>'

        DELETE FROM @tbl WHERE id = @i
    END

    IF @str <> ''
        SET @str = '<ul>' + @str + '</ul>'


    RETURN @str
END

