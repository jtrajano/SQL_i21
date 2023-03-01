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

    BEGIN TRANSACTION;

    BEGIN TRY
	    DELETE [dbo].[tblGLAuditorTransaction] WHERE intGeneratedBy = @intEntityId AND intType = 1;
    
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
                , A.strLocationName strLocation
                , A.strCompanyLocation 
                , A.strSourceUOMId 
                , A.intSourceEntityId
                , A.strSourceEntity 
                , A.strSourceEntityNo 
                , A.strLOBSegmentDescription
                , A.strCurrency
                , A.strAccountId
            FROM  
			vyuGLDetail A 
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
               
            INTO #TransactionGroup 
            FROM #AuditorTransactions 
            GROUP BY intAccountId, strAccountId, intCurrencyId, strCurrency
            
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
                    @beginBalanceForeign NUMERIC(18,6) = 0
                    

                

                SELECT TOP 1 @intAccountId= intAccountId , @intCurrencyId = intCurrencyId, @strAccountId = strAccountId
                FROM #TransactionGroup 
                ORDER BY strAccountId, intCurrencyId

                IF @intAccountIdLoop <> @intAccountId
                    SELECT @beginBalance= beginBalance FROM dbo.fnGLGetBeginningBalanceAndUnit(@strAccountId,@dtmDateFrom)

                IF @intCurrencyIdLoop <> @intCurrencyId
                    SELECT @beginBalanceForeign= beginBalanceForeign FROM dbo.fnGLGetBeginningBalanceForeignCurrency(@strAccountId,@dtmDateFrom,@intCurrencyId)
                
                SELECT @beginBalance = ISNULL(@beginBalance ,0)
                SELECT @beginBalanceForeign = ISNULL(@beginBalanceForeign ,0);

                WITH CTE AS(
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
            

                SELECT @dblTotalDebit = sum(dblDebit), @dblTotalCredit= sum(dblCredit), @dblTotalDebitForeign = sum(dblDebitForeign), 
                @dblTotalCreditForeign = sum(dblCreditForeign)
                FROM #AuditorTransactions 
                WHERE @intAccountId =intAccountId 
                AND @intCurrencyId = intCurrencyId


                -- Total record
                INSERT INTO tblGLAuditorTransaction (
                    ysnGroupHeader
                    , intType
                    , intGeneratedBy      
                    , dtmDateGenerated
                    , strTotalTitle
                    , strGroupTitle
                    , intEntityId
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , strCurrency
                    , strAccountId
                    , intConcurrencyId
                )
                SELECT TOP 1
                    CAST(1 AS BIT)
                    , 0
                    , @intEntityId
                    , @dtmNow
                    , 'Total'
                    , 'Account ID: ' + strAccountId + ', Currency: ' + strCurrency
                    , @intEntityId
                    , @dblTotalDebit
                    , @dblTotalCredit
                    , @dblTotalDebitForeign
                    , @dblTotalCreditForeign                   
                    , strCurrency
                    , strAccountId
                    , 1
                    FROM #TransactionGroup 
                    WHERE intAccountId = @intAccountId
                    AND @intCurrencyId = intCurrencyId
            

                DELETE #TransactionGroup WHERE @intAccountId = intAccountId AND @intCurrencyId = intCurrencyId
            END
        END
    END TRY
    BEGIN CATCH
        SET @strError = @@ERROR
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