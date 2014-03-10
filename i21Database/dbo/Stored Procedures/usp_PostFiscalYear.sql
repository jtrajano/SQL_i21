
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[usp_PostFiscalYear]
	 @intFiscalYearID	AS INT
	,@ysnPost			AS BIT				= 0
	,@ysnRecap			AS BIT				= 0
	,@strBatchID		AS NVARCHAR(100)	= ''
	,@intUserID			AS INT				= 1
	,@successfulCount	AS INT				= 0 OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

BEGIN TRANSACTION;


--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
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
	,strCode					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NOT NULL
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
	,intJournalLineNo			INT
	,ysnIsUnposted				BIT
	,intConcurrencyId			INT
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
		,@intCurrencyID			 INT
		,@strAccountID			 NVARCHAR(100)
		,@intAccountID			 INT		
		,@dblDailyRate			 NUMERIC (18,6)
		
		,@intYear				INT
		,@dtmDateFrom			DATETIME
		,@dtmDateTo				DATETIME
		,@strRetainedAccount	NVARCHAR(50)	= ''
		
SET @intYear			= (SELECT TOP 1 CAST(strFiscalYear as INT) FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID) 		
SET @dtmDateFrom		= (SELECT TOP 1 dtmDateFrom FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID) 		
SET @dtmDateTo			= (SELECT TOP 1 dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID) 		
SET @strRetainedAccount = (SELECT TOP 1 strAccountID FROM tblGLAccount WHERE intAccountID = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE intFiscalYearID = @intFiscalYearID))
SET @intCurrencyID		= (SELECT TOP 1 ISNULL(intCurrencyID, (SELECT intCurrencyID FROm tblSMCurrency WHERE strCurrency = 'USD')) FROM tblSMCurrency WHERE intCurrencyID = (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency'))
SET @dblDailyRate		= (SELECT dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyID)


--=====================================================================================================================================
-- 	COMPUTATIONS ON GL
---------------------------------------------------------------------------------------------------------------------------------------
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
		,intCurrencyID				= @intCurrencyID
		,dblExchangeRate			= @dblDailyRate		
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= @dtmDateTo
		,strProductID				= NULL
		,strWarehouseID				= NULL
		,strNum						= NULL
		,strCompanyName				= NULL
		,strBillInvoiceNumber		= NULL
		,strJournalLineDescription	= NULL
		,intJournalLineNo			= 0
		,ysnIsUnposted				= 0
		,intConcurrencyId			= 1
		,intUserID					= @intUserID
		,strTransactionForm			= 'Fiscal Year'
		,strModuleName				= 'General Ledger'
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
		--AND strCode <> 'AA' 
GROUP BY tblGLDetail.intAccountID, C.strAccountType


--=====================================================================================================================================
-- 	RETAINED EARNINGS for new Fiscal Year
---------------------------------------------------------------------------------------------------------------------------------------
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
					-- AND strCode <> 'AA'
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
					-- AND strCode <> 'AA'
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
		,dblDebitUnit			= 0
		,dblCreditUnit			= 0
		,strGLDescription		= 'Retained Earnings'
		,strCode				= 'RE'
		,strTransactionID		= CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount
		,strReference			= 'Fiscal Year'
		,strJobID				= NULL
		,intCurrencyID			= @intCurrencyID
		,dblExchangeRate		= @dblDailyRate		
		,dtmDateEntered			= GETDATE()
		,dtmTransactionDate		= @dtmDateTo
		,strProductID			= NULL
		,strWarehouseID			= NULL
		,strNum					= NULL
		,strCompanyName			= NULL
		,strBillInvoiceNumber	= NULL
		,strJournalLineDescription	= NULL
		,intJournalLineNo		= 0
		,ysnIsUnposted			= 0
		,intConcurrencyId		= 1
		,intUserID				= @intUserID
		,strTransactionForm		= 'Fiscal Year'
		,strModuleName			= 'General Ledger'
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
			,intJournalLineNo
			,ysnIsUnposted
			,intConcurrencyId
			,intUserID
			,strTransactionForm
			,strModuleName
			,strUOMCode
	FROM #ConstructGL
	
	UPDATE tblGLFiscalYear SET ysnStatus = 0 WHERE intFiscalYearID = @intFiscalYearID	
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 0 where intFiscalYearID = @intFiscalYearID
	
	IF @@ERROR <> 0	GOTO Post_Rollback;
END	
ELSE IF @ysnPost = 0 and @ysnRecap = 0
BEGIN
	INSERT INTO tblGLDetail (dtmDate,strBatchID,intAccountID,strAccountGroup,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strDescription,strCode,strTransactionID,strReference,strJobID,intCurrencyID,dblExchangeRate,dtmDateEntered,dtmTransactionDate,strProductID,strWarehouseID,strNum,strCompanyName,strBillInvoiceNumber,strJournalLineDescription,intJournalLineNo,ysnIsUnposted,intConcurrencyId,intUserID,strTransactionForm,strModuleName,strUOMCode)
	SELECT   dtmDate
			,@strBatchID
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
			,intJournalLineNo
			,1 as ysnIsUnposted
			,intConcurrencyId
			,intUserID
			,strTransactionForm
			,strModuleName
			,strUOMCode
	FROM tblGLDetail
	WHERE strTransactionID = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	
	UPDATE tblGLDetail SET ysnIsUnposted = 1 WHERE strTransactionID = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	UPDATE tblGLFiscalYear SET ysnStatus = 1 WHERE intFiscalYearID = @intFiscalYearID
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 1 where intFiscalYearID = @intFiscalYearID
	
	IF @@ERROR <> 0	GOTO Post_Rollback;
END
ELSE IF @ysnPost = 1 and @ysnRecap = 1
BEGIN
	-- DELETE Results 1 DAYS OLDER	
	DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intUserID = @intUserID;
	
	WITH Accounts 
	AS 
	(
		SELECT A.[strAccountID], A.[intAccountID], A.[intAccountGroupID], B.[strAccountGroup], C.[dblLbsPerUnit]
		FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupID = B.intAccountGroupID
							LEFT JOIN tblGLAccountUnit  C on C.intAccountUnitID  = A.intAccountUnitID
	)
	INSERT INTO tblGLPostRecap (
		 [strTransactionID]
		,[intTransactionID]
		,[intAccountID]
		,[strAccountID]
		,[strAccountGroup]
		,[strDescription]
		,[strReference]	
		,[dtmTransactionDate]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[dtmDate]
		,[ysnIsUnposted]
		,[intConcurrencyId]	
		,[dblExchangeRate]
		,[intUserID]
		,[dtmDateEntered]
		,[strBatchID]
		,[strCode]
		,[strModuleName]
		,[strTransactionForm]
	)
	SELECT 
		 @strBatchID
		,@intFiscalYearID
		,intAccountID
		,strAccountID
		,strAccountGroup
		,strDescription
		,strReference
		,dtmTransactionDate
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,dtmDate
		,ysnIsUnposted
		,intConcurrencyId
		,dblExchangeRate
		,intUserID
		,dtmDateEntered
		,@strBatchID
		,strCode
		,strModuleName
		,strTransactionForm
	FROM #ConstructGL

	IF @@ERROR <> 0	GOTO Post_Rollback;
	
	GOTO Post_Commit;
	
END

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE	tblGLSummary 
SET		 [dblDebit]			= ISNULL(tblGLSummary.[dblDebit], 0) + ISNULL(GLDetailGrouped.[dblDebit], 0)
		,[dblCredit]		= ISNULL(tblGLSummary.[dblCredit], 0) + ISNULL(GLDetailGrouped.[dblCredit], 0)
		,[dblDebitUnit]		= ISNULL(tblGLSummary.[dblDebitUnit], 0) + ISNULL(GLDetailGrouped.[dblDebitUnit], 0)
		,[dblCreditUnit]	= ISNULL(tblGLSummary.[dblCreditUnit], 0) + ISNULL(GLDetailGrouped.[dblCreditUnit], 0)
		,[intConcurrencyId] = ISNULL([intConcurrencyId], 0) + 1
FROM	(
			SELECT	 [dblDebit]			= SUM(ISNULL(B.[dblDebit], 0))
					,[dblCredit]		= SUM(ISNULL(B.[dblCredit], 0))
					,[dblDebitUnit]		= SUM(ISNULL(B.[dblDebitUnit], 0))
					,[dblCreditUnit]	= SUM(ISNULL(B.[dblCreditUnit], 0))
					,[intAccountID]		= A.[intAccountID]
					,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '')
					,A.[strCode] 								
			FROM tblGLSummary A 
					INNER JOIN tblGLDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountID] = B.[intAccountID] AND A.[strCode] = B.[strCode] AND B.[strBatchID] = @strBatchID
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID],A.[strCode]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountID] = GLDetailGrouped.[intAccountID] AND tblGLSummary.[strCode] = GLDetailGrouped.[strCode] AND 
	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	INSERT TO GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
WITH Units
AS 
(
	SELECT	A.[dblLbsPerUnit], B.[intAccountID] 
	FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.[intAccountUnitID] = B.[intAccountUnitID]
)
INSERT INTO tblGLSummary (
	 [intAccountID]
	,[dtmDate]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
	,[strCode]
	,[intConcurrencyId]
)
SELECT	
	 [intAccountID]		= A.[intAccountID]
	,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '')
	,[dblDebit]			= SUM(A.[dblDebit])
	,[dblCredit]		= SUM(A.[dblCredit])
	,[dblDebitUnit]		= SUM(A.[dblDebitUnit])
	,[dblCreditUnit]	= SUM(A.[dblCreditUnit])
	,[strCode] = A.[strCode]
	,[intConcurrencyId] = 1
FROM #ConstructGL A
WHERE NOT EXISTS 
		(
			SELECT TOP 1 1
			FROM tblGLSummary B
			WHERE ISNULL(CONVERT(DATE, A.[dtmDate]), '') = ISNULL(CONVERT(DATE, B.[dtmDate]), '') AND 
				  A.[intAccountID] = B.[intAccountID] AND B.[strCode] = A.[strCode]
		)
GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountID], A.[strCode];

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION		            
	GOTO Post_Exit

Post_Exit:
	SET @successfulCount = 1;
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#ConstructGL')) DROP TABLE #ConstructGL


GO



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[usp_PostFiscalYear]
--			@intFiscalYearID	 = 2,
--			@ysnPost = 0,
--			@ysnRecap = 0,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@strBatchID = 'BATCH-122',							-- COMMA DELIMITED JOURNAL ID TO POST 
--			@intUserID = 1,							-- USER ID THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
