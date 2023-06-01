CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByAccountId]
	@intEntityId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
    @ysnSuppressZero BIT,
    @intLocationSegmentId INT,
    @intLOBSegmentId INT,
    @intCurrencyId INT,
    @intPrimaryFrom INT,
    @intPrimaryTo INT,
    @intAccountIdFrom INT,
    @intAccountIdTo INT
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
        IF OBJECT_ID('tempdb..##AuditorTransactions') IS NOT NULL
            DROP TABLE ##AuditorTransactions
        DECLARE @strSQL NVARCHAR(MAX) =
        ' ;WITH T AS (
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
                , FP.strPeriod 
                , A.strDescription
                , strAccountDescription = B.strDescription
                , A.strCode
                , A.strReference
                , A.strComments
                , A.strJournalLineDescription
                , U.strUOMCode 
                , A.strTransactionType 
                , A.strModuleName 
                , A.strTransactionForm 
                , A.strDocument
                , A.dblExchangeRate
                --, A.strStatus 
                , A.dblDebitReport
                , A.dblCreditReport
                , A.dblSourceUnitDebit
                , A.dblSourceUnitCredit
                , A.dblDebitUnit
                , A.dblCreditUnit
                , IC.strCommodityCode 
                , A.strSourceDocumentId
                , strLocation = B.strLocationSegmentId
                , strCompanyLocation = CL.strLocationName
                , strSourceUOMId = ICUOM.strUnitMeasure  
                , A.intSourceEntityId
                , strSourceEntity = SE.strName
                , strSourceEntityNo = SE.strEntityNo  
                , strLOBSegmentDescription = B.strLOBSegmentId
                , SM.strCurrency
                , B.strAccountId
                , strPrimary = B.strCode
                , B.intOrderId
            FROM  
			tblGLDetail A LEFT JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
            LEFT JOIN tblSMCurrency SM on SM.intCurrencyID = A.intCurrencyId
			LEFT JOIN tblGLFiscalYearPeriod FP ON FP.intGLFiscalYearPeriodId = A.intFiscalPeriodId
			LEFT JOIN tblICCommodity IC ON IC.intCommodityId = A.intCommodityId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intCompanyLocationId
			LEFT JOIN tblICUnitMeasure ICUOM ON ICUOM.intUnitMeasureId = A.intSourceUOMId
			OUTER APPLY (
				SELECT TOP 1 strName, strEntityNo  from tblEMEntity  WHERE intEntityId = A.intSourceEntityId
			)SE
			OUTER APPLY (
				SELECT TOP 1 dblLbsPerUnit,strUOMCode FROM tblGLAccountUnit WHERE intAccountUnitId = B.intAccountUnitId
			)U
            WHERE A.ysnIsUnposted = 0 AND A.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo'
            
         DECLARE @strWhere NVARCHAR(MAX) = ''
        IF ( ISNULL(@intLocationSegmentId,0) <> 0)BEGIN
            SET @strSQL = @strSQL + '  AND B.intLocationSegmentId =  ' +  CAST( @intLocationSegmentId AS NVARCHAR(5))
            SET @strWhere =@strSQL
        END
        IF ( ISNULL(@intLOBSegmentId,0) <> 0)BEGIN
            SET @strSQL = @strSQL + '  AND B.intLOBSegmentId =  ' +  CAST( @intLOBSegmentId AS NVARCHAR(5))
            SET @strWhere =@strSQL
        END
         IF ( ISNULL(@intCurrencyId,0) <> 0)
            SET @strSQL = @strSQL + '  AND A.intCurrencyId =  ' +  CAST( @intCurrencyId AS NVARCHAR(5))
       
        DECLARE @strWhere1 NVARCHAR(MAX)

        IF (ISNULL(@intAccountIdFrom, 0) <> 0 AND ISNULL(@intAccountIdTo, 0) <> 0)
        BEGIN
            IF @intAccountIdFrom > @intAccountIdTo
            BEGIN
                SET @strWhere1 =  '  AND B.intOrderId BETWEEN  ' +  CAST( @intAccountIdTo AS NVARCHAR(5)) + ' AND ' + CAST( @intAccountIdFrom AS NVARCHAR(5))
                SET @strSQL = @strSQL +  @strWhere1 
                SET @strWhere += @strWhere1
            END
            ELSE
            BEGIN
                SET @strWhere1 =  '  AND B.intOrderId BETWEEN  ' +  CAST( @intAccountIdFrom AS NVARCHAR(5)) + ' AND ' + CAST( @intAccountIdTo AS NVARCHAR(5))
                SET @strSQL += @strWhere1 
                SET @strWhere += @strWhere1


            END
        END
        
        IF (ISNULL(@intAccountIdFrom, 0) <> 0 AND ISNULL(@intAccountIdTo, 0) = 0)
        BEGIN
            SET @strWhere1 ='  AND B.intOrderId =  ' +  CAST( @intAccountIdFrom AS NVARCHAR(5))
            SET @strSQL += @strWhere1
            SET @strWhere += @strWhere1
        END

        
        IF (ISNULL(@intPrimaryFrom, 0) <> 0 AND ISNULL(@intPrimaryTo, 0) <> 0)
        BEGIN
            IF @intPrimaryFrom > @intPrimaryTo
            BEGIN
                SET @strWhere1 = '  AND B.intPrimaryOrderId BETWEEN  ' +  CAST( @intPrimaryTo AS NVARCHAR(5)) + ' AND ' + CAST( @intPrimaryFrom AS NVARCHAR(5))
                SET @strSQL += @strWhere1 
                SET @strWhere += @strWhere1
            END
            ELSE
            BEGIN
                SET @strWhere1 ='  AND B.intPrimaryOrderId BETWEEN  ' +  CAST( @intPrimaryFrom AS NVARCHAR(5)) + ' AND ' + CAST( @intPrimaryTo AS NVARCHAR(5))
                SET @strSQL += @strWhere1 
                SET @strWhere += @strWhere1
            END
        END
        IF (ISNULL(@intPrimaryFrom, 0) <> 0 AND ISNULL(@intPrimaryTo, 0) = 0)
        BEGIN
            SET @strWhere1 = '  AND B.intPrimaryOrderId =  ' +  CAST( @intPrimaryFrom AS NVARCHAR(5))
            SET @strSQL += @strWhere1 
            SET @strWhere += @strWhere1
        END
        SET @strSQL = @strSQL + ') SELECT * INTO ##AuditorTransactions FROM T ORDER BY T.intOrderId, T.intCurrencyId, T.dtmDate, T.intGLDetailId'
        DECLARE @params NVARCHAR(100) = '@dtmDateFrom DATETIME, @dtmDateTo DATETIME'

        EXEC sp_executesql @strSQL, @params, @dtmDateFrom= @dtmDateFrom, @dtmDateTo=@dtmDateTo
        DECLARE @dtmNow DATETIME = GETDATE()
        IF OBJECT_ID('tempdb..##TransactionGroup') IS NOT NULL
            DROP TABLE ##TransactionGroup
         IF OBJECT_ID('tempdb..#TransactionGroupAll') IS NOT NULL
            DROP TABLE #TransactionGroupAll
            SELECT
                intAccountId, strAccountId,
                strLOBSegmentId strLOBSegmentDescription, 
                strLocationSegmentId strLocation, 
                GL.strDescription strAccountDescription 
            INTO #TransactionGroupAll
            FROM vyuGLAccountDetail GL
            DECLARE @sqlGroups NVARCHAR(MAX) = 

            

           '
           DECLARE @dtmFrom DATETIME
           SELECT TOP 1 @dtmFrom= dtmDateFrom FROM tblGLFiscalYear WHERE dtmDateFrom < @dtmDateFrom ORDER BY dtmDateFrom
           
           ;WITH groups AS(
            SELECT 
                intAccountId
                , strAccountId
                , strCurrency
                , intCurrencyId
                , strLOBSegmentDescription
                , strLocation
                , strAccountDescription
            FROM ##AuditorTransactions 
            GROUP BY intAccountId, strAccountId, intCurrencyId, strCurrency
            ,strLOBSegmentDescription,strLocation, strAccountDescription
               UNION
            --GETS THE PREVIOUS YEAR
            SELECT  A.intAccountId
                , strAccountId
                , strCurrency
                , intCurrencyId
                , strLOBSegmentId  strLOBSegmentDescription 
                , strLocationSegmentId strLocation
                , B.strDescription strAccountDescription FROM tblGLDetail A JOIN vyuGLAccountDetail B on A.intAccountId = B.intAccountId
            WHERE A.ysnIsUnposted = 0 AND A.dtmDate BETWEEN
            @dtmFrom AND DATEADD(SECOND, -1, @dtmDateFrom) ' + @strWhere + '
                GROUP BY A.intAccountId, strAccountId, A.intCurrencyId, SM.strCurrency
            ,strLOBSegmentId,strLocationSegmentId, B.strDescription
            )
            SELECT
              intAccountId
                , strAccountId
                , strCurrency
                , intCurrencyId
                , strLOBSegmentDescription
                , strLocation
                , strAccountDescription
              INTO ##TransactionGroup 
              FROM groups'

            EXEC sp_executesql @sqlGroups, N'@dtmDateFrom DATETIME', @dtmDateFrom= @dtmDateFrom  

            DECLARE @intAccountIdLoop INT = 0
            DECLARE @intCurrencyIdLoop INT = 0
            DECLARE @_intAccountId INT
            DECLARE @_intCurrencyId INT
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
                SELECT TOP 1 @_intAccountId= intAccountId ,  @strAccountId = strAccountId
                FROM #TransactionGroupAll
                ORDER BY strAccountId

				-- SELECT
				-- 	@beginBalance               = 0,
				-- 	@beginBalanceDebit          = 0,
				-- 	@beginBalanceCredit         = 0,
				-- 	@beginBalanceForeign        = 0,
				-- 	@beginBalanceDebitForeign   = 0,
				-- 	@beginBalanceCreditForeign  = 0
                
                -- SELECT
				-- 	--@beginBalance=          ISNULL(beginBalance,0),
				-- 	@beginBalanceDebit=     ISNULL(beginBalanceDebit,0),
				-- 	@beginBalanceCredit=    ISNULL(beginBalanceCredit,0)
				-- 	FROM dbo.fnGLGetBeginningBalanceAuditorReport(@strAccountId,@dtmDateFrom)
                        -- Total record
                DECLARE @_strAccountId NVARCHAR(60)
                DECLARE @_beginBalance NUMERIC(18,6)
				IF EXISTS(SELECT 1 FROM ##TransactionGroup where @_intAccountId =intAccountId)
				BEGIN
                    WHILE EXISTS ( SELECT 1 FROM ##TransactionGroup WHERE @_intAccountId = intAccountId)
                    BEGIN
                        SELECT TOP 1 @_intCurrencyId = intCurrencyId, @_strAccountId = strAccountId
                        FROM ##TransactionGroup WHERE @_intAccountId = intAccountId
                        ORDER BY intCurrencyId
                        
                        SELECT
                        @beginBalance               =   ISNULL(beginBalance ,0),
                        @beginBalanceDebit          =   ISNULL(beginBalanceDebit,0),
				        @beginBalanceCredit         =   ISNULL(beginBalanceCredit,0),
                        @beginBalanceForeign        =   ISNULL(beginBalanceForeign,0),
                        @beginBalanceDebitForeign   =   ISNULL(beginBalanceDebitForeign,0),
                        @beginBalanceCreditForeign  =   ISNULL(beginBalanceCreditForeign,0)
                        FROM dbo.fnGLGetBeginningBalanceAuditorReportForeign(@strAccountId,@dtmDateFrom,@_intCurrencyId)
                                -- Total record

                        IF @intAccountIdLoop <> @_intAccountId
                        BEGIN
                            SELECT @_beginBalance =ISNULL( beginBalance , 0) from dbo.fnGLGetBeginningBalanceAuditorReport(@_strAccountId,@dtmDateFrom)
                            SET @intAccountIdLoop = @_intAccountId
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
                                , @_beginBalance --@beginBalance
                                , @_beginBalance --@beginBalanceForeign            
                                , strCurrency
                                , strAccountId
                                , strLocation
                                , strLOBSegmentDescription
                                , strAccountDescription
                                , 1
                                FROM ##TransactionGroup 
                                WHERE intAccountId = @_intAccountId
                                AND @_intCurrencyId = intCurrencyId

                        END
                        ;WITH cteOrder AS(
                            select *, ROW_NUMBER() over(order by dtmDate, strTransactionId) rowId 
                            FROM ##AuditorTransactions 
                            WHERE @_intAccountId =intAccountId 
                            AND @_intCurrencyId = intCurrencyId   
                        )
                        ,cteTotal AS (
                            select * , sum(dblDebit - dblCredit) over(order by rowId) total,
                            sum(dblDebitForeign - dblCreditForeign) over(order by rowId) totalf
                            from cteOrder
                        ),
                        
                        cteResult AS(
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
                           -- , strStatus 
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
                            , total - (dblDebit - dblCredit) + @beginBalance dblBeginningBalance 
                            , totalf - (dblDebitForeign - dblCreditForeign) + @beginBalanceForeign dblBeginningBalanceForeign
                            , total + @beginBalance  dblEndingBalance
                            , totalf + @beginBalanceForeign  dblEndingBalanceForeign
                            FROM cteTotal
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
                                --, strStatus 
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
                                --, strStatus 
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
                                FROM cteResult

                                SELECT
                                @dblTotalDebit = sum(dblDebit) , 
                                @dblTotalCredit= sum(dblCredit) ,
                                @dblTotalDebitUnit = sum(ISNULL(dblDebitUnit,0)) , 
                                @dblTotalCreditUnit= sum(ISNULL(dblCreditUnit,0)) ,
                                @dblTotalSourceUnitDebit = SUM(ISNULL(dblSourceUnitDebit,0)),
                                @dblTotalSourceUnitCredit = SUM(ISNULL(dblSourceUnitCredit,0)),
                                @dblTotalDebitForeign = sum(dblDebitForeign),
                                @dblTotalCreditForeign = sum(dblCreditForeign)
                                FROM ##AuditorTransactions 
                                WHERE @_intAccountId =intAccountId 
                                AND @_intCurrencyId = intCurrencyId    

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
                                FROM ##TransactionGroup 
                                WHERE intAccountId = @_intAccountId
                                AND @_intCurrencyId = intCurrencyId
                            
                                --SET @beginBalance = @beginBalance +  (@dblTotalDebit - @dblTotalCredit)
                                DELETE ##TransactionGroup WHERE @_intAccountId = intAccountId AND @_intCurrencyId = intCurrencyId
                    END --  while exist in #TransactionGroup
				END -- if exist in #TransactionGroup
				ELSE -- if not exist in #TransactionGroup
                BEGIN
                    DECLARE @dtmStartPreviousFiscal DATETIME
                    SELECT TOP 1 @dtmStartPreviousFiscal = dtmDateFrom FROM tblGLFiscalYear WHERE DATEADD(SECOND, -1, @dtmDateFrom) BETWEEN dtmDateFrom AND dtmDateTo

                    IF OBJECT_ID('tempdb..#PreviousFiscalCurrency') IS NOT NULL
                    DROP TABLE #PreviousFiscalCurrency

                    SELECT intCurrencyId, strCurrency INTO #PreviousFiscalCurrency 
                    FROM vyuGLDetail WHERE ysnIsUnposted = 0 AND dtmDate BETWEEN DATEADD(SECOND, -1, @dtmDateFrom) AND @dtmStartPreviousFiscal AND 
                    intAccountId = @_intAccountId
                    ORDER BY intCurrencyId

                    DECLARE @strCurrency NVARCHAR(10)
                    
                    WHILE EXISTS ( SELECT 1 FROM #PreviousFiscalCurrency)
                    BEGIN
                        SELECT TOP 1 @_intCurrencyId = intCurrencyId, @strCurrency = strCurrency FROM #PreviousFiscalCurrency

                          SELECT
                            @beginBalance               =   ISNULL(@beginBalance ,0),
                            @beginBalanceDebit          =   ISNULL(beginBalanceDebit,0),
                            @beginBalanceCredit         =   ISNULL(beginBalanceCredit,0),
                            @beginBalanceForeign        =   ISNULL(beginBalanceForeign,0),
                            @beginBalanceDebitForeign   =   ISNULL(beginBalanceDebitForeign,0),
                            @beginBalanceCreditForeign  =   ISNULL(beginBalanceCreditForeign,0)
                        FROM dbo.fnGLGetBeginningBalanceAuditorReportForeign(@strAccountId,@dtmDateFrom,@_intCurrencyId)

                        SELECT @ysnZeroEntry = CASE WHEN
                            @beginBalance = 0 AND @beginBalanceForeign = 0
                            AND @beginBalanceDebit + @beginBalanceCredit= 0
                            AND @beginBalanceDebitForeign + @beginBalanceCreditForeign= 0
                            THEN 1 ELSE 0 END


                        IF @ysnSuppressZero = 0 AND @ysnZeroEntry = 1
                        BEGIN

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
                                , 'Account ID: ' + strAccountId + ', Currency: ' + @strCurrency
                                , @intEntityId
                                , 0
                                , 0            
                                , @strCurrency
                                , strAccountId
                                , strLocation
                                , strLOBSegmentDescription
                                , strAccountDescription
                                , 1
                            FROM #TransactionGroupAll
                            WHERE intAccountId = @_intAccountId
                            INSERT INTO tblGLAuditorTransaction (
                                ysnGroupFooter
                                ,ysnGroupHeader
                                , intType
                                , intGeneratedBy      
                                , dtmDateGenerated
                                , strTotalTitle
                                , strGroupTitle
                                , intEntityId
                                , dblEndingBalance
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
                                , 'Account ID: ' + strAccountId + ', Currency: ' + @strCurrency
                                , @intEntityId
                                , 0
                                , 0            
                                , @strCurrency
                                , strAccountId
                                , strLocation
                                , strLOBSegmentDescription
                                , strAccountDescription
                                , 1
                                FROM #TransactionGroupAll
                                WHERE intAccountId = @_intAccountId

                        END  
                        ELSE
                        BEGIN
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
                                , 'Account ID: ' + strAccountId + ', Currency: ' + @strCurrency
                                , @intEntityId
                                , @beginBalance
                                , @beginBalanceForeign           
                                , @strCurrency
                                , strAccountId
                                , strLocation
                                , strLOBSegmentDescription
                                , strAccountDescription
                                , 1
                            FROM #TransactionGroupAll
                            WHERE intAccountId = @_intAccountId
                            INSERT INTO tblGLAuditorTransaction (
                                ysnGroupFooter
                                ,ysnGroupHeader
                                , intType
                                , intGeneratedBy      
                                , dtmDateGenerated
                                , strTotalTitle
                                , strGroupTitle
                                , intEntityId
                                , dblEndingBalance
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
                                , 'Account ID: ' + strAccountId + ', Currency: ' + @strCurrency
                                , @intEntityId
                                , @beginBalance
                                , @beginBalanceForeign            
                                , @strCurrency
                                , strAccountId
                                , strLocation
                                , strLOBSegmentDescription
                                , strAccountDescription
                                , 1
                                FROM #TransactionGroupAll
                                WHERE intAccountId = @_intAccountId


                        END    



                        DELETE FROM #PreviousFiscalCurrency WHERE @_intCurrencyId = intCurrencyId
                    END

                  
                    
               

                   
                
                END
				DELETE FROM #TransactionGroupAll WHERE @_intAccountId = intAccountId
            END

        INSERT INTO tblGLAuditorTransaction (ysnSpace,intType,intGeneratedBy,intEntityId) SELECT 1, 0, @intEntityId, @intEntityId --space

        IF EXISTS (SELECT 1 FROM ##AuditorTransactions)
        BEGIN 
             INSERT INTO tblGLAuditorTransaction (ysnSummary, intType,intGeneratedBy,intEntityId, strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
                SELECT 1,0, @intEntityId, @intEntityId,
                strCurrency,
                SUM(ISNULL(dblDebit,0)) dblDebit, 
                SUM(ISNULL(dblCredit,0)) dblCredit,
                SUM(ISNULL(dblDebit,0)- ISNULL(dblCredit,0)) dblEndingBalance
                FROM
                ##AuditorTransactions  A 
                GROUP BY strCurrency

            INSERT INTO tblGLAuditorTransaction (ysnSummaryFooter, intType,intGeneratedBy,intEntityId,strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
            SELECT 1, 0, @intEntityId, @intEntityId,
            'Final Total',
            SUM(ISNULL(dblDebit,0)) dblDebit, 
            SUM(ISNULL(dblCredit,0)) dblCredit,
            SUM(ISNULL(dblDebit,0)- ISNULL(dblCredit,0)) dblEndingBalance
            FROM
            ##AuditorTransactions  A 

        END
        ELSE
        BEGIN
            IF isnull(@ysnSuppressZero,0) = 0 
            BEGIN
                INSERT INTO tblGLAuditorTransaction (ysnSummary, intType,intGeneratedBy,intEntityId, strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
                SELECT 1,0, @intEntityId, @intEntityId,
                SM.strCurrency,
                0 dblDebit, 
                0 dblCredit,
                0 dblEndingBalance
                FROM
                ##AuditorTransactions  A  RIGHT JOIN tblSMCurrency SM ON SM.intCurrencyID = A.intCurrencyId
                GROUP BY SM.strCurrency

                INSERT INTO tblGLAuditorTransaction (ysnSummaryFooter, intType,intGeneratedBy,intEntityId,strTotalTitle, dblDebit, dblCredit, dblDebitUnit)
                SELECT 1, 0, @intEntityId, @intEntityId,
                'Final Total',
                0 dblDebit, 
                0 dblCredit,
                0 dblEndingBalance
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