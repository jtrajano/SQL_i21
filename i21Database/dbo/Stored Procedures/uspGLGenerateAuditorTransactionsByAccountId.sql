CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByAccountId]
	@intEntityId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_NULLS ON;
	SET NOCOUNT ON;

    DECLARE @strError NVARCHAR(MAX)
    DELETE [dbo].[tblGLAuditorTransaction] WHERE intGeneratedBy = @intEntityId AND intType = 0;

    BEGIN TRANSACTION;

    BEGIN TRY

        IF OBJECT_ID('tempdb..#AuditorTransactions') IS NOT NULL
            DROP TABLE #AuditorTransactions

        ;WITH T AS (
           SELECT
                A.intGLDetailId
                , A.intEntityId
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
                A.ysnIsUnposted = 0 AND A.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
       
        )
        SELECT * INTO #AuditorTransactions FROM T ORDER BY T.strAccountId, T.intCurrencyId, T.dtmDate, T.intGLDetailId

        DECLARE @dtmNow DATETIME = GETDATE()

        IF OBJECT_ID('tempdb..#TransactionGroup') IS NOT NULL
            DROP TABLE #TransactionGroup

        IF EXISTS(SELECT TOP 1 1 FROM #AuditorTransactions)
        BEGIN
            SELECT 
                intAccountId
                , strAccountId
                , strCurrency
                , intCurrencyId
                , strLOBSegmentDescription
                , strLocation
                , strAccountDescription
               
            INTO #TransactionGroup 
            FROM #AuditorTransactions 
            GROUP BY intAccountId, strAccountId, intCurrencyId, strCurrency
            ,strLOBSegmentDescription,strLocation, strAccountDescription
            
            DECLARE @intAccountIdLoop INT = 0
            DECLARE @intCurrencyIdLoop INT = 0
            DECLARE @intAccountId INT
            DECLARE @intCurrencyId INT
            DECLARE @strAccountId NVARCHAR(50)
            DECLARE @dblTotalDebit NUMERIC(18,6)
            DECLARE @dblTotalCredit NUMERIC(18,6)
            DECLARE @dblTotalDebitForeign NUMERIC(18,6)
            DECLARE @dblTotalCreditForeign NUMERIC(18,6)

            WHILE EXISTS(SELECT TOP 1 1 FROM #TransactionGroup)
            BEGIN
                DECLARE 
                    @beginBalance NUMERIC(18,6) = 0,
                    @beginBalanceForeign NUMERIC(18,6) = 0,
                    @beginBalanceDebit NUMERIC(18,6) = 0,
                    @beginBalanceCredit NUMERIC(18,6) = 0,
                    @beginBalanceDebitForeign NUMERIC(18,6) = 0,
                    @beginBalanceCreditForeign NUMERIC(18,6) = 0

                SELECT TOP 1 @intAccountId= intAccountId , @intCurrencyId = intCurrencyId, @strAccountId = strAccountId
                FROM #TransactionGroup 
                ORDER BY strAccountId, intCurrencyId

                IF @intAccountIdLoop <> @intAccountId
                BEGIN
                    SET @intAccountIdLoop  = @intAccountId

                    SELECT
                    @beginBalance=          ISNULL(beginBalance,0),
                    @beginBalanceDebit=     ISNULL(beginBalanceDebit,0),
                    @beginBalanceCredit=    ISNULL(beginBalanceCredit,0)
                    FROM dbo.fnGLGetBeginningBalanceAuditorReport(@strAccountId,@dtmDateFrom)

                    SELECT
                    @beginBalanceForeign=       ISNULL(beginBalanceForeign,0),
                    @beginBalanceDebitForeign=  ISNULL(beginBalanceDebitForeign,0),
                    @beginBalanceCreditForeign= ISNULL(beginBalanceCreditForeign,0)
                    FROM dbo.fnGLGetBeginningBalanceAuditorReportForeign(@strAccountId,@dtmDateFrom,@intCurrencyId)

                        -- Total record
                    INSERT INTO tblGLAuditorTransaction (
                        ysnGroupFooter
                        ,ysnGroupHeader
                        , intType
                        , intGeneratedBy      
                        , dtmDateGenerated
                        , strTotalTitle
                        , strGroupTitle
                        , intEntityId
                        , dblDebit
                        , dblCredit
                        , dblEndingBalance
                        , dblDebitForeign
                        , dblCreditForeign
                        , dblEndingBalanceForeign
                        , strCurrency
                        , strAccountId
                        , strLocation
                        , strLOBSegmentDescription
                        , strAccountDescription
                        , intConcurrencyId
                    )
                    SELECT TOP 1
                        CAST(0 AS BIT)
                        ,CAST(1 AS BIT)
                        , 0
                        , @intEntityId
                        , @dtmNow
                        , 'Beginning Balance'
                        , 'Account ID: ' + strAccountId + ', Currency: ' + strCurrency
                        , @intEntityId
                        , @beginBalanceDebit
                        , @beginBalanceCredit
                        , @beginBalance
                        , @beginBalanceDebitForeign
                        , @beginBalanceCreditForeign     
                        , @beginBalanceForeign            
                        , strCurrency
                        , strAccountId
                        , strLocation
                        , strLOBSegmentDescription
                        , strAccountDescription
                        , 1
                        FROM #TransactionGroup 
                        WHERE intAccountId = @intAccountId
                        AND @intCurrencyId = intCurrencyId
            

                END

                ELSE
                BEGIN
                    SELECT
                    @beginBalanceForeign=       ISNULL(beginBalanceForeign,0),
                    @beginBalanceDebitForeign=  ISNULL(beginBalanceDebitForeign,0),
                    @beginBalanceCreditForeign= ISNULL(beginBalanceCreditForeign,0)
                    FROM dbo.fnGLGetBeginningBalanceAuditorReportForeign(@strAccountId,@dtmDateFrom,@intCurrencyId)
                END

                -- IF @intCurrencyIdLoop <> @intCurrencyId
                --     SELECT
                --     @beginBalanceForeign=       ISNULL(beginBalanceForeign,0),
                --     @beginBalanceDebitForeign=  ISNULL(beginBalanceDebitForeign,0),
                --     @beginBalanceCreditForeign= ISNULL(beginBalanceCreditForeign,0)
                --     FROM dbo.fnGLGetBeginningBalanceAuditorReportForeign(@strAccountId,@dtmDateFrom,@intCurrencyId)
                
            

              

                ;WITH CTE AS(
                    SELECT 
                     intEntityId
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
                    , sum(dblDebit - dblCredit) OVER ( ORDER BY dtmDate, intGLDetailId)  + @beginBalance  dblEndingBalance
                    , sum(dblDebitForeign - dblCreditForeign) OVER ( ORDER BY dtmDate, intGLDetailId) + @beginBalanceForeign  dblEndingBalanceForeign
                    FROM #AuditorTransactions 
                    WHERE @intAccountId =intAccountId 
                    AND @intCurrencyId = intCurrencyId   

                ),
                CTEBB AS(

                    SELECT *,
                    dblEndingBalance - (dblDebit - dblCredit)  dblBeginningBalance ,
                    dblEndingBalanceForeign - (dblDebitForeign - dblCreditForeign) dblBeginningBalanceForeign
                    FROM 
                    CTE 

                )
                INSERT INTO tblGLAuditorTransaction (
                    ysnGroupHeader
                    ,intType
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
                    , dblBeginningBalance
                    , dblEndingBalance
                    , dblBeginningBalanceForeign
                    , dblEndingBalanceForeign
                )
                SELECT 
                    CAST(0 AS BIT)
                    , 0
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
                    , dblBeginningBalance
                    , dblEndingBalance
                    , dblBeginningBalanceForeign
                    , dblEndingBalanceForeign
                FROM CTEBB
            

                SELECT
                @dblTotalDebit = sum(dblDebit), @dblTotalCredit= sum(dblCredit), 
                @dblTotalDebitForeign = sum(dblDebitForeign), 
                @dblTotalCreditForeign = sum(dblCreditForeign)
                FROM #AuditorTransactions 
                WHERE @intAccountId =intAccountId 
                AND @intCurrencyId = intCurrencyId
             


                -- Total record
                INSERT INTO tblGLAuditorTransaction (
                    ysnGroupFooter
                    , ysnGroupHeader
                    , intType
                    , intGeneratedBy      
                    , dtmDateGenerated
                    , strTotalTitle
                    , strGroupTitle
                    , intEntityId
                    , dblBeginningBalance
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblBeginningBalanceForeign
                    , strCurrency
                    , strAccountId
                    , strLocation
                    , strLOBSegmentDescription
                    , strAccountDescription
                    , intConcurrencyId
                )
                SELECT TOP 1
                     CAST(1 AS BIT)
                    ,CAST(0 AS BIT)
                    , 0
                    , @intEntityId
                    , @dtmNow
                    , 'Total'
                    , 'Account ID: ' + strAccountId + ', Currency: ' + strCurrency
                    , @intEntityId
                    ,  @dblTotalDebit- @dblTotalCredit + @beginningBalance
                    , @dblTotalDebit
                    , @dblTotalCredit
                    , @dblTotalDebitForeign
                    , @dblTotalCreditForeign     
                    , @dblTotalDebitForeign- @dblTotalCreditForeign + @beginningBalanceForeign    
                    , strCurrency
                    , strAccountId
                    , strLocation
                    , strLOBSegmentDescription
                    , strAccountDescription
                    , 1
                    FROM #TransactionGroup 
                    WHERE intAccountId = @intAccountId
                    AND @intCurrencyId = intCurrencyId
            

                DELETE #TransactionGroup WHERE @intAccountId = intAccountId AND @intCurrencyId = intCurrencyId
            END
        END
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