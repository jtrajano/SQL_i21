-- =============================================
-- Author:		Trajano, Jeff
-- Create date: 8-11-2015
-- Description:	Gets all unposted transaction (GL,CM,AP,IC,AR) 
-- JIRA Key:	GL-1923
-- =============================================
CREATE PROCEDURE uspGLGetAllUnpostedTransactionsByFiscal --GL-1923
 @intFiscalYearId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @blnLegacyIntegration BIT = 0
	DECLARE @tblTransactions TABLE(
		strTransactionId NVARCHAR(20),
		strTransactionType NVARCHAR(25),
		dtmDate DATETIME
	)
	SELECT TOP 1 @blnLegacyIntegration = ISNULL(ysnLegacyIntegration,0) FROM tblSMCompanyPreference 

	;WITH FiscalYear(dtmDateFrom,dtmDateTo)
	AS
	(
		SELECT TOP 1 dtmDateFrom,dtmDateTo FROM tblGLFiscalYear WHERE intFiscalYearId = @intFiscalYearId
	),
	Transactions(strTransactionId,strTransactionType,dtmDate)
	AS
	(
		SELECT strJournalId COLLATE DATABASE_DEFAULT AS strTransactionId, strTransactionType COLLATE DATABASE_DEFAULT AS strTransactionType, dtmDate 
			FROM tblGLJournal WHERE ysnPosted = 0 and strTransactionType = 'General Journal' -- GL
		UNION
		SELECT glije_src_no as strTransactionId, 'Origin - ' + glije_src_sys as strTransactionType,	CAST(SUBSTRING(CAST(glije_date AS NVARCHAR(10)),1,4) + '-' + SUBSTRING(CAST(glije_date AS NVARCHAR(10)),5,2) + '-' + SUBSTRING(CAST(glije_date AS NVARCHAR(10)),7,2) AS DATE) as dtmDate 
			FROM glijemst WHERE @blnLegacyIntegration  = 1 --ORIGIN JOURNAL
		UNION
		SELECT aptrx_ivc_no as strTransactionId, 'Origin - AP' as strTransactionType, CAST(SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),1,4) + '-' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),5,2) + '-' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),7,2) AS DATE) as dtmDate 
			FROM aptrxmst WHERE @blnLegacyIntegration  = 1   GROUP BY aptrx_ivc_no, aptrx_gl_rev_dt --ORIGIN AP
		UNION
		SELECT strTransactionId, strTransactionType,dtmDate from [vyuICGetUnpostedTransactions] --IC
		UNION
		SELECT strTransactionId, strTransactionType,dtmDate from [vyuAPUnpostedTransaction] --AP
		UNION
		SELECT strTransactionId, strTransactionType,dtmDate from [vyuCMUnpostedTransaction] --CM
		UNION
		SELECT strTransactionId, strTransactionType,dtmDate from [vyuARUnpostedTransactions] --AR
	)
	INSERT INTO @tblTransactions
	SELECT strTransactionId,strTransactionType,dtmDate from Transactions,FiscalYear WHERE dtmDate >= FiscalYear.dtmDateFrom AND dtmDate <= FiscalYear.dtmDateTo
	DECLARE @intCount INT
	DECLARE @intAACount INT
	
	SELECT @intCount = COUNT(1) FROM @tblTransactions
	SELECT @intAACount = COUNT(1) FROM @tblTransactions WHERE strTransactionType = 'Audit Adjustment'
	
	SELECT strTransactionId,strTransactionType,dtmDate FROM @tblTransactions
	SELECT CASE WHEN @intCount >0 AND @intAACount = @intCount THEN 'AA' ELSE '' END

END
GO