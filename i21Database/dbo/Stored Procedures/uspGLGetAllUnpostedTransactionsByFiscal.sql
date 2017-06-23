/****** Object:  StoredProcedure [dbo].[uspGLGetAllUnpostedTransactionsByFiscal]    Script Date: 11/4/2015 3:41:46 PM ******/
-- =============================================
-- Author:		Trajano, Jeff
-- Create date: 8-11-2015
-- Description:	Gets all unposted transaction (GL,CM,AP,IC,AR) 
-- JIRA Key:	GL-1923
-- =============================================
CREATE PROCEDURE [uspGLGetAllUnpostedTransactionsByFiscal] --GL-1923
	@intFiscalYearId INT,
	@intEntityId INT,
	@intFiscalYearPeriodId INT = 0,
	@strModule NVARCHAR(3),
	@ysnUnpostedTrans  int OUT
AS
BEGIN
SET NOCOUNT ON;
-- BEGIN DECLARE TABLE VARIABLES
DECLARE @tblOriginTransactions TABLE(
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTransactionType NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	dtmDate DATETIME,
	strModule NVARCHAR(3)COLLATE Latin1_General_CI_AS NULL

)
DECLARE @tblTransactions TABLE(
	intTransactionId INT,
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTransactionType NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	dtmDate DATETIME,
	strDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intEntityId	INT,
	strModule NVARCHAR(3)  COLLATE Latin1_General_CI_AS NULL
)
DECLARE @transactionType  NVARCHAR(30)= ''
DECLARE @msg NVARCHAR(2) = ''
DECLARE @guid UNIQUEIDENTIFIER
-- END TABLE VARIABLE DECLARATIONS

-- BEGIN GETS THE DATE CRITERIA BASE ON THE FISCAL YEAR
DECLARE @dtmDateFrom DATETIME
DECLARE @dtmDateTo DATETIME
IF @intFiscalYearPeriodId > 0
	SELECT TOP 1 @dtmDateFrom= dtmStartDate,@dtmDateTo= dtmEndDate FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalYearPeriodId
ELSE
	SELECT TOP 1 @dtmDateFrom= dtmDateFrom,@dtmDateTo= dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId
-- END GETS THE DATE CRITERIA BASE ON THE FISCAL YEAR

-- BEGIN OPEN GL UNPOSTED SCREEN
-- EXCLUDED IC AND PR SINCE THEY DO NOT HAVE BATCH POSTING FEATURE
IF @strModule = 'INV' -- SHOW ONLY IC TRANSACTIONS
		INSERT INTO @tblOriginTransactions
		SELECT  strTransactionId,strTransactionType, dtmDate ,@strModule from [vyuICGetUnpostedTransactions]
		WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo


ELSE IF @strModule = 'PR' -- SHOW ONLY PR TRANSACTIONS
		INSERT INTO @tblOriginTransactions
		SELECT  strTransactionId,strTransactionType, dtmDate,@strModule  from vyuPRUnpostedTransactions
		WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
ELSE IF @strModule = 'GL'
BEGIN
	-- BEGIN SHOW CM,INV, PR (I21) AND AP,GL (ORIGIN) TRANSACTIONS
	DECLARE @blnLegacyIntegration BIT = 0
	SELECT TOP 1 @blnLegacyIntegration = ISNULL(ysnLegacyIntegration,0) FROM tblSMCompanyPreference
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glijemst]') AND type IN (N'U'))
		AND  @blnLegacyIntegration = 1
	BEGIN
		;WITH GLORIGIN(strTransactionId,strTransactionType,dtmDate)
		as
		(
			SELECT glije_src_no as strTransactionId,
			'Origin - ' + glije_src_sys as strTransactionType,
			CAST(SUBSTRING(CAST(glije_date AS NVARCHAR(10)),1,4) + '-' + SUBSTRING(CAST(glije_date AS NVARCHAR(10)),5,2) + '-' + SUBSTRING(CAST(glije_date AS NVARCHAR(10)),7,2) AS DATE) as dtmDate
			FROM glijemst group by glije_src_no,glije_src_sys,glije_date

		)
		INSERT INTO @tblOriginTransactions
		SELECT strTransactionId,strTransactionType,dtmDate,'OG' FROM GLORIGIN
		WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo

	END

	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aptrxmst]') AND type IN (N'U'))
		AND  @blnLegacyIntegration = 1
	BEGIN
		;WITH APORIGIN(strTransactionId,strTransactionType,dtmDate)AS(
			SELECT aptrx_ivc_no as strTransactionId, 'Origin - AP' as strTransactionType, CAST(SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),1,4) + '-' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),5,2) + '-' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),7,2) AS DATE) as dtmDate
			FROM aptrxmst GROUP BY aptrx_ivc_no, aptrx_gl_rev_dt)
		INSERT INTO @tblOriginTransactions
		SELECT strTransactionId,strTransactionType,dtmDate,'OG' FROM APORIGIN
		WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
	END


	;WITH I21Transactions (strTransactionId,strTransactionType,dtmDate,strModule) AS(
		 SELECT strTransactionId COLLATE Latin1_General_CI_AS,strTransactionType COLLATE Latin1_General_CI_AS, dtmDate ,'INV' from [vyuICGetUnpostedTransactions] UNION ALL
		SELECT strTransactionId COLLATE Latin1_General_CI_AS,strTransactionType COLLATE Latin1_General_CI_AS, dtmDate ,'PR' from vyuPRUnpostedTransactions
		)
	INSERT INTO @tblOriginTransactions SELECT strTransactionId,strTransactionType,dtmDate,strModule FROM I21Transactions WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
	-- END SHOW CM,INV, PR (I21) AND AP,GL (ORIGIN) TRANSACTIONS
END

IF EXISTS (SELECT TOP 1 1 FROM @tblOriginTransactions)
BEGIN
	SELECT  @transactionType ='Origin'
	SELECT TransactionType = @transactionType
	SELECT strTransactionId,strTransactionType,dtmDate FROM @tblOriginTransactions
	SET @ysnUnpostedTrans = 1
	RETURN --SHOW GL SCREEN IF THERE ARE TRANSACTION THEN EXIT
END
-- END OPEN GL UNPOSTED SCREEN

-- SHOW BATCH POSTING SCREEN IF THERE ARE NO ORIGIN UNSPOSTED TRANSACTIONS
-- BEGIN OPEN BATCH POSTING SCREEN
DECLARE @tblModule TABLE(strModule NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL)
IF @strModule <>  'GL' INSERT INTO @tblModule SELECT @strModule
ELSE INSERT INTO @tblModule SELECT 'GL' UNION ALL SELECT 'AP' UNION ALL SELECT 'AR'

;WITH Transactions(intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate, strModule)
	AS
	(
		SELECT intJournalId,  strJournalId COLLATE DATABASE_DEFAULT AS strTransactionId,strDescription,  strTransactionType COLLATE DATABASE_DEFAULT AS strTransactionType,
		strUserName = (select strName from tblEMEntity where intEntityId = j.intEntityId ),
		intEntityId,
		dtmDate,'GL' FROM tblGLJournal j
			 WHERE ysnPosted = 0 and (strTransactionType = 'General Journal' OR strTransactionType = 'Audit Adjustment')-- GL
		UNION ALL
			SELECT intTransactionId, strTransactionId,strDescription,strTransactionType,strUserName,intEntityId,  dtmDate,'AP' from [vyuAPUnpostedTransaction] --AP

		UNION ALL
			SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName, intEntityId, dtmDate,'AR' from [vyuARUnpostedTransactions] --AR
		UNION ALL
			SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName, intEntityId, dtmDate, 'CM' FROM vyuCMUnpostedTransaction --CM
	)
	INSERT INTO @tblTransactions(intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate, strModule)
	SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate,T.strModule from Transactions T
	INNER JOIN @tblModule M ON T.strModule = M.strModule
	WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
	IF EXISTS (SELECT TOP 1 1 from @tblTransactions)
	BEGIN

		DECLARE @intCount INT
		DECLARE @intAACount INT
		DECLARE @ysnAllowUserSelfPost BIT

		DELETE FROM tblGLForBatchPosting
		SELECT @guid = NEWID()
		SELECT  @transactionType ='NonOrigin'

		INSERT INTO tblGLForBatchPosting (intTransactionId, strTransactionId,strDescription, strTransactionType,strUserName, intEntityId, dtmDate,[guid])
			SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate,@guid FROM @tblTransactions
		SELECT @intAACount = COUNT(1) FROM @tblTransactions WHERE strTransactionType = 'Audit Adjustment'
		SELECT @intCount = COUNT(1) FROM @tblTransactions

		SELECT @ysnAllowUserSelfPost= ISNULL(ysnAllowUserSelfPost,0)  FROM [tblSMUserPreference] where intEntityUserSecurityId = @intEntityId

		IF @ysnAllowUserSelfPost = 1
		BEGIN
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLForBatchPosting WHERE intEntityId = @intEntityId)
				SELECT  @transactionType ='OtherUserTransaction'
		END

		SELECT @msg = CASE WHEN @intCount >0 AND @intAACount = @intCount THEN 'AA' ELSE '' END
		SELECT TransactionType = @transactionType , message = @msg ,batchGUID = @guid
		SET @ysnUnpostedTrans = 1
	END

	-- END OPEN BATCH POSTING SCREEN
	ELSE
	BEGIN
		-- ANY SCREEN IS NOT OPENED.
		SELECT TransactionType = 'Empty'  , message = '' ,batchGUID = ''
		SET @ysnUnpostedTrans = 0
	END

END