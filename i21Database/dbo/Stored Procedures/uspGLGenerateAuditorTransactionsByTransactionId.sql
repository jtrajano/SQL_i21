﻿CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByTransactionId]
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
        SELECT * INTO #AuditorTransactions FROM T ORDER BY T.strTransactionId, T.dtmDate

        DECLARE @dtmNow DATETIME = GETDATE()

        IF OBJECT_ID('tempdb..#TransactionGroup') IS NOT NULL
            DROP TABLE #TransactionGroup

        IF EXISTS(SELECT TOP 1 1 FROM #AuditorTransactions)
        BEGIN
            SELECT 
                strTransactionId
                , intCurrencyId
                , strCurrency
                , dblDebit = SUM(ISNULL(dblDebit, 0))
                , dblCredit = SUM(ISNULL(dblCredit, 0))
                , dblDebitForeign = SUM(ISNULL(dblDebitForeign, 0))
                , dblCreditForeign = SUM(ISNULL(dblCreditForeign, 0))
                , dblAmount = (SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0)))
                , dblAmountForeign = (SUM(ISNULL(dblDebitForeign, 0)) - SUM(ISNULL(dblCreditForeign, 0)))
            INTO #TransactionGroup 
            FROM #AuditorTransactions 
            GROUP BY strTransactionId, intCurrencyId, strCurrency
            

            WHILE EXISTS(SELECT TOP 1 1 FROM #TransactionGroup)
            BEGIN
                DECLARE 
                    @strTransactionId NVARCHAR(40) = '',
                    @intCurrencyId INT = NULL,
                    @dblAmount NUMERIC(18, 6) = 0,
                    @dblAmountForeign NUMERIC(18, 6) = 0

                SELECT TOP 1 @strTransactionId = strTransactionId , @intCurrencyId = intCurrencyId
                FROM #TransactionGroup 
                ORDER BY strTransactionId, intCurrencyId

                INSERT INTO tblGLAuditorTransaction (
                    intType
                    , intGeneratedBy
                    , dtmDateGenerated
                    , intEntityId
                    , intAccountId
                    , intTransactionId
                    , strTransactionId
                    , dtmDate
                    , dtmDateEntered
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblExchangeRate
                    , intCurrencyId
                    , strBatchId
                    , strCode
                    , strTransactionType
                    , strTransactionForm
                    , strReference
                    , strDocument
                    , strComments
                    , strPeriod
                    , strDescription
                    , dblSourceUnitDebit
                    , dblSourceUnitCredit
                    , dblDebitReport
                    , dblCreditReport
                    , strCommodityCode
                    , strSourceDocumentId
                    , strLocation
                    , strCompanyLocation
                    , strJournalLineDescription
                    , strUOMCode
                    , strStatus
                    , intSourceEntityId
                    , strSourceEntity
                    , strSourceEntityNo
                    , strLOBSegmentDescription
                    , strCurrency
                    , strAccountId
                )
                SELECT 
                    1 -- By TransactionId, 0 - by AccountId
                    , @intEntityId
                    , @dtmNow
                    , intEntityId
                    , intAccountId
                    , intTransactionId
                    , strTransactionId
                    , dtmDate
                    , dtmDateEntered
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblExchangeRate
                    , intCurrencyId
                    , strBatchId
                    , strCode
                    , strTransactionType
                    , strTransactionForm
                    , strReference
                    , strDocument
                    , strComments
                    , strPeriod
                    , strDescription
                    , dblSourceUnitDebit
                    , dblSourceUnitCredit
                    , dblDebitReport
                    , dblCreditReport
                    , strCommodityCode
                    , strSourceDocumentId
                    , strLocation
                    , strCompanyLocation
                    , strJournalLineDescription
                    , strUOMCode
                    , strStatus
                    , intSourceEntityId
                    , strSourceEntity
                    , strSourceEntityNo
                    , strLOBSegmentDescription
                    , strCurrency
                    , strAccountId
                FROM #AuditorTransactions 
                WHERE @strTransactionId =strTransactionId 
                AND @intCurrencyId = intCurrencyId
                ORDER BY dtmDate

                -- Total record
                INSERT INTO tblGLAuditorTransaction (
                    intType
                    , intGeneratedBy      
                    , dtmDateGenerated
                    , strTransactionId
                    , strTotalTitle
                    , strGroupTitle
                    , intEntityId
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblTotal
                    , dblTotalForeign
                    , strCurrency
                )
                SELECT TOP 1
                    1
                    , @intEntityId
                    , @dtmNow
                    , @strTransactionId
                    , 'Total'
                    , 'Transaction ID: ' + @strTransactionId + ', Currency: ' + strCurrency
                    , @intEntityId
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblAmount
                    , dblAmountForeign
                    , strCurrency
                    FROM #TransactionGroup 
                    WHERE strTransactionId = @strTransactionId
                    AND @intCurrencyId = intCurrencyId
            

                DELETE #TransactionGroup WHERE @strTransactionId = strTransactionId AND @intCurrencyId = intCurrencyId
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