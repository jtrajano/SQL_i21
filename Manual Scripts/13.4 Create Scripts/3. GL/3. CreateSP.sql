
GO
/****** Object:  StoredProcedure [dbo].[usp_BuildGLAccountTemporary]    Script Date: 10/07/2013 18:00:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BuildGLAccountTemporary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_BuildGLAccountTemporary
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------*/
/* CREATE THE PROCEDURE */
/*----------------------*/

CREATE PROCEDURE  [dbo].[usp_BuildGLAccountTemporary]
@intUserID INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

CREATE TABLE #TempResults
(
	 strCode					NVARCHAR(50)
	,strPrimary					NVARCHAR(50)
	,strSegment					NVARCHAR(50)
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)
    ,intAccountGroupID			INT
    ,intAccountSegmentID		INT
    ,intAccountStructureID		INT
    ,strAccountSegmentID		NVARCHAR(100)
)

CREATE TABLE #PrimaryAccounts
(
	 strCode					NVARCHAR(50)
	,strPrimary					NVARCHAR(50)
	,strSegment					NVARCHAR(50)
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)	
    ,intAccountGroupID			INT
    ,intAccountSegmentID		INT
    ,intAccountStructureID		INT
    ,strAccountSegmentID		NVARCHAR(100)
)

INSERT INTO #PrimaryAccounts
SELECT a.strCode,'', '', a.strDescription, b.strAccountGroup, a.intAccountGroupID, x.intAccountSegmentID, a.intAccountStructureID, x.intAccountSegmentID AS strAccountSegmentID
FROM tblGLTempAccountToBuild x
LEFT JOIN tblGLAccountSegment a 
ON x.intAccountSegmentID = a.intAccountSegmentID
LEFT JOIN tblGLAccountGroup b
ON a.intAccountGroupID = b.intAccountGroupID
LEFT JOIN tblGLAccountStructure c
ON a.intAccountStructureID = c.intAccountStructureID
WHERE x.intUserID = @intUserID and c.strType = 'Primary'

CREATE TABLE #ConstructAccount
(
	 strCode					NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
	,strPrimary					NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
	,strSegment					NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
	,strDescription				NVARCHAR(300)
	,strAccountGroup			NVARCHAR(50)
	,intAccountGroupID			INT
	,intAccountSegmentID		INT
	,intAccountStructureID		INT
	,strAccountSegmentID		NVARCHAR(100)
)

CREATE TABLE #Structure
(
	 strMask				NVARCHAR(100)
	,strType				NVARCHAR(17)
	,intAccountStructureID	INT
)

IF (SELECT TOP 1 strType FROM tblGLAccountStructure WHERE intSort = 1) = 'Primary'
	BEGIN 
		INSERT INTO #Structure 
		SELECT strMask, strType, intAccountStructureID
		FROM tblGLAccountStructure WHERE strType <> 'Divider'
		ORDER BY intSort DESC
	END
ELSE
	BEGIN
		INSERT INTO #Structure 
		SELECT strMask, strType, intAccountStructureID
		FROM tblGLAccountStructure WHERE strType <> 'Divider'
		ORDER BY intSort DESC
	END

CREATE TABLE #Segments
(
	 strCode 					NVARCHAR(150)
	,strDescription 	        NVARCHAR(300)
    ,intAccountStructureID		INT
	,intAccountSegmentID		INT
	,strAccountSegmentID		NVARCHAR(100)
)


INSERT INTO #Segments
SELECT a.strCode, a.strDescription, a.intAccountStructureID, a.intAccountSegmentID, a.intAccountSegmentID AS strAccountSegmentID
FROM tblGLTempAccountToBuild x
LEFT JOIN tblGLAccountSegment a 
ON x.intAccountSegmentID = a.intAccountSegmentID
LEFT JOIN tblGLAccountStructure c
ON a.intAccountStructureID = c.intAccountStructureID
WHERE x.intUserID = @intUserID and c.strType = 'Segment'
ORDER BY a.strCode

DECLARE @iStructureType INT
DECLARE @strType		NVARCHAR(20)
DECLARE @strMask		NVARCHAR(50)
DECLARE @strDivider		NVARCHAR(10)

SET @strDivider = (Select Top 1 strMask from tblGLAccountStructure where strType = 'Divider')

WHILE EXISTS(SELECT 1 FROM #Structure)
BEGIN
	SELECT @strMask = strMask, @strType = strType, @iStructureType = intAccountStructureID FROM #Structure
	IF @strType = 'Primary' 
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM #ConstructAccount)
			 BEGIN
				TRUNCATE TABLE #TempResults
								
				INSERT INTO #TempResults
				SELECT PA.strCode, REPLICATE('0',(select intStartingPosition from tblGLAccountStructure where strType = 'Primary')) + PA.strCode AS strPrimary, '' as strSegment, PA.strDescription,
					PA.strAccountGroup, PA.intAccountGroupID, PA.intAccountStructureID, PA.intAccountSegmentID, PA.intAccountSegmentID AS strAccountSegmentID
				FROM #PrimaryAccounts PA
			 END
			ELSE
			 BEGIN
				IF EXISTS (SELECT 1 FROM #PrimaryAccounts)
				BEGIN
					TRUNCATE TABLE #TempResults
				
					INSERT INTO #TempResults
					SELECT CA.strCode + @strDivider + PA.strCode AS strCode, CA.strPrimary + @strDivider + PA.strCode AS strPrimary, '' as strSegment, CA.strDescription + @strDivider + PA.strDescription AS strDescription,
						PA.strAccountGroup, PA.intAccountGroupID, PA.intAccountStructureID, PA.intAccountSegmentID, PA.intAccountSegmentID AS strAccountSegmentID
					FROM #ConstructAccount CA, #PrimaryAccounts PA
					WHERE PA.intAccountStructureID = @iStructureType
				END
			 END
			DELETE FROM #PrimaryAccounts WHERE intAccountStructureID = @iStructureType
		END

	ELSE IF @strType = 'Segment'
		BEGIN
			IF EXISTS(SELECT 1 FROM #Segments WHERE intAccountStructureID = @iStructureType) AND EXISTS (SELECT 1 FROM #Segments)
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM #ConstructAccount)
					 BEGIN
  						INSERT INTO #TempResults ([strCode], [strPrimary], [strSegment], [strDescription], [intAccountStructureID], [intAccountSegmentID], [strAccountSegmentID])
						SELECT S.strCode, S.strCode, S.strCode, S.strDescription, S.intAccountStructureID, S.intAccountSegmentID, S.intAccountSegmentID AS strAccountSegmentID FROM #Segments S  
						WHERE S.intAccountStructureID = @iStructureType										
					 END
					ELSE
					 BEGIN
						IF EXISTS (SELECT 1 FROM #Segments) 
						BEGIN
							TRUNCATE TABLE #TempResults

							INSERT INTO #TempResults ([strCode], [strPrimary], [strSegment], [strDescription], [strAccountGroup], [intAccountGroupID], [intAccountStructureID], [intAccountSegmentID], [strAccountSegmentID])
							SELECT CA.strCode + @strDivider + S.strCode AS strCode, strPrimary, CA.strSegment + '' + S.strCode AS strSegment, CA.strDescription + @strDivider + S.strDescription AS strDescription
								 ,CA.strAccountGroup, CA.intAccountGroupID, CA.intAccountStructureID, S.intAccountSegmentID, CA.strAccountSegmentID + ';' + CAST(S.intAccountSegmentID as NVARCHAR(50)) AS strAccountSegmentID
							FROM #ConstructAccount CA, #Segments S
							WHERE S.intAccountStructureID = @iStructureType  							
					    END
					 END
					DELETE FROM #Segments WHERE intAccountStructureID = @iStructureType
				END
			ELSE
				BEGIN
					DELETE FROM #Structure
				END
		END

	TRUNCATE TABLE #ConstructAccount

	INSERT INTO #ConstructAccount
	SELECT strCode,strPrimary,strSegment,strDescription,strAccountGroup,intAccountGroupID,intAccountSegmentID,intAccountStructureID,strAccountSegmentID FROM #TempResults

	DELETE FROM #Structure WHERE intAccountStructureID = @iStructureType	
END

IF EXISTS (SELECT * FROM tblGLTempAccount WHERE intUserID = @intUserID)
BEGIN
	DELETE tblGLTempAccount WHERE intUserID = @intUserID
END

INSERT INTO tblGLTempAccount
SELECT strCode AS strAccountID, 
	   strPrimary, 
	   strSegment,
	   strDescription,
	   strAccountGroup,
	   intAccountGroupID,
	   strAccountSegmentID,
	   @intUserID AS intUserID,
	   dtmCreated = getDate()
FROM #ConstructAccount
WHERE strCode COLLATE DATABASE_DEFAULT NOT IN (SELECT strAccountID COLLATE DATABASE_DEFAULT FROM tblGLAccount)	   
ORDER BY strCode		


DROP TABLE #TempResults
DROP TABLE #PrimaryAccounts
DROP TABLE #Structure	
DROP TABLE #Segments
DROP TABLE #ConstructAccount

DELETE tblGLTempAccountToBuild WHERE intUserID = @intUserID

select 1
GO
/****** Object:  StoredProcedure [dbo].[usp_SyncAccounts]    Script Date: 10/07/2013 18:00:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SyncAccounts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_SyncAccounts
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[usp_SyncAccounts]
@intUserID INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

IF NOT EXISTS(SELECT 1 FROM tblGLCOACrossReference)
BEGIN
	DELETE glactmst	
END

BEGIN	
	-- +++++ TO TEMP TABLE +++++ --
	SELECT * INTO #TempUpdateCrossReference
	FROM tblGLCOACrossReference WHERE intLegacyReferenceID IS NULL

	-- +++++ SYNC ACCOUNTS +++++ --
	WHILE EXISTS(SELECT 1 FROM #TempUpdateCrossReference)
	BEGIN
		Declare @ID_update INT = (SELECT TOP 1 inti21ID FROM #TempUpdateCrossReference)
		Declare @ACCOUNT_update varchar(200) = (SELECT TOP 1 REPLACE(strCurrentExternalID,'-','') FROM #TempUpdateCrossReference WHERE inti21ID = @ID_update)
		Declare @TYPE_update varchar(200) = (SELECT TOP 1 strAccountType FROM tblGLAccount LEFT JOIN tblGLAccountGroup ON tblGLAccount.intAccountGroupID = tblGLAccountGroup.intAccountGroupID WHERE intAccountID = @ID_update)
		Declare @ACTIVE_update BIT = (SELECT TOP 1 ysnActive FROM tblGLAccount WHERE intAccountID = @ID_update)
		Declare @DESCRIPTION_update varchar(500) = (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountID = @ID_update)
		Declare @LegacyType_update varchar(200) = ''
		Declare @LegacySide_update varchar(200) = ''
		Declare @LegacyActive_update varchar(200) = 'N'
		
		IF @ACTIVE_update = 1
			BEGIN
				SET @LegacyActive_update = 'Y'
			END

		IF @TYPE_update = 'Asset'
			BEGIN
				SET @LegacyType_update = 'A'
				SET @LegacySide_update = 'D'
			END
		ELSE IF @TYPE_update = 'Liability'
			BEGIN
				SET @LegacyType_update = 'L'
				SET @LegacySide_update = 'C'
			END
		ELSE IF @TYPE_update = 'Equity'
			BEGIN
				SET @LegacyType_update = 'Q'
				SET @LegacySide_update = 'D'
			END
		ELSE IF @TYPE_update = 'Revenue'
			BEGIN
				SET @LegacyType_update = 'I'
				SET @LegacySide_update = 'C'
			END
		ELSE IF @TYPE_update = 'Expense'
			BEGIN
				SET @LegacyType_update = 'E'
				SET @LegacySide_update = 'D'
			END
		ELSE IF @TYPE_update = 'Cost of Goods Sold'
			BEGIN
				SET @LegacyType_update = 'C'
				SET @LegacySide_update = 'D'
			END
		ELSE IF @TYPE_update = 'Sales'
			BEGIN
				SET @LegacyType_update = 'I'
				SET @LegacySide_update = 'C'
			END
		
		INSERT INTO glactmst (
			[glact_acct1_8],
			[glact_acct9_16],
			[glact_desc],
			[glact_type],
			[glact_normal_value],
			[glact_saf_cat],
			[glact_flow_cat],
			[glact_uom],
			[glact_verify_flag],
			[glact_active_yn],
			[glact_sys_acct_yn],
			[glact_desc_lookup],
			[glact_user_fld_1],
			[glact_user_fld_2],
			[glact_user_id],
			[glact_user_rev_dt]
			)
		VALUES (
			CONVERT(INT, SUBSTRING(@ACCOUNT_update,1,8)),
			CONVERT(INT, SUBSTRING(@ACCOUNT_update,9,16)),
			SUBSTRING(@DESCRIPTION_update,0,30),
			@LegacyType_update,
			@LegacySide_update,
			'',
			'',
			'',
			'',
			@LegacyActive_update,
			'N',
			'',
			'',
			'',
			@intUserID,
			CONVERT(INT, CONVERT(VARCHAR(8), GETDATE(), 112))
			)
					
			UPDATE tblGLCOACrossReference SET intLegacyReferenceID = (SELECT TOP 1 A4GLIdentity FROM glactmst ORDER BY A4GLIdentity DESC) WHERE inti21ID = @ID_update		
			DELETE FROM #TempUpdateCrossReference WHERE inti21ID = @ID_update
	END		
END
	
select 1



--[usp_SyncAccounts] '130'
GO
/****** Object:  StoredProcedure [dbo].[usp_PostFiscalYear]    Script Date: 10/07/2013 18:00:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_PostFiscalYear]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_PostFiscalYear
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		dtmDate						= GETDATE()
		,strBatchID					= @strBatchID
		,intAccountID				= tblGLDetail.intAccountID
		,strAccountGroup			= (SELECT TOP 1 A.strAccountGroup  FROM tblGLAccountGroup A LEFT JOIN tblGLAccount B 
											ON A.intAccountGroupID = B.intAccountGroupID WHERE B.intAccountID = tblGLDetail.intAccountID)
		,dblDebit					=	CASE WHEN C.strAccountType = 'Revenue' THEN (  
											CASE WHEN SUM((ISNULL(dblCredit,0) - ISNULL(dblDebit,0))) > 0 THEN ABS(SUM(ISNULL(dblCredit,0) - ISNULL(dblDebit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' THEN (  
											CASE WHEN SUM((ISNULL(dblDebit,0) - ISNULL(dblCredit,0))) < 0 THEN ABS(SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)))  
											ELSE 0 END)
											END 
		,dblCredit					=	CASE WHEN C.strAccountType = 'Revenue' THEN (  
											CASE WHEN SUM((ISNULL(dblCredit,0) - ISNULL(dblDebit,0))) < 0 THEN ABS(SUM(ISNULL(dblCredit,0) - ISNULL(dblDebit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' THEN (  
											CASE WHEN SUM((ISNULL(dblDebit,0) - ISNULL(dblCredit,0))) > 0 THEN ABS(SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)))  
											ELSE 0 END)  
											END
		,dblDebitUnit				=	CASE WHEN C.strAccountType = 'Revenue' THEN (  
											CASE WHEN SUM((ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0))) > 0 THEN ABS(SUM(ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' THEN (  
											CASE WHEN SUM((ISNULL(dblDebitUnit,0) - ISNULL(dblCreditUnit,0))) < 0 THEN ABS(SUM(ISNULL(dblDebitUnit,0) - ISNULL(dblCreditUnit,0)))  
											ELSE 0 END)
											END 
		,dblCreditUnit				=	CASE WHEN C.strAccountType = 'Revenue' THEN (  
											CASE WHEN SUM((ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0))) < 0 THEN ABS(SUM(ISNULL(dblCreditUnit,0) - ISNULL(dblDebitUnit,0)))  
											ELSE 0 END)  
											WHEN C.strAccountType = 'Expense' THEN (  
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
WHERE	C.strAccountType IN ('Revenue', 'Expense') 
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
			WHERE	C.strAccountType = 'Revenue' 
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
			WHERE	C.strAccountType = 'Expense' 
					AND FLOOR(CAST(CAST(dtmDate AS DATETIME) AS NUMERIC(18,6))) BETWEEN  FLOOR(CAST(@dtmDateFrom AS NUMERIC(18,6))) AND FLOOR(CAST(@dtmDateTo AS NUMERIC(18,6)))
					AND ysnIsUnposted = 0
					AND strCode <> 'AA'
		), 0)  
)

SET @dblRetainedDebit = (SELECT SUM(dblDebit) as dblDebit FROM #ConstructGL)
SET @dblRetainedCredit = (SELECT SUM(dblCredit) as dblCredit FROM #ConstructGL)

IF @dblRetainedDebit > @dblRetainedCredit
BEGIN
	SET @dblRetainedCredit = @dblRetained
	SET @dblRetainedDebit = 0
END
ELSE
BEGIN
	SET @dblRetainedCredit = 0
	SET @dblRetainedDebit = @dblRetained	
END

INSERT INTO #ConstructGL
SELECT			
		dtmDate				= GETDATE()
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
GO
/****** Object:  StoredProcedure [dbo].[usp_BuildGLAccount]    Script Date: 10/07/2013 18:00:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_BuildGLAccount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_BuildGLAccount
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[usp_BuildGLAccount]
@intUserID nvarchar(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

-- +++++ INSERT ACCOUNT ID +++++ --
INSERT INTO tblGLAccount ([strAccountID],[strDescription],[intAccountGroupID], [ysnActive])
SELECT strAccountID, 
	   strDescription,
	   intAccountGroupID,
	   1
FROM tblGLTempAccount
WHERE intUserID = @intUserID and strAccountID NOT IN (SELECT strAccountID FROM tblGLAccount)	
ORDER BY strAccountID


-- +++++ INSERT CROSS REFERENCE +++++ --
INSERT INTO tblGLCOACrossReference ([inti21ID],[stri21ID],[strExternalID], [strCurrentExternalID], [strCompanyID], [intConcurrencyID])
SELECT (SELECT intAccountID FROM tblGLAccount A WHERE A.strAccountID = B.strAccountID) as inti21ID,
	   B.strAccountID as stri21ID,
	   B.strPrimary + '-' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strSegment as strExternalID , 	   
	   B.strPrimary + '-' + REPLICATE('0',(select 8 - SUM(intLength) from tblGLAccountStructure where strType = 'Segment')) + B.strSegment as strCurrentExternalID,
	   'Legacy' as strCompanyID,
	   1
FROM tblGLTempAccount B
WHERE intUserID = @intUserID and strAccountID NOT IN (SELECT stri21ID FROM tblGLCOACrossReference)	
ORDER BY strAccountID

-- +++++ INSERT SEGMENT MAPPING +++++ --
WHILE EXISTS(SELECT 1 FROM tblGLTempAccount WHERE intUserID = @intUserID)
BEGIN
	Declare @ID INT = (SELECT TOP 1 cntID FROM tblGLTempAccount WHERE intUserID = @intUserID)
	Declare @segmentcodes varchar(200) = (SELECT TOP 1 strAccountSegmentID FROM tblGLTempAccount WHERE intUserID = @intUserID)
	Declare @segmentID varchar(200) = null
	Declare @accountID INT = (SELECT TOP 1 intAccountID FROM tblGLAccount WHERE strAccountID = (SELECT TOP 1 strAccountID FROM tblGLTempAccount WHERE intUserID = @intUserID))

	WHILE LEN(@segmentcodes) > 0
	BEGIN
		IF PATINDEX('%;%',@segmentcodes) > 0
		BEGIN
			SET @segmentID = SUBSTRING(@segmentcodes, 0, PATINDEX('%;%',@segmentcodes))
			
			INSERT INTO tblGLAccountSegmentMapping ([intAccountID], [intAccountSegmentID]) values (@accountID, @segmentID)
			UPDATE tblGLAccountSegment SET ysnBuild = 1 WHERE intAccountSegmentID = @segmentID
			UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureID = (SELECT intAccountStructureID FROM tblGLAccountSegment WHERE intAccountSegmentID = @segmentID)

			SET @segmentcodes = SUBSTRING(@segmentcodes, LEN(@segmentID + ';') + 1, LEN(@segmentcodes))
		END
		ELSE
		BEGIN
			SET @segmentID = @segmentcodes
			SET @segmentcodes = NULL
			
			INSERT INTO tblGLAccountSegmentMapping ([intAccountID], [intAccountSegmentID]) values (@accountID, @segmentID)
			UPDATE tblGLAccountSegment SET ysnBuild = 1 WHERE intAccountSegmentID = @segmentID
			UPDATE tblGLAccountStructure SET ysnBuild = 1 WHERE intAccountStructureID = (SELECT intAccountStructureID FROM tblGLAccountSegment WHERE intAccountSegmentID = @segmentID)
			
			SELECT @segmentID
		END
		
		DELETE FROM tblGLTempAccount WHERE cntID = @ID
	END
END


DELETE FROM tblGLTempAccount WHERE intUserID = @intUserID

EXEC usp_SyncAccounts @intUserID


select 1

GO