CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByTransactionId]
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
                , strBatchId = ISNULL(A.strBatchId, '')
                , A.intAccountId
                , strTransactionId = ISNULL(A.strTransactionId, '')
                , A.intTransactionId
                , A.intCurrencyId
                , A.dtmDate
                , A.dtmDateEntered
                , dblDebit = ISNULL(A.dblDebit, 0)
                , dblCredit = ISNULL(A.dblCredit, 0)
                , dblDebitForeign = ISNULL(A.dblDebitForeign, 0)
                , dblCreditForeign = ISNULL(A.dblCreditForeign, 0)
                , strPeriod = ISNULL(FP.strPeriod, '')
                , strDescription = ISNULL(A.strDescription, '')
                , strCode = ISNULL(A.strCode, '')
                , strReference = ISNULL(A.strReference, '')
                , strComments = ISNULL(A.strComments, '')
                , strJournalLineDescription = ISNULL(A.strJournalLineDescription, '')
                , strUOMCode = ISNULL(U.strUOMCode, '')
                , strTransactionType = ISNULL(A.strTransactionType, '')
                , strModuleName = ISNULL(A.strModuleName, '')
                , strTransactionForm = ISNULL(A.strTransactionForm, '')
                , strDocument = ISNULL(A.strDocument, '')
                , A.dblExchangeRate
                , strStatus = CASE WHEN A.ysnIsUnposted = 0 THEN 'Posted' ELSE 'Audit Record ' END
                , A.dblDebitReport
                , A.dblCreditReport
                , A.dblSourceUnitDebit
                , A.dblSourceUnitCredit
                , A.dblDebitUnit
                , A.dblCreditUnit
                , strCommodityCode = ISNULL(ICCom.strCommodityCode, '')
                , strSourceDocumentId = ISNULL(A.strSourceDocumentId, '')
                , strLocation = ISNULL(Loc.strLocationName, '')
                , strCompanyLocation = ISNULL(CL.strLocationName, '')
                , strSourceUOMId = ISNULL(ICUOM.strUnitMeasure, '')
                , A.intSourceEntityId
                , strSourceEntity = ISNULL(SE.strName, '')
                , strSourceEntityNo = ISNULL(SE.strEntityNo, '')
            FROM tblGLDetail A
	        LEFT JOIN tblGLAccount AS B ON A.intAccountId = B.intAccountId
            LEFT JOIN tblSMCompanyLocation Loc ON A.intSourceLocationId = Loc.intCompanyLocationId
            LEFT JOIN tblICUnitMeasure ICUOM ON ICUOM.intUnitMeasureId = A.intSourceUOMId
            LEFT JOIN tblICCommodity ICCom ON ICCom.intCommodityId = A.intCommodityId
            LEFT JOIN tblEMEntity EM ON EM.intEntityId = A.intEntityId
            LEFT JOIN tblGLFiscalYearPeriod FP ON FP.intGLFiscalYearPeriodId = A.intFiscalPeriodId
            LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intCompanyLocationId
            OUTER APPLY (
		        SELECT TOP 1 dblLbsPerUnit,strUOMCode FROM tblGLAccountUnit WHERE intAccountUnitId = B.intAccountUnitId
	         )U
            OUTER APPLY (
		        SELECT TOP 1 strName, strEntityNo  from tblEMEntity  WHERE intEntityId = A.intSourceEntityId
	         )SE
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
                , dblDebit = SUM(ISNULL(dblDebit, 0))
                , dblCredit = SUM(ISNULL(dblCredit, 0))
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
                    , strModuleName
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
                    , strModuleName
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
                FROM #AuditorTransactions 
                WHERE strTransactionId = @strTransactionId
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
                )
                SELECT TOP 1
                    1
                    , @intEntityId
                    , @dtmNow
                    , @strTransactionId
                    , 'Total'
                    , 'Transaction ID: ' + @strTransactionId
                    , @intEntityId
                    , dblDebit
                    , dblCredit
                    , dblDebitForeign
                    , dblCreditForeign
                    , dblAmount
                    , dblAmountForeign
                    FROM #TransactionGroup 
                    WHERE strTransactionId = @strTransactionId

                DELETE #TransactionGroup WHERE strTransactionId = @strTransactionId
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