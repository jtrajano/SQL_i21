CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByAccountId]
	@intEntityId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
    @ysnSuppressZero BIT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_NULLS ON;
	SET NOCOUNT ON;

    DECLARE @strError NVARCHAR(MAX), @ysnAllowZeroEntry BIT , @ysnZeroEntry BIT

    DELETE [dbo].[tblGLAuditorTransaction] WHERE intGeneratedBy = @intEntityId AND intType = 0;
    DECLARE @intDefaultCurrencyId INT, @strDefaultCurrency NVARCHAR(10)
    SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId, @strDefaultCurrency= strCurrency FROM 
    tblSMCompanyPreference A JOIN tblSMCurrency B on A.intDefaultCurrencyId = B.intCurrencyID
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
         IF OBJECT_ID('tempdb..#TransactionGroupAll') IS NOT NULL
            DROP TABLE #TransactionGroupAll

       
            SELECT
                intAccountId, strAccountId,
                strLOBSegmentId strLOBSegmentDescription, 
                strLocationSegmentId strLocation, 
                GL.strDescription strAccountDescription 
            INTO #TransactionGroupAll
            FROM vyuGLAccountDetail GL

        
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
            DECLARE @dblTotalDebitUnit NUMERIC(18,6)
            DECLARE @dblTotalCreditUnit  NUMERIC(18,6)
            DECLARE @dblTotalSourceUnitDebit NUMERIC(18,6)
            DECLARE @dblTotalSourceUnitCredit NUMERIC(18,6)

            DECLARE 
            @beginBalance NUMERIC(18,6)              = 0,
            @beginBalanceForeign NUMERIC(18,6)       = 0,
            @beginBalanceDebit NUMERIC(18,6)         = 0,
            @beginBalanceCredit NUMERIC(18,6)        = 0,
            @beginBalanceDebitForeign NUMERIC(18,6)  = 0,
            @beginBalanceCreditForeign NUMERIC(18,6) = 0

            WHILE EXISTS(SELECT TOP 1 1 FROM #TransactionGroupAll)
            BEGIN
                SELECT TOP 1 @intAccountId= intAccountId ,  @strAccountId = strAccountId
                FROM #TransactionGroupAll
                ORDER BY strAccountId

				SELECT
					@beginBalance               = 0,
					@beginBalanceDebit          = 0,
					@beginBalanceCredit         = 0,
					@beginBalanceForeign        = 0,
					@beginBalanceDebitForeign   = 0,
					@beginBalanceCreditForeign  = 0
                
                SELECT
					@beginBalance=          ISNULL(beginBalance,0),
					@beginBalanceDebit=     ISNULL(beginBalanceDebit,0),
					@beginBalanceCredit=    ISNULL(beginBalanceCredit,0)
					FROM dbo.fnGLGetBeginningBalanceAuditorReport(@strAccountId,@dtmDateFrom)
                

                        -- Total record
                   
                     

				IF EXISTS(SELECT 1 FROM #TransactionGroup where @intAccountId =intAccountId)
				BEGIN
                    WHILE EXISTS ( SELECT 1 FROM #TransactionGroup WHERE @intAccountId = intAccountId)
                    BEGIN
                        SELECT TOP 1 @intCurrencyId = intCurrencyId
                        FROM #TransactionGroup WHERE @intAccountId = intAccountId
                        ORDER BY intCurrencyId
                        
                        SELECT
                        @beginBalanceForeign=       ISNULL(beginBalanceForeign,0),
                        @beginBalanceDebitForeign=  ISNULL(beginBalanceDebitForeign,0),
                        @beginBalanceCreditForeign= ISNULL(beginBalanceCreditForeign,0)
                        FROM dbo.fnGLGetBeginningBalanceAuditorReportForeign(@strAccountId,@dtmDateFrom,@intCurrencyId)
                                -- Total record

                        IF @intAccountIdLoop <> @intAccountId
                        BEGIN
                            SET @intAccountIdLoop = @intAccountId
                            INSERT INTO tblGLAuditorTransaction (
                            ysnGroupFooter
                            ,ysnGroupHeader
                            , intType
                            , intGeneratedBy      
                            , dtmDateGenerated
                            , strTotalTitle
                            , strGroupTitle
                            , intEntityId
                            , dblBeginningBalance
                            , dblBeginningBalanceForeign
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
                                , @beginBalance
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
                            dblBeginningBalance =  dblEndingBalance- (dblDebit- dblCredit),
                            dblBeginningBalanceForeign =  dblEndingBalanceForeign- (dblDebitForeign- dblCreditForeign)
                            FROM 
                            CTE )
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
                                @dblTotalDebit = sum(dblDebit) , 
                                @dblTotalCredit= sum(dblCredit) ,
                                @dblTotalDebitUnit = sum(ISNULL(dblDebitUnit,0)) , 
                                @dblTotalCreditUnit= sum(ISNULL(dblCreditUnit,0)) ,
                                @dblTotalSourceUnitDebit = SUM(ISNULL(dblSourceUnitDebit,0)),
                                @dblTotalSourceUnitCredit = SUM(ISNULL(dblSourceUnitCredit,0)),
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
                                , dblEndingBalance
                                , dblDebit
                                , dblCredit
                                , dblDebitUnit
                                , dblCreditUnit
                                , dblSourceUnitDebit
                                , dblSourceUnitCredit
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
                                CAST(1 AS BIT)
                                ,CAST(0 AS BIT)
                                , 0
                                , @intEntityId
                                , @dtmNow
                                , 'Total'
                                , 'Account ID: ' + strAccountId + ', Currency: ' + strCurrency
                                , @intEntityId
                                , @dblTotalDebit- @dblTotalCredit + @beginBalance
                                , @dblTotalDebit + CASE WHEN @beginBalance > 0 THEN @beginBalance ELSE 0 END
                                , @dblTotalCredit - CASE WHEN @beginBalance < 0 THEN  @beginBalance ELSE 0 END
                                , @dblTotalDebitUnit
                                , @dblTotalCreditUnit
                                , @dblTotalSourceUnitDebit
                                , @dblTotalSourceUnitCredit
                                , @dblTotalDebitForeign
                                , @dblTotalCreditForeign     
                                , @dblTotalDebitForeign- @dblTotalCreditForeign  + @beginBalanceForeign
                                , strCurrency
                                , strAccountId
                                , strLocation
                                , strLOBSegmentDescription
                                , strAccountDescription
                                , 1
                                FROM #TransactionGroup 
                                WHERE intAccountId = @intAccountId
                                AND @intCurrencyId = intCurrencyId
                            
                                SET @beginBalance = @beginBalance +  (@dblTotalDebit - @dblTotalCredit)
                                DELETE #TransactionGroup WHERE @intAccountId = intAccountId AND @intCurrencyId = intCurrencyId
                    END --  while exist in #TransactionGroup
				END -- if exist in #TransactionGroup
				ELSE -- if not exist in #TransactionGroup
                BEGIN

                
                    
                    SELECT @ysnZeroEntry = CASE WHEN
                        @beginBalance = 0 AND @beginBalanceForeign = 0
                        AND @beginBalanceDebit + @beginBalanceCredit= 0
                        AND @beginBalanceDebitForeign + @beginBalanceCreditForeign= 0
                        THEN 1 ELSE 0 END

                    IF @ysnSuppressZero = 0 OR @ysnZeroEntry = 0 OR
                    (@ysnZeroEntry = 1 AND @ysnSuppressZero = 0)

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
                            , 'Account ID: ' + strAccountId + ', Currency: ' + @strDefaultCurrency
                            , @intEntityId
                            , @beginBalanceDebit
                            , @beginBalanceCredit
                            , @beginBalance
                            , @beginBalanceDebitForeign
                            , @beginBalanceCreditForeign     
                            , @beginBalanceForeign            
                            , @strDefaultCurrency
                            , strAccountId
                            , strLocation
                            , strLOBSegmentDescription
                            , strAccountDescription
                            , 1
                            FROM #TransactionGroupAll
                            WHERE intAccountId = @intAccountId
                            
                        UNION ALL SELECT TOP 1
                            CAST(1 AS BIT)
                            ,CAST(0 AS BIT)
                            , 0
                            , @intEntityId
                            , @dtmNow
                            , 'Total'
                            , 'Account ID: ' + strAccountId + ', Currency: ' + @strDefaultCurrency
                            , @intEntityId
                            , 0
                            , 0
                            , @beginBalance
                            , 0
                            , 0    
                            , @beginBalanceForeign            
                            , @strDefaultCurrency
                            , strAccountId
                            , strLocation
                            , strLOBSegmentDescription
                            , strAccountDescription
                            , 1
                            FROM #TransactionGroupAll
                            WHERE intAccountId = @intAccountId
                
                END
				DELETE FROM #TransactionGroupAll WHERE @intAccountId = intAccountId
            END

        INSERT INTO tblGLAuditorTransaction (ysnSpace,intType,intGeneratedBy,intEntityId) SELECT 1, 0, @intEntityId, @intEntityId --space

        IF @ysnSuppressZero = 1
            INSERT INTO tblGLAuditorTransaction (ysnSummary, intType,intGeneratedBy,intEntityId, strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
                SELECT 1,0, @intEntityId, @intEntityId,
                strCurrency,
                SUM(ISNULL(dblDebit,0)) dblDebit, 
                SUM(ISNULL(dblCredit,0)) dblCredit,
                SUM(ISNULL(dblDebit,0)- ISNULL(dblCredit,0)) dblEndingBalance
                FROM
                #AuditorTransactions  A 
                GROUP BY strCurrency
        ELSE
                INSERT INTO tblGLAuditorTransaction (ysnSummary, intType,intGeneratedBy,intEntityId, strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
                SELECT 1,0, @intEntityId, @intEntityId,
                SM.strCurrency,
                SUM(ISNULL(dblDebit,0)) dblDebit, 
                SUM(ISNULL(dblCredit,0)) dblCredit,
                SUM(ISNULL(dblDebit,0)- ISNULL(dblCredit,0)) dblEndingBalance
                FROM
                #AuditorTransactions  A  RIGHT JOIN tblSMCurrency SM ON SM.intCurrencyID = A.intCurrencyId
                GROUP BY SM.strCurrency


          INSERT INTO tblGLAuditorTransaction (ysnSummaryFooter, intType,intGeneratedBy,intEntityId,strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
            SELECT 1, 0, @intEntityId, @intEntityId,
            'Final Total',
            SUM(ISNULL(dblDebit,0)) dblDebit, 
            SUM(ISNULL(dblCredit,0)) dblCredit,
            SUM(ISNULL(dblDebit,0)- ISNULL(dblCredit,0)) dblEndingBalance
            FROM
            #AuditorTransactions  A 
            

            
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