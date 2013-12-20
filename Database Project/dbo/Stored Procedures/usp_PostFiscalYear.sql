CREATE PROCEDURE [dbo].[usp_PostFiscalYear]
	 @intUserID					INT
	,@intFiscalYearID			INT
	,@ysnPost					BIT				= 0
	,@ysnRecap					BIT				= 0

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

CREATE TABLE #ConstructGL
(
	dtmDate						DATETIME
	,strBatchID					NVARCHAR(100)
	,intAccountID				INT
	,strAccountGroup			NVARCHAR(50)
	,dblDebit					NUMERIC(18, 6)
	,dblCredit					NUMERIC(18, 6)
	,dblDebitUnit				NUMERIC(18, 6)
	,dblCreditUnit				NUMERIC(18, 6)
	,strGLDescription			NVARCHAR(300)
	,strCode					NVARCHAR(50)
	,strTransactionID			NVARCHAR(100)
	,strReference				NVARCHAR(500)
	,strJobID					NVARCHAR(100)
	,intCurrencyID				INT
	,dblExchangeRate			NUMERIC(18, 6)
	,dtmDateEntered				DATETIME
	,dtmTransactionDate			DATETIME
	,strProductID				NVARCHAR(100)
	,strWarehouseID				NVARCHAR(100)
	,strNum						NVARCHAR(200)
	,strCompanyName				NVARCHAR(300)
	,strBillInvoiceNumber		NVARCHAR(100)
	,strJournalLineDescription	NVARCHAR(500)
	,ysnIsUnposted				BIT
	,intConcurrencyID			INT
	,intUserID					INT
	,strTransactionForm			NVARCHAR(510)
	,strModuleName				NVARCHAR(510)
	,strUOMCode					NVARCHAR(50)
	
	,strAccountID				NVARCHAR(100)
	,strDescription				NVARCHAR(300)
)

-- ++++++++ GLOBAL DECLARATION ++++++++ --
DECLARE  @dblRetained			 NUMERIC (18,6)
		,@dblRetainedDebit		 NUMERIC (18,6)
		,@dblRetainedCredit		 NUMERIC (18,6)
		,@dblRetainedDebitUnit	 NUMERIC (18,6)
		,@dblRetainedCreditUnit	 NUMERIC (18,6)
		,@strRetainedAcctGroup	 NVARCHAR(50)  
		,@dtmDate				 DATETIME  
		,@strCurrencyID			 NVARCHAR(30)
		,@strBatchID			 NVARCHAR(100)
		,@strAccountID			 NVARCHAR(100)
		,@intAccountID			 INT
		
		,@intYear				INT
		,@dtmDateFrom			DATETIME
		,@dtmDateTo				DATETIME
		,@strRetainedAccount	NVARCHAR(50)	= ''
		
SET @intYear			= (SELECT TOP 1 CAST(strFiscalYear as INT) FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID) 		
SET @dtmDateFrom		= (SELECT TOP 1 dtmDateFrom FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID) 		
SET @dtmDateTo			= (SELECT TOP 1 dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID) 		
SET @strRetainedAccount = (SELECT TOP 1 strAccountID FROM tblGLAccount WHERE intAccountID = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID))

IF @ysnPost = 1 and @ysnRecap = 0
BEGIN
	UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE strModule = 'Posting'
	SET @strBatchID = (SELECT strPrefix + CAST(intNumber as NVARCHAR(20)) FROM tblSMStartingNumber WHERE strModule = 'Posting')
END

SELECT TOP 1 @strCurrencyID = ISNULL(strCurrency, 'USD') FROM tblSMCurrency WHERE strCurrency = 'USD'		

-- ++++++++ COMPUTATIONS ON GL ++++++++ --
--	Revenue, Sales	=	Credit - Debit
--	Expense, COGS	=	Debit  - Credit

INSERT INTO #ConstructGL
SELECT		
		dtmDate						= @dtmDateTo
		,strBatchID					= @strBatchID
		,intAccountID				= tblGLDetail.intAccountID
		,strAccountGroup			= (SELECT TOP 1 A.strAccountGroup  FROM tblGLAccountGroup A LEFT JOIN tblGLAccount B 
											ON A.intAccountGroupID = B.intAccountGroupID WHERE B.intAccountID = tblGLDetail.intAccountID)
		,dblDebit					=	CASE WHEN C.strAccountType = 'Revenue' or C.strAccountType = 'Sales' THEN (  
											CASE WHEN SUM((ISNULL(dblCredit,0) - ISNULL(dblDebit,0))) > 0 THEN ABS(SUM(ISNULL(dblCredit,0) - ISNULL(dblDebit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' or C.strAccountType = 'Cost of Goods Sold' THEN (  
											CASE WHEN SUM((ISNULL(dblDebit,0) - ISNULL(dblCredit,0))) < 0 THEN ABS(SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)))  
											ELSE 0 END)
											END 
		,dblCredit					=	CASE WHEN C.strAccountType = 'Revenue' or C.strAccountType = 'Sales' THEN (  
											CASE WHEN SUM((ISNULL(dblCredit,0) - ISNULL(dblDebit,0))) < 0 THEN ABS(SUM(ISNULL(dblCredit,0) - ISNULL(dblDebit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' or C.strAccountType = 'Cost of Goods Sold' THEN (  
											CASE WHEN SUM((ISNULL(dblDebit,0) - ISNULL(dblCredit,0))) > 0 THEN ABS(SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)))  
											ELSE 0 END)  
											END
		,dblDebitUnit				=	CASE WHEN C.strAccountType = 'Revenue' or C.strAccountType = 'Sales' THEN (  
											CASE WHEN SUM((ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0))) > 0 THEN ABS(SUM(ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' or C.strAccountType = 'Cost of Goods Sold' THEN (  
											CASE WHEN SUM((ISNULL(dblDebitUnit,0) - ISNULL(dblCreditUnit,0))) < 0 THEN ABS(SUM(ISNULL(dblDebitUnit,0) - ISNULL(dblCreditUnit,0)))  
											ELSE 0 END)
											END 
		,dblCreditUnit				=	CASE WHEN C.strAccountType = 'Revenue' or C.strAccountType = 'Sales' THEN (  
											CASE WHEN SUM((ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0))) < 0 THEN ABS(SUM(ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' or C.strAccountType = 'Cost of Goods Sold' THEN (  
											CASE WHEN SUM((ISNULL(dblDebitUnit,0) - ISNULL(dblCreditUnit,0))) > 0 THEN ABS(SUM(ISNULL(dblDebitUnit,0) - ISNULL(dblCreditUnit,0)))  
											ELSE 0 END)  
											END    
		,strGLDescription			= 'Closed Fiscal Year'
		,strCode					= 'CY'
		,strTransactionID			= CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount
		,strReference				= 'Fiscal Year'
		,strJobID					= NULL
		,intCurrencyID				= (SELECT intCurrencyID FROM tblSMCurrency WHERE strCurrency = @strCurrencyID)
		,dblExchangeRate			= (SELECT dblDailyRate FROM tblSMCurrency WHERE strCurrency = @strCurrencyID)		
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= @dtmDateTo
		,strProductID				= NULL
		,strWarehouseID				= NULL
		,strNum						= NULL
		,strCompanyName				= NULL
		,strBillInvoiceNumber		= NULL
		,strJournalLineDescription	= NULL
		,ysnIsUnposted				= 0
		,intConcurrencyID			= 1
		,intUserID					= @intUserID
		,strTransactionForm			= NULL
		,strModuleName				= NULL
		,strUOMCode					= NULL		
		
		,strAccountID				=	(SELECT TOP 1 strAccountID  FROM tblGLAccount  WHERE intAccountID = tblGLDetail.intAccountID)
		,strDescription				=	(SELECT TOP 1 strDescription  FROM tblGLAccount  WHERE intAccountID = tblGLDetail.intAccountID)			
		
FROM	tblGLDetail  LEFT JOIN tblGLAccount B 
			ON tblGLDetail.intAccountID = B.intAccountID 
		LEFT JOIN tblGLAccountGroup C
			ON B.intAccountGroupID = C.intAccountGroupID
WHERE	C.strAccountType IN ('Revenue','Sales', 'Expense','Cost of Goods Sold') 
		AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
		AND ysnIsUnposted = 0
		AND strCode <> 'AA' 
GROUP BY tblGLDetail.intAccountID, C.strAccountType


-- ++++++++ RETAINED EARNINGS for new Fiscal Year ++++++++ --
SET @intAccountID			= (SELECT intAccountID FROM tblGLAccount WHERE strAccountID = @strRetainedAccount)
SET @strRetainedAcctGroup	= ISNULL((SELECT TOP 1 strAccountGroup FROM tblGLAccount A
												LEFT JOIN tblGLAccountGroup B
												ON A.intAccountGroupID = B.intAccountGroupID WHERE A.strAccountID = @strRetainedAccount), '')
SET @dtmDate				= DATEADD(DAY, 1 ,CAST(FLOOR(CAST(CAST(@dtmDateTo AS DATETIME) AS NUMERIC(18,6))) AS DATETIME))
SET @dblRetained =   
(  
	SELECT  
	ISNULL((  
			SELECT	SUM(ISNULL(dblCredit, 0)) - SUM(ISNULL(dblDebit, 0))  
			FROM	tblGLDetail INNER JOIN tblGLAccount B
						ON tblGLDetail.intAccountID = B.intAccountID  
						LEFT JOIN tblGLAccountGroup C
						ON B.intAccountGroupID = C.intAccountGroupID
			WHERE	C.strAccountType IN ('Revenue','Sales')
					AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
					AND ysnIsUnposted = 0
					AND strCode <> 'AA'
		), 0) -   
	ISNULL((  
			SELECT	SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0))  
			FROM	tblGLDetail INNER JOIN tblGLAccount  B
						ON tblGLDetail.intAccountID = B.intAccountID  
						LEFT JOIN tblGLAccountGroup C
						ON B.intAccountGroupID = C.intAccountGroupID
			WHERE	C.strAccountType IN ('Expense','Cost of Goods Sold')
					AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
					AND ysnIsUnposted = 0
					AND strCode <> 'AA'
		), 0)  
)

SET @dblRetainedDebit = (SELECT SUM(dblDebit) as dblDebit FROM #ConstructGL)
SET @dblRetainedCredit = (SELECT SUM(dblCredit) as dblCredit FROM #ConstructGL)
SET @dblRetainedDebitUnit = (SELECT SUM(dblDebitUnit) as dblDebitUnit FROM #ConstructGL)
SET @dblRetainedCreditUnit = (SELECT SUM(dblCreditUnit) as dblCreditUnit FROM #ConstructGL)

IF @dblRetainedDebit > @dblRetainedCredit
BEGIN
	SET @dblRetainedCredit = ABS(@dblRetained)
	SET @dblRetainedDebit = 0
END
ELSE
BEGIN
	SET @dblRetainedCredit = 0
	SET @dblRetainedDebit = ABS(@dblRetained)	
END

INSERT INTO #ConstructGL
SELECT			
		dtmDate					= @dtmDateTo
		,strBatchID				= @strBatchID
		,intAccountID			= @intAccountID
		,strAccountGroup		= @strRetainedAcctGroup
		,dblDebit				= @dblRetainedDebit
		,dblCredit				= @dblRetainedCredit
		,dblDebitUnit			= @dblRetainedDebitUnit
		,dblCreditUnit			= @dblRetainedCreditUnit
		,strGLDescription		= 'Retained Earnings'
		,strCode				= 'RE'
		,strTransactionID		= CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount
		,strReference			= 'Fiscal Year'
		,strJobID				= NULL
		,intCurrencyID			= (SELECT intCurrencyID FROM tblSMCurrency WHERE strCurrency = @strCurrencyID)
		,dblExchangeRate		= (SELECT dblDailyRate FROM tblSMCurrency WHERE strCurrency = @strCurrencyID)		
		,dtmDateEntered			= GETDATE()
		,dtmTransactionDate		= @dtmDateTo
		,strProductID			= NULL
		,strWarehouseID			= NULL
		,strNum					= NULL
		,strCompanyName			= NULL
		,strBillInvoiceNumber	= NULL
		,strJournalLineDescription	= NULL
		,ysnIsUnposted			= 0
		,intConcurrencyID		= 1
		,intUserID				= @intUserID
		,strTransactionForm		= NULL
		,strModuleName			= NULL
		,strUOMCode				= NULL		
		
		,strAccountID			= @strRetainedAccount
		,strDescription			= (SELECT TOP 1 strDescription FROM tblGLAccount where strAccountID = @strRetainedAccount )


IF @ysnPost = 1 and @ysnRecap = 0
BEGIN
	-- +++++ INSERT TO GL TABLE +++++ --	
	INSERT INTO tblGLDetail
	SELECT   dtmDate
			,strBatchID
			,intAccountID
			,strAccountGroup
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strGLDescription as strDescription
			,strCode
			,strTransactionID
			,strReference
			,strJobID
			,intCurrencyID
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strProductID
			,strWarehouseID
			,strNum
			,strCompanyName
			,strBillInvoiceNumber
			,strJournalLineDescription
			,ysnIsUnposted
			,intConcurrencyID
			,intUserID
			,strTransactionForm
			,strModuleName
			,strUOMCode
	FROM #ConstructGL
	
	UPDATE tblGLFiscalYear SET ysnStatus = 0 WHERE intFiscalYearID = @intFiscalYearID	
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 0 where intFiscalYearID = @intFiscalYearID
END	
ELSE IF @ysnPost = 0 and @ysnRecap = 0
BEGIN
	INSERT INTO tblGLDetail (dtmDate,strBatchID,intAccountID,strAccountGroup,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDescription,strCode,strTransactionID,strReference,strJobID,intCurrencyID,dblExchangeRate,dtmDateEntered,dtmTransactionDate,strProductID,strWarehouseID,strNum,strCompanyName,strBillInvoiceNumber,strJournalLineDescription,ysnIsUnposted,intConcurrencyID,intUserID,strTransactionForm,strModuleName,strUOMCode)
	SELECT   dtmDate
			,strBatchID
			,intAccountID
			,strAccountGroup
			,dblCredit
			,dblDebit			
			,dblCreditUnit
			,dblDebitUnit
			,strDescription = CASE WHEN tblGLDetail.strCode = 'CY' THEN 'Opened Fiscal Year'
								   ELSE 'Retained Earnings'
								   END
			,strCode
			,strTransactionID
			,strReference
			,strJobID
			,intCurrencyID
			,dblExchangeRate
			,GETDATE() as dtmDateEntered
			,dtmTransactionDate
			,strProductID
			,strWarehouseID
			,strNum
			,strCompanyName
			,strBillInvoiceNumber
			,strJournalLineDescription
			,1 as ysnIsUnposted
			,intConcurrencyID
			,intUserID
			,strTransactionForm
			,strModuleName
			,strUOMCode
	FROM tblGLDetail
	WHERE strTransactionID = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	
	UPDATE tblGLDetail SET ysnIsUnposted = 1 WHERE strTransactionID = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	UPDATE tblGLFiscalYear SET ysnStatus = 1 WHERE intFiscalYearID = @intFiscalYearID
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 1 where intFiscalYearID = @intFiscalYearID
END


SELECT * FROM #ConstructGL
DROP TABLE #ConstructGL

