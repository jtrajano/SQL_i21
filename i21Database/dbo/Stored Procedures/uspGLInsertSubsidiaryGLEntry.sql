CREATE PROCEDURE uspGLInsertSubsidiaryGLEntry
    @ysnClear BIT = DEFAULT
AS

DECLARE @tbl TABLE(
    strDatabase NVARCHAR(40), intSubsidiaryCompanyId INT
)
DECLARE @strDatabase NVARCHAR(40)
DECLARE @intLastGLDetailId INT
DECLARE @intSubsidiaryCompanyId INT
DECLARE @tSQL NVARCHAR(MAX)
SET XACT_ABORT ON

    IF @ysnClear = 1
    BEGIN
        DELETE FROM tblGLDetail
    END

    IF EXISTS(SELECT 1 FROM tblGLSubsidiaryCompany WHERE ISNULL(ysnMergedCOA,0) = 0)
	BEGIN
		RAISERROR ('There are Chart of account from subsidiary  that are not yet merged', 16,1)
		RETURN
	END


    INSERT INTO @tbl (strDatabase, intSubsidiaryCompanyId)
        SELECT strDatabase,intSubsidiaryCompanyId FROM tblGLSubsidiaryCompany


    EXEC uspGLCreateSubsidiaryAccountMapping

    DECLARE @tblGLDetail TABLE (
    [intSubsidiaryGLDetailId]   INT              NOT NULL,
    [intSubsidiaryCompanyId]    INT              NOT NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]              INT              NOT NULL,
    [dblDebit] [numeric](18, 6) NULL,
    [dblCredit] [numeric](18, 6) NULL ,
    [dblDebitUnit] [numeric](18, 6) NULL,
    [dblCreditUnit] [numeric](18, 6) NULL,
    [strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
    [strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId]             INT              NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
    [dblExchangeRate]           NUMERIC (38, 20) NOT NULL,
    [dtmDateEntered]            DATETIME         NOT NULL,
    [dtmDateEnteredMin]         DATETIME         NULL,
    [dtmTransactionDate]        DATETIME         NULL,
    [strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
    [ysnIsUnposted]             BIT              NOT NULL,    
    [ysnPostAction]             BIT              NULL,    
    [intUserId]                 INT              NULL,
    [intEntityId]				INT              NULL,
    [strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL,
    [intTransactionId]          INT              NULL,
    [strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign] [numeric](18, 9) NULL,
    [dblDebitReport] [numeric](18, 9) NULL,
    [dblCreditForeign] [numeric](18, 9) NULL,
    [dblCreditReport] [numeric](18, 9) NULL ,
    [dblReportingRate] [numeric](18, 9) NULL,
    [dblForeignRate] NUMERIC(18, 9) NULL, 
    [intReconciledId] INT NULL, 
    [dtmReconciled] DATETIME NULL, 
    [ysnReconciled] BIT NULL, 
	[ysnRevalued] BIT NULL,
    -- new columns GL-3550
    [strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    intSourceLocationId INT NULL,
    intSourceUOMId INT NULL,
    dblSourceUnitDebit NUMERIC(18,9) NULL,
	dblSourceUnitCredit NUMERIC(18,9) NULL,
    intCommodityId INT NULL,
    intSourceEntityId INT NULL,
	-- new columns GL-3550	
	[strDocument] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strComments] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[intFiscalPeriodId] INT NULL
);

DECLARE @fiscalErrorMsg NVARCHAR(MAX)


    WHILE EXISTS(SELECT TOP 1 1 FROM @tbl)
    BEGIN
        SELECT TOP 1 @strDatabase=strDatabase , @intSubsidiaryCompanyId = intSubsidiaryCompanyId  FROM @tbl

        DECLARE @intMaxGLDetailID INT
        SELECT @intMaxGLDetailID = MAX(intSubsidiaryGLDetailId) from  tblGLDetail 
        WHERE intSubsidiaryCompanyId = @intSubsidiaryCompanyId

        SET @tSQL =
        REPLACE(
        'SELECT 
        intGLDetailId,
        [intSubsidiaryCompanyId],
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
        D.strComments,
        intFiscalPeriodId
        FROM [dbname].dbo.tblGLDetail D 
        JOIN tblGLSubsidiaryAccountMapping M on M.intAccountId = D.intAccountId and M.strDatabase = ''[dbname]''
        JOIN tblGLAccount A on A.strAccountId = M.strAccountId
        WHERE ysnIsUnposted = 0
        AND intGLDetailId > [LastGLDetailId]
        ', '[dbname]', @strDatabase)

        SET @tSQL = REPLACE(@tSQL , '[LastGLDetailId]', CAST(ISNULL(@intMaxGLDetailID,0) AS NVARCHAR(10)))
        SET @tSQL = REPLACE(@tSQL , '[intSubsidiaryCompanyId]', CAST(ISNULL(@intSubsidiaryCompanyId,0) AS NVARCHAR(10)))

        INSERT INTO @tblGLDetail EXEC (@tSQL)

        UPDATE @tblGLDetail SET intFiscalPeriodId = NULL

        UPDATE  T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId
        FROM @tblGLDetail T
        OUTER APPLY (
            SELECT intGLFiscalYearPeriodId FROM tblGLFiscalYearPeriod where dtmDate BETWEEN dtmStartDate AND dtmEndDate
        )F

        IF EXISTS (SELECT TOP 1 1 FROM  @tblGLDetail WHERE intFiscalPeriodId IS NULL AND intSubsidiaryCompanyId = @intSubsidiaryCompanyId)
        BEGIN
            SET @fiscalErrorMsg = 'There are dates from ' + @strDatabase +' company that have no fiscal period in the consolidating company'
            RAISERROR (@fiscalErrorMsg, 16,1 )
            RETURN
        END

        DELETE FROM @tbl WHERE intSubsidiaryCompanyId = @intSubsidiaryCompanyId
    END


     INSERT INTO tblGLDetail (
        intSubsidiaryGLDetailId,
        intSubsidiaryCompanyId,
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
        intSubsidiaryGLDetailId,
        intSubsidiaryCompanyId,
        dtmDate,  
        strBatchId,  
        intAccountId,  -- account id from consolidating company
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
        FROM @tblGLDetail
    
    EXEC uspGLSummaryRecalculate
    EXEC uspGLRecalcTrialBalance