
--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspGLPostFiscalYear]
	 @intFiscalYearId	AS INT
	,@ysnPost			AS BIT				= 0
	,@ysnRecap			AS BIT				= 0
	,@strBatchId		AS NVARCHAR(100)	= ''
	,@intEntityId		AS INT				= 1
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
	,strBatchId					NVARCHAR(100)
	,intAccountId				INT
	,strAccountGroup			NVARCHAR(50)
	,dblDebit					NUMERIC(18, 6)
	,dblCredit					NUMERIC(18, 6)
	,dblDebitUnit				NUMERIC(18, 6)
	,dblCreditUnit				NUMERIC(18, 6)
	,strGLDescription			NVARCHAR(300)
	,strCode					NVARCHAR(50)	COLLATE Latin1_General_CI_AS NOT NULL
	,strTransactionId			NVARCHAR(100)
	,intTransactionId			INT
	,strReference				NVARCHAR(500)
	,intCurrencyId				INT
	,dblExchangeRate			NUMERIC(18, 6)
	,dtmDateEntered				DATETIME
	,dtmTransactionDate			DATETIME
	,strJournalLineDescription	NVARCHAR(500)
	,intJournalLineNo			INT
	,ysnIsUnposted				BIT
	,intConcurrencyId			INT
	,intUserId					INT
	,intEntityId				INT	
	,strTransactionType			NVARCHAR(510)
	,strTransactionForm			NVARCHAR(510)
	,strModuleName				NVARCHAR(510)
	
	,strAccountId				NVARCHAR(100)
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
		,@strCurrencyId			 NVARCHAR(30)
		,@intCurrencyId			 INT
		,@strAccountId			 NVARCHAR(100)
		,@intAccountId			 INT		
		,@dblDailyRate			 NUMERIC (18,6)
		
		,@intYear				INT
		,@dtmDateFrom			DATETIME
		,@dtmDateTo				DATETIME
		,@strRetainedAccount	NVARCHAR(50)	= ''
		
SET @intYear			= (SELECT TOP 1 CAST(strFiscalYear as INT) FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId) 		
SET @dtmDateFrom		= (SELECT TOP 1 dtmDateFrom FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId) 		
SET @dtmDateTo			= (SELECT TOP 1 dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId) 		
SET @strRetainedAccount = (SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId))
SET @intCurrencyId		= (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))
SET @dblDailyRate		= (SELECT dblDailyRate FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId)

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	COMPUTATIONS ON GL
---------------------------------------------------------------------------------------------------------------------------------------
--	Revenue, Sales	=	Credit - Debit
--	Expense, COGS	=	Debit  - Credit

INSERT INTO #ConstructGL
SELECT		
		dtmDate						= @dtmDateTo
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLDetail.intAccountId
		,strAccountGroup			= (SELECT TOP 1 A.strAccountGroup  FROM tblGLAccountGroup A LEFT JOIN tblGLAccount B 
											ON A.intAccountGroupId = B.intAccountGroupId WHERE B.intAccountId = tblGLDetail.intAccountId)
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
		,strTransactionId			= CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount
		,intTransactionId			= @intFiscalYearId
		,strReference				= 'Fiscal Year'
		,intCurrencyId				= intCurrencyId
		,dblExchangeRate			= dblExchangeRate		
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= @dtmDateTo
		,strJournalLineDescription	= NULL
		,intJournalLineNo			= 0
		,ysnIsUnposted				= 0
		,intConcurrencyId			= 1
		,intUserId					= 0
		,intEntityId				= @intEntityId		
		,strTransactionType			= 'Fiscal Year'
		,strTransactionForm			= 'Fiscal Year'
		,strModuleName				= 'General Ledger'
		
		,strAccountId				=	(SELECT TOP 1 strAccountId  FROM tblGLAccount  WHERE intAccountId = tblGLDetail.intAccountId)
		,strDescription				=	(SELECT TOP 1 strDescription  FROM tblGLAccount  WHERE intAccountId = tblGLDetail.intAccountId)			
		
FROM	tblGLDetail  LEFT JOIN tblGLAccount B 
			ON tblGLDetail.intAccountId = B.intAccountId 
		LEFT JOIN tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
WHERE	C.strAccountType IN ('Revenue','Sales', 'Expense','Cost of Goods Sold') 
		AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
		AND ysnIsUnposted = 0
		AND tblGLDetail.intGLDetailId NOT IN (SELECT intGLDetailId FROM (
							SELECT SUM(ABS(dblCredit) + ABS(dblDebit) + ABS(dblCreditUnit) + ABS(dblDebitUnit)) as dblTotal, intGLDetailId FROM tblGLDetail  
								WHERE FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
									AND ysnIsUnposted = 0 
								GROUP BY intGLDetailId) A 
					WHERE dblTotal = 0)
GROUP BY tblGLDetail.intAccountId, C.strAccountType, tblGLDetail.intCurrencyId, tblGLDetail.dblExchangeRate

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETAINED EARNINGS for new Fiscal Year
---------------------------------------------------------------------------------------------------------------------------------------
SET @intAccountId			= (SELECT intAccountId FROM tblGLAccount WHERE strAccountId = @strRetainedAccount)
SET @strRetainedAcctGroup	= ISNULL((SELECT TOP 1 strAccountGroup FROM tblGLAccount A
												LEFT JOIN tblGLAccountGroup B
												ON A.intAccountGroupId = B.intAccountGroupId WHERE A.strAccountId = @strRetainedAccount), '')
SET @dtmDate				= DATEADD(DAY, 1 ,CAST(FLOOR(CAST(CAST(@dtmDateTo AS DATETIME) AS NUMERIC(18,6))) AS DATETIME))
SET @dblRetained =   
(  
	SELECT  
	ISNULL((  
			SELECT	SUM(ISNULL(dblCredit, 0)) - SUM(ISNULL(dblDebit, 0))  
			FROM	tblGLDetail INNER JOIN tblGLAccount B
						ON tblGLDetail.intAccountId = B.intAccountId  
						LEFT JOIN tblGLAccountGroup C
						ON B.intAccountGroupId = C.intAccountGroupId
			WHERE	C.strAccountType IN ('Revenue','Sales')
					AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
					AND ysnIsUnposted = 0
		), 0) -   
	ISNULL((  
			SELECT	SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0))  
			FROM	tblGLDetail INNER JOIN tblGLAccount  B
						ON tblGLDetail.intAccountId = B.intAccountId  
						LEFT JOIN tblGLAccountGroup C
						ON B.intAccountGroupId = C.intAccountGroupId
			WHERE	C.strAccountType IN ('Expense','Cost of Goods Sold')
					AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
					AND ysnIsUnposted = 0
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
		,strBatchId				= @strBatchId
		,intAccountId			= @intAccountId
		,strAccountGroup		= @strRetainedAcctGroup
		,dblDebit				= @dblRetainedDebit
		,dblCredit				= @dblRetainedCredit
		,dblDebitUnit			= 0
		,dblCreditUnit			= 0
		,strGLDescription		= 'Retained Earnings'
		,strCode				= 'RE'
		,strTransactionId		= CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount
		,intTransactionId		= @intFiscalYearId
		,strReference			= 'Fiscal Year'
		,intCurrencyId			= @intCurrencyId
		,dblExchangeRate		= @dblDailyRate		
		,dtmDateEntered			= GETDATE()
		,dtmTransactionDate		= @dtmDateTo
		,strJournalLineDescription	= NULL
		,intJournalLineNo		= 0
		,ysnIsUnposted			= 0
		,intConcurrencyId		= 1
		,intUserId				= 0
		,intEntityId			= @intEntityId		
		,strTransactionType		= 'Fiscal Year'
		,strTransactionForm		= 'Fiscal Year'
		,strModuleName			= 'General Ledger'
		
		,strAccountId			= @strRetainedAccount
		,strDescription			= (SELECT TOP 1 strDescription FROM tblGLAccount where strAccountId = @strRetainedAccount )


IF @ysnPost = 1 and @ysnRecap = 0
BEGIN
	-- +++++ INSERT TO GL TABLE +++++ --	
	INSERT INTO tblGLDetail( 
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strTransactionId
			,intTransactionId
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intConcurrencyId
			,intUserId
			,intEntityId
			,strTransactionType
			,strTransactionForm
			,strModuleName
	)
	SELECT   dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strGLDescription as strDescription
			,strCode
			,strTransactionId
			,intTransactionId
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate			
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intConcurrencyId
			,intUserId
			,intEntityId			
			,strTransactionType
			,strTransactionForm
			,strModuleName
	FROM #ConstructGL
	
	IF @@ERROR <> 0	GOTO Post_Rollback;
	
	UPDATE tblGLFiscalYear SET ysnStatus = 0 WHERE intFiscalYearId = @intFiscalYearId	
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 0 where intFiscalYearId = @intFiscalYearId
	
	IF @@ERROR <> 0	GOTO Post_Rollback;
END	
ELSE IF @ysnPost = 0 and @ysnRecap = 0
BEGIN
	INSERT INTO tblGLDetail ( 
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strTransactionId
			,intTransactionId
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intConcurrencyId
			,intUserId
			,intEntityId
			,strTransactionType
			,strTransactionForm
			,strModuleName
	)
	SELECT   dtmDate
			,@strBatchId
			,intAccountId
			,dblCredit
			,dblDebit			
			,dblCreditUnit
			,dblDebitUnit
			,strDescription = CASE WHEN tblGLDetail.strCode = 'CY' THEN 'Opened Fiscal Year'
								   ELSE 'Retained Earnings'
								   END
			,strCode
			,strTransactionId
			,intTransactionId
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,GETDATE() as dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,1 as ysnIsUnposted
			,intConcurrencyId
			,intUserId
			,intEntityId			
			,strTransactionType
			,strTransactionForm
			,strModuleName
	FROM tblGLDetail
	WHERE strTransactionId = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	
	UPDATE tblGLDetail SET ysnIsUnposted = 1 WHERE strTransactionId = CAST(@intYear as NVARCHAR(10)) + '-' + @strRetainedAccount and ysnIsUnposted = 0
	UPDATE tblGLFiscalYear SET ysnStatus = 1 WHERE intFiscalYearId = @intFiscalYearId
	UPDATE tblGLFiscalYearPeriod SET ysnOpen = 1 where intFiscalYearId = @intFiscalYearId
	
	IF @@ERROR <> 0	GOTO Post_Rollback;
END
ELSE IF @ysnPost = 1 and @ysnRecap = 1
BEGIN
	-- DELETE Results 1 DAYS OLDER	
	DELETE tblGLPostRecap WHERE dtmDateEntered < DATEADD(day, -1, GETDATE()) and intEntityId = @intEntityId;
	
	WITH Accounts 
	AS 
	(
		SELECT A.[strAccountId], A.[intAccountId], A.[intAccountGroupId], B.[strAccountGroup]
		FROM tblGLAccount A LEFT JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId
	)
	INSERT INTO tblGLPostRecap (
		 [strTransactionId]
		,[intTransactionId]
		,[intAccountId]
		,[strAccountId]
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
		,[intUserId]
		,[intEntityId]		
		,[dtmDateEntered]
		,[strBatchId]
		,[strCode]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
	)
	SELECT 
		 @strBatchId
		,@intFiscalYearId
		,intAccountId
		,strAccountId
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
		,intUserId
		,intEntityId		
		,dtmDateEntered
		,@strBatchId
		,strCode
		,strTransactionType
		,strTransactionForm
		,strModuleName		
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
					,[intAccountId]		= A.[intAccountId]
					,[dtmDate]			= ISNULL(CONVERT(DATE, A.[dtmDate]), '')
					,A.[strCode] 								
			FROM tblGLSummary A 
					INNER JOIN tblGLDetail B 
					ON CONVERT(DATE, A.[dtmDate]) = CONVERT(DATE, B.[dtmDate]) AND A.[intAccountId] = B.[intAccountId] AND A.[strCode] = B.[strCode] AND B.[strBatchId] = @strBatchId
			GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId],A.[strCode]
		) AS GLDetailGrouped
