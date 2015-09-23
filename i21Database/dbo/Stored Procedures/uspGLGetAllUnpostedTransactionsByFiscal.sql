-- =============================================
-- Author:		Trajano, Jeff
-- Create date: 8-11-2015
-- Description:	Gets all unposted transaction (GL,CM,AP,IC,AR) 
-- JIRA Key:	GL-1923
-- =============================================
CREATE PROCEDURE [dbo].[uspGLGetAllUnpostedTransactionsByFiscal] --GL-1923
 @intFiscalYearId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @blnLegacyIntegration BIT = 0
	DECLARE @tblOriginTransactions TABLE(
		strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strTransactionType NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
		dtmDate DATETIME
	)
	DECLARE @tblTransactions TABLE(
		intTransactionId INT,
		strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strTransactionType NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
		dtmDate DATETIME,
		strDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
		strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		intEntityId	INT
	)
	
	DECLARE @guid UNIQUEIDENTIFIER
	DECLARE @dtmDateFrom DATETIME
	DECLARE @dtmDateTo DATETIME
	SELECT TOP 1 @dtmDateFrom= dtmDateFrom,@dtmDateTo= dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId

	--INSERTS TO temporarytable
	;WITH Transactions(intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate)
	AS
	(
		SELECT intJournalId,  strJournalId COLLATE DATABASE_DEFAULT AS strTransactionId,strDescription,  strTransactionType COLLATE DATABASE_DEFAULT AS strTransactionType,
		strUserName = (select strName from tblEntity where intEntityId = j.intEntityId ),
		intEntityId,
		dtmDate
		 dtmDate 
			FROM tblGLJournal j
			 WHERE ysnPosted = 0 and (strTransactionType = 'General Journal' OR strTransactionType = 'Audit Adjustment')-- GL
		--UNION
		--SELECT strTransactionId, strTransactionType,dtmDate from [vyuICGetUnpostedTransactions] --IC
		--UNION
		--SELECT strTransactionId, strTransactionType,dtmDate from [vyuAPUnpostedTransaction] --AP
		UNION
		SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate from [vyuCMUnpostedTransaction] --CM
		--UNION
		--SELECT strTransactionId, strTransactionType,dtmDate from [vyuARUnpostedTransactions] --AR
	)
	INSERT INTO @tblTransactions(intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate)
	SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate from Transactions WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
	
	IF EXISTS (SELECT TOP 1 1 from @tblTransactions)
	BEGIN
		DELETE FROM tblGLForBatchPosting WHERE dtmDateEntered < DATEADD(day,-2, GETDATE())
		SELECT @guid = NEWID()
		
		INSERT INTO 
		tblGLForBatchPosting (intTransactionId, strTransactionId,strDescription, strTransactionType,strUserName, intEntityId, dtmDate,[guid])
		SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate,@guid FROM @tblTransactions
	END

		
	
	
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
		FROM glijemst
	)
	INSERT INTO @tblOriginTransactions
	SELECT strTransactionId,strTransactionType,dtmDate FROM GLORIGIN
	WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
		
	END

	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aptrxmst]') AND type IN (N'U'))
		AND  @blnLegacyIntegration = 1
	BEGIN
		;WITH APORIGIN(strTransactionId,strTransactionType,dtmDate)
		as
		(
			SELECT aptrx_ivc_no as strTransactionId, 'Origin - AP' as strTransactionType, CAST(SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),1,4) + '-' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),5,2) + '-' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),7,2) AS DATE) as dtmDate 
			FROM aptrxmst 
			GROUP BY aptrx_ivc_no, aptrx_gl_rev_dt
		)
		INSERT INTO @tblOriginTransactions
		SELECT strTransactionId,strTransactionType,dtmDate FROM APORIGIN
		WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
	END

	DECLARE @intCount INT
	DECLARE @intAACount INT
	
	SELECT @intCount = COUNT(1) FROM @tblTransactions
	SELECT @intAACount = COUNT(1) FROM @tblTransactions WHERE strTransactionType = 'Audit Adjustment'
	
	SELECT strTransactionId,strTransactionType,dtmDate FROM @tblOriginTransactions
	SELECT CASE WHEN @intCount >0 AND @intAACount = @intCount THEN 'AA' ELSE '' END AS message
	SELECT @guid as batchGUID

END