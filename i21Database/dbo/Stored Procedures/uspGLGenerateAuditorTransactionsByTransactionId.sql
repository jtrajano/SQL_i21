CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByTransactionId]
	@intEntityId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
    @strFilterDate NVARCHAR(20) = 'DatePosted',
    @intLocationSegmentId INT = 0
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_NULLS ON;
	SET NOCOUNT ON;

    DECLARE @strError NVARCHAR(MAX)

    DELETE [dbo].[tblGLAuditorTransaction] WHERE intGeneratedBy = @intEntityId AND intType = 1;

    BEGIN TRANSACTION;

    BEGIN TRY
	    
        IF OBJECT_ID('tempdb..#AuditorTransactions') IS NOT NULL
            DROP TABLE #AuditorTransactions

        ;WITH T AS (
           SELECT
                A.intEntityId
                , A.strBatchId
                , A.intAccountId
                , A.strTransactionId
                , A.intTransactionId
                , A.intCurrencyId
                , A.dtmDate
                , A.dtmDateEntered
                , dblDebit = ISNULL(A.dblDebit, 0)
                , dblCredit = ISNULL(A.dblCredit, 0)
                , dblDebitForeign = ISNULL(A.dblDebitForeign, 0)
                , dblCreditForeign = ISNULL(A.dblCreditForeign, 0)
                , A.strPeriod 
                , A.strDescription
                , A.strAccountDescription
                , A.strCode
                , A.strReference
                , A.strComments
                , A.strJournalLineDescription
                , A.strUOMCode 
                , A.strTransactionType 
                , A.strModuleName 
                , A.strTransactionForm 
                , A.strDocument
                , A.dblExchangeRate
                , A.strStatus 
                , A.dblDebitReport
                , A.dblCreditReport
                , A.dblSourceUnitDebit
                , A.dblSourceUnitCredit
                , A.dblDebitUnit
                , A.dblCreditUnit
                , A.strCommodityCode 
                , A.strSourceDocumentId
                , strLocation = LOC.strCode
                , A.strCompanyLocation 
                , A.strSourceUOMId 
                , A.intSourceEntityId
                , A.strSourceEntity 
                , A.strSourceEntityNo 
                , strLOBSegmentDescription = LOB.strCode
                , A.strCurrency
                , A.strAccountId
            FROM  
			vyuGLDetail A 
            outer apply dbo.fnGLGetSegmentAccount(A.intAccountId, 3)LOC
			outer apply dbo.fnGLGetSegmentAccount(A.intAccountId, 5)LOB
            WHERE 
                A.ysnIsUnposted = 0 AND CASE WHEN @strFilterDate = 'DatePosted' THEN A.dtmDate ELSE A.dtmDateEntered END
                BETWEEN @dtmDateFrom AND @dtmDateTo
            AND  CASE WHEN @intLocationSegmentId = 0 THEN  intLocationSegmentId  ELSE @intLocationSegmentId END = intLocationSegmentId
        )
        SELECT * INTO #AuditorTransactions FROM T ORDER BY T.strTransactionId, CASE WHEN @strFilterDate = 'DatePosted' THEN T.dtmDate ELSE T.dtmDateEntered END

        DECLARE @dtmNow DATETIME = GETDATE()

        IF OBJECT_ID('tempdb..#TransactionGroup') IS NOT NULL
            DROP TABLE #TransactionGroup

        IF EXISTS(SELECT TOP 1 1 FROM #AuditorTransactions)
        BEGIN
            SELECT 
                strTransactionId
                , dblDebit = SUM(ISNULL(dblDebit, 0))
                , dblCredit = SUM(ISNULL(dblCredit, 0))
                , dblDebitUnit = SUM(ISNULL(dblDebitUnit, 0))
                , dblCreditUnit = SUM(ISNULL(dblCreditUnit, 0))
                , dblSourceUnitDebit = SUM(ISNULL(dblSourceUnitDebit,0))
                , dblSourceUnitCredit = SUM(ISNULL(dblSourceUnitCredit,0))
                , dblDebitForeign = SUM(ISNULL(dblDebitForeign, 0))
                , dblCreditForeign = SUM(ISNULL(dblCreditForeign, 0))
                , dblAmount = (SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0)))
                , dblAmountForeign = (SUM(ISNULL(dblDebitForeign, 0)) - SUM(ISNULL(dblCreditForeign, 0)))
            INTO #TransactionGroup 
            FROM #AuditorTransactions 
            GROUP BY strTransactionId

            WHILE EXISTS(SELECT TOP 1 1 FROM #TransactionGroup)
            BEGIN
                DECLARE 
                    @strTransactionId NVARCHAR(40) = '',
                    @dblAmount NUMERIC(18, 6) = 0,
                    @dblAmountForeign NUMERIC(18, 6) = 0

                SELECT TOP 1 @strTransactionId = strTransactionId
                FROM #TransactionGroup 
                ORDER BY strTransactionId

                INSERT INTO tblGLAuditorTransaction (
                    ysnGroupHeader
                    , intType
                    , intGeneratedBy
                    , dtmDateGenerated
                    , intEntityId
                    , strBatchId
                    , intAccountId
                    , strTransactionId
                    , intTransactionId
                    , intCurrencyId
                    , dtmDate
                    , dtmDateEntered
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , strPeriod 
                    , strDescription
                    , strAccountDescription
                    , strCode
                    , strReference
                    , strComments
                    , strJournalLineDescription
                    , strUOMCode 
                    , strTransactionType 
                    , strModuleName 
                    , strTransactionForm 
                    , strDocument
                    , dblExchangeRate
                    , strStatus 
                    , dblDebitReport
                    , dblCreditReport
                    , dblSourceUnitDebit
                    , dblSourceUnitCredit
                    , dblDebitUnit
                    , dblCreditUnit
                    , strCommodityCode 
                    , strSourceDocumentId
                    , strLocation
                    , strCompanyLocation 
                    , strSourceUOMId 
                    , intSourceEntityId
                    , strSourceEntity 
                    , strSourceEntityNo 
                    , strLOBSegmentDescription
                    , strCurrency
                    , strAccountId
                )
                SELECT 
                    0
                    ,1 -- By TransactionId, 0 - by AccountId
                    , @intEntityId
                    , @dtmNow
                    , intEntityId
                    , strBatchId
                    , intAccountId
                    , strTransactionId
                    , intTransactionId
                    , intCurrencyId
                    , dtmDate
                    , dtmDateEntered
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , strPeriod 
                    , strDescription
                    , strAccountDescription
                    , strCode
                    , strReference
                    , strComments
                    , strJournalLineDescription
                    , strUOMCode 
                    , strTransactionType 
                    , strModuleName 
                    , strTransactionForm 
                    , strDocument
                    , dblExchangeRate
                    , strStatus 
                    , dblDebitReport
                    , dblCreditReport
                    , dblSourceUnitDebit
                    , dblSourceUnitCredit
                    , dblDebitUnit
                    , dblCreditUnit
                    , strCommodityCode 
                    , strSourceDocumentId
                    , strLocation
                    , strCompanyLocation 
                    , strSourceUOMId 
                    , intSourceEntityId
                    , strSourceEntity 
                    , strSourceEntityNo 
                    , strLOBSegmentDescription
                    , strCurrency
                    , strAccountId
                FROM #AuditorTransactions 
                WHERE @strTransactionId =strTransactionId 
                ORDER BY CASE WHEN @strFilterDate = 'DatePosted' THEN   dtmDate ELSE dtmDateEntered  END

                -- Total record
                INSERT INTO tblGLAuditorTransaction (
                    ysnGroupHeader
                    , intType
                    , intGeneratedBy      
                    , dtmDateGenerated
                    , strTransactionId
                    , strTotalTitle
                    , strGroupTitle
                    , intEntityId
                    , dblDebit
                    , dblCredit
                    , dblDebitUnit
                    , dblCreditUnit
                    , dblSourceUnitDebit
                    , dblSourceUnitCredit 
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblTotal
                    , dblTotalForeign
                )
                SELECT TOP 1
                    1
                    ,1
                    , @intEntityId
                    , @dtmNow
                    , @strTransactionId
                    , 'Total'
                    , 'Transaction ID: ' + @strTransactionId 
                    , @intEntityId
                    , dblDebit
                    , dblCredit
                    , dblDebitUnit
                    , dblCreditUnit
                    , dblSourceUnitDebit
                    , dblSourceUnitCredit 
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblAmount
                    , dblAmountForeign
                    FROM #TransactionGroup 
                    WHERE strTransactionId = @strTransactionId
                DELETE #TransactionGroup WHERE @strTransactionId = strTransactionId
            END


        END

        SELECT 
        SUM(dblDebit) dblTotalDebitSummary,
        SUM(dblCredit) dblTotalCreditSummary,
        SUM(dblDebitUnit) dblTotalDebitUnitSummary,
        SUM(dblCreditUnit) dblTotalCreditUnitSummary
        FROM #AuditorTransactions

    END TRY
    BEGIN CATCH
        SET @strError = ERROR_MESSAGE()
        GOTO ROLLBACK_TRANSACTION;
    END CATCH

    POST_TRANSACTION:
        COMMIT TRANSACTION;
        GOTO EXIT_TRANSACTION;

    ROLLBACK_TRANSACTION:
        RAISERROR(@strError, 16, 1);
        ROLLBACK TRANSACTION;
        GOTO EXIT_TRANSACTION;

    EXIT_TRANSACTION:
END