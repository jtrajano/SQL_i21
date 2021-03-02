CREATE PROCEDURE uspGLInsertSubsidiaryGLEntry
    @ysnClear BIT = DEFAULT
AS

DECLARE @tbl TABLE(
    strDatabase NVARCHAR(40), intLastGLDetailId INT
)
DECLARE @strDatabase NVARCHAR(40)
DECLARE @intLastGLDetailId INT
DECLARE @tSQL NVARCHAR(MAX)
SET XACT_ABORT ON

    IF @ysnClear = 1
    BEGIN
        DELETE FROM tblGLDetail
        UPDATE tblGLSubsidiaryCompany SET intLastGLDetailId = NULL
    END

    IF EXISTS(SELECT 1 FROM tblGLSubsidiaryCompany WHERE ISNULL(ysnMergedCOA,0) = 0)
	BEGIN
		RAISERROR ('There are Chart of account from subsidiary  that are not yet merged', 16,1)
		RETURN
	END


    INSERT INTO @tbl
        SELECT strDatabase, intLastGLDetailId FROM tblGLSubsidiaryCompany


    EXEC uspGLCreateSubsidiaryAccountMapping

    WHILE EXISTS(SELECT TOP 1 1 FROM @tbl)
    BEGIN
        SELECT TOP 1 @strDatabase=strDatabase ,@intLastGLDetailId = intLastGLDetailId  FROM @tbl
        SET @tSQL =
        REPLACE(
        '
        DECLARE @intMaxGLDetailID INT
        SELECT @intMaxGLDetailID = MAX(intGLDetailId) from  [dbname].dbo.tblGLDetail 
        INSERT INTO tblGLDetail (
        dtmDate,  
        strBatchId,  
        intAccountId,  
        dblDebit,  
        dblCredit,  
        dblDebitUnit,  
        dblCreditUnit,  
        strDescription,  
        strCode,  
        strReference,  
        intCurrencyId,  
        intCurrencyExchangeRateTypeId,  
        dblExchangeRate,  
        dtmDateEntered,  
        dtmDateEnteredMin,  
        dtmTransactionDate,  
        strJournalLineDescription,  
        intJournalLineNo,  
        ysnIsUnposted,  
        ysnPostAction,  
        intUserId,  
        intEntityId,  
        strTransactionId,  
        intTransactionId,  
        strTransactionType,  
        strTransactionForm,  
        strModuleName,  
        intConcurrencyId,  
        dblDebitForeign,  
        dblDebitReport,  
        dblCreditForeign,  
        dblCreditReport,  
        dblReportingRate,  
        dblForeignRate,  
        intReconciledId,  
        dtmReconciled,  
        ysnReconciled,  
        ysnRevalued,  
        strSourceDocumentId,  
        intSourceLocationId,  
        intSourceUOMId,  
        dblSourceUnitDebit,  
        dblSourceUnitCredit,  
        intCommodityId,  
        intSourceEntityId,  
        strDocument,  
        strComments
        )
    SELECT 
        dtmDate,  
        strBatchId,  
        A.intAccountId,  -- account id from consolidating company
        dblDebit,  
        dblCredit,  
        dblDebitUnit,  
        dblCreditUnit,  
        D.strDescription,  
        strCode,  
        strReference,  
        intCurrencyId,  
        D.intCurrencyExchangeRateTypeId,  
        dblExchangeRate,  
        dtmDateEntered,  
        dtmDateEnteredMin,  
        dtmTransactionDate,  
        strJournalLineDescription,  
        intJournalLineNo,  
        ysnIsUnposted,  
        ysnPostAction,  
        intUserId,  
        intEntityId,  
        strTransactionId,  
        intTransactionId,  
        strTransactionType,  
        strTransactionForm,  
        strModuleName,  
        D.intConcurrencyId,  
        dblDebitForeign,  
        dblDebitReport,  
        dblCreditForeign,  
        dblCreditReport,  
        dblReportingRate,  
        dblForeignRate,  
        intReconciledId,  
        dtmReconciled,  
        ysnReconciled,  
        ysnRevalued,  
        strSourceDocumentId,  
        intSourceLocationId,  
        intSourceUOMId,  
        dblSourceUnitDebit,  
        dblSourceUnitCredit,  
        intCommodityId,  
        intSourceEntityId,  
        strDocument,  
        D.strComments
        FROM [dbname].dbo.tblGLDetail D 

        JOIN tblGLSubsidiaryAccountMapping M on M.intAccountId = D.intAccountId and M.strDatabase = ''[dbname]''
        JOIN tblGLAccount A on A.strAccountId = M.strAccountId
        WHERE ysnIsUnposted = 0
        AND intGLDetailId > [LastGLDetailId]

        UPDATE tblGLSubsidiaryCompany SET intLastGLDetailId = @intMaxGLDetailID
        WHERE strDatabase = ''[dbname]''
        ', '[dbname]', @strDatabase)
        SET @tSQL = REPLACE(@tSQL , '[LastGLDetailId]', CAST(ISNULL(@intLastGLDetailId,0) AS NVARCHAR(10)))
        DECLARE  @DBExec NVARCHAR(40)
        SET @DBExec =  N'.sys.sp_executesql';
        EXEC @DBExec @tSQL;
        DELETE FROM @tbl WHERE strDatabase = @strDatabase
    END

    EXEC uspGLSummaryRecalculate