/****** Object:  StoredProcedure [dbo].[uspGLGetAllUnpostedTransactionsByFiscal]    Script Date: 11/4/2015 3:41:46 PM ******/
-- =============================================
-- Author:		Trajano, Jeff
-- Create date: 8-11-2015
-- Description:	Gets all unposted transaction (GL,CM,AP,IC,AR) 
-- JIRA Key:	GL-1923
-- =============================================
CREATE PROCEDURE [dbo].[uspGLGetAllUnpostedTransactionsByFiscal] --GL-1923
 @intFiscalYearId INT,
 @intEntityId INT,
 @intFiscalYearPeriodId INT = 0
 
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
	IF @intFiscalYearPeriodId > 0 
		BEGIN
			SELECT TOP 1 @dtmDateFrom= dtmStartDate,@dtmDateTo= dtmEndDate FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = @intFiscalYearPeriodId
		END
	ELSE
		SELECT TOP 1 @dtmDateFrom= dtmDateFrom,@dtmDateTo= dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId


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
	
		IF EXISTS (SELECT TOP 1 1 FROM @tblOriginTransactions)
		BEGIN
			SELECT  TransactionType ='Origin' 
			SELECT strTransactionId,strTransactionType,dtmDate FROM @tblOriginTransactions
			RETURN
		END

		;WITH Transactions(intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate)
		AS
		(
			SELECT intJournalId,  strJournalId COLLATE DATABASE_DEFAULT AS strTransactionId,strDescription,  strTransactionType COLLATE DATABASE_DEFAULT AS strTransactionType,
			strUserName = (select strName from tblEntity where intEntityId = j.intEntityId ),
			intEntityId,
			dtmDate
			  
				FROM tblGLJournal j
				 WHERE ysnPosted = 0 and (strTransactionType = 'General Journal' OR strTransactionType = 'Audit Adjustment')-- GL
			--UNION ALL
				--SELECT intTransactionId, strTransactionId,strDescription, strTransactionType,strUserName,intEntityId, dtmDate from [vyuICGetUnpostedTransactions] --IC
			UNION ALL
				SELECT intTransactionId, strTransactionId,strDescription,strTransactionType,strUserName,intEntityId,  dtmDate from [vyuAPUnpostedTransaction] --AP
			UNION ALL
				SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate from [vyuCMUnpostedTransaction] --CM
			UNION ALL
				SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName, intEntityId, dtmDate from [vyuARUnpostedTransactions] --AR
		)
		INSERT INTO @tblTransactions(intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate)
		SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate from Transactions WHERE dtmDate >= @dtmDateFrom AND dtmDate <= @dtmDateTo
		
		IF EXISTS (SELECT TOP 1 1 from @tblTransactions)
		BEGIN
			
			DELETE FROM tblGLForBatchPosting 
			
			SELECT @guid = NEWID()
			
			DECLARE @ysnAllowUserSelfPost BIT
			
			
			SELECT  TransactionType ='NonOrigin' 

			INSERT INTO tblGLForBatchPosting (intTransactionId, strTransactionId,strDescription, strTransactionType,strUserName, intEntityId, dtmDate,[guid])
				SELECT intTransactionId, strTransactionId, strDescription, strTransactionType,strUserName,intEntityId, dtmDate,@guid FROM @tblTransactions
			SELECT @intAACount = COUNT(1) FROM @tblTransactions WHERE strTransactionType = 'Audit Adjustment'
			SELECT @intCount = COUNT(1) FROM @tblTransactions
			
			SELECT @ysnAllowUserSelfPost= ISNULL(ysnAllowUserSelfPost,0)  FROM [tblSMUserPreference] where intEntityUserSecurityId = @intEntityId
			
			IF @ysnAllowUserSelfPost = 1
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLForBatchPosting WHERE intEntityId = @intEntityId)
					SELECT  TransactionType ='OtherUserTransaction' 
			END

			SELECT CASE WHEN @intCount >0 AND @intAACount = @intCount THEN 'AA' ELSE '' END AS message
			SELECT  @guid as batchGUID
		END
		ELSE
		BEGIN
			SELECT  TransactionType ='Empty' 
		END
END