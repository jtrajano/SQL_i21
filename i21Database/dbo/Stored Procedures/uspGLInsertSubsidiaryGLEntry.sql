CREATE PROCEDURE uspGLInsertSubsidiaryGLEntry
AS

DECLARE @tbl TABLE(
    strDatabase NVARCHAR(40),
    intLastGLDetailId INT NULL
)
DECLARE @strDatabase NVARCHAR(40)
DECLARE @intLastGLDetailId INT
DECLARE @tSQL NVARCHAR(MAX)

INSERT INTO @tbl
    SELECT strDatabase, intLastGLDetailId FROM tblGLSubsidiaryCompany

EXEC uspGLCreateSubsidiaryAccountMapping

WHILE EXISTS(SELECT TOP 1 1 FROM @tbl)
BEGIN
    SELECT TOP 1 @strDatabase=strDatabase,  @intLastGLDetailId =intLastGLDetailId FROM @tbl
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
    
    UPDATE tblGLSubsidiaryCompany SET intLastGLDetailId = @intMaxGLDetailID
    WHERE strDatabase = ''[dbname]''', '[dbname]', @strDatabase)

    IF @intLastGLDetailId IS NOT NULL
    SET @tSQL = @tSQL + ' AND intGLDetaiId > ' + CAST (@intLastGLDetailId AS NVARCHAR(20))


    DECLARE  @DBExec NVARCHAR(40)
	  
    SET @DBExec =  N'.sys.sp_executesql';

    EXEC @DBExec @tSQL;



    DELETE FROM @tbl WHERE strDatabase = @strDatabase
END