WHERE tblGLSummary.[intAccountId] = GLDetailGrouped.[intAccountId] AND tblGLSummary.[strCode] = GLDetailGrouped.[strCode] AND 
	  ISNULL(CONVERT(DATE, tblGLSummary.[dtmDate]), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.[dtmDate]), '');

IF @@ERROR <> 0	GOTO Post_Rollback;


--=====================================================================================================================================
-- 	INSERT TO GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO tblGLSummary (
	 [intAccountId]
	,[dtmDate]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
	,[strCode]
	,[intConcurrencyId]
)
SELECT	
	 [intAccountId]		= A.[intAccountId]
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
				  A.[intAccountId] = B.[intAccountId] AND B.[strCode] = A.[strCode]
		)
GROUP BY ISNULL(CONVERT(DATE, A.[dtmDate]), ''), A.[intAccountId], A.[strCode];

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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#ConstructGL')) DROP TABLE #ConstructGL


GO



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[uspGLPostFiscalYear]
--			@intFiscalYearId	 = 10,
--			@ysnPost = 1,
--			@ysnRecap = 1,								-- WHEN SET TO 1, THEN IT WILL POPULATE tblGLPostRecap THAT CAN BE VIEWED VIA BUFFERED STORE IN SENCHA
--			@strBatchId = 'BATCH-2011',							-- COMMA DELIMITED JOURNAL Id TO POST 
--			@intEntityId = 1,							-- USER Id THAT INITIATES POSTING
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @intCount
