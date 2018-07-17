
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glhstmst]') AND type IN (N'U'))
EXEC (
'ALTER PROCEDURE [dbo].[uspGLImportOriginHistoricalJournal]
@intEntityId		INT
AS
SET ANSI_WARNINGS OFF
SET NOCOUNT ON
DECLARE @result NVARCHAR(MAX)
DECLARE @invalidDatesUpdated VARCHAR(1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption A join tblGLAccount B on A.OriginConversion_OffsetAccountId = B.intAccountId)
BEGIN
	SELECT ''Origin Offset Account is required in GL Company Configuration.''
	RETURN -1
END

IF NOT EXISTS(SELECT TOP 1 1 FROM glhstmst)
BEGIN
	SELECT ''Origin table is empty.''
	RETURN -1
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntity WHERE intEntityId = @intEntityId)
BEGIN
	SELECT CONVERT(NVARCHAR(4),@intEntityId) + '' Entity Id is not valid. Please re-login your credential.''
	RETURN -1
END

--BEGIN TRANSACTION
EXECUTE [dbo].[uspGLImportOriginHistoricalJournalCLOSED] @intEntityId ,@result OUTPUT

	--IF @@ERROR <> 0	OR CHARINDEX(''SUCCESS'', @result,1)= 0
	--		GOTO ROLLBACK_INSERT

SELECT @result = REPLACE(@result , ''SUCCESS '','''')

	--+++++++++++++++++++++++++++++++++
	--		CLEAN-UP TEMP TABLES
	--+++++++++++++++++++++++++++++++++

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''iRelyImptblGLJournal'') DROP TABLE iRelyImptblGLJournal
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''iRelyImptblGLJournalDetail'') DROP TABLE iRelyImptblGLJournalDetail


	--+++++++++++++++++++++++++++++++++
	--		 TEMP HEADER JOURNAL
	--+++++++++++++++++++++++++++++++++

	DECLARE @intCurrencyId NVARCHAR(100) = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'') > 0
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD'') END))

	SELECT
		CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalId,
		CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate,																					-- took the max period for the unique transaction - glhst_period controls posting period.
		MAX(glhst_ref) AS strDescription,																									-- strDescription
		''General Journal'' AS strTransactionType,																							-- Hard coded the transaction type
		''Origin Journal'' AS strJournalType,																						-- Hard coded transaction type.
		glhst_src_seq AS strSourceId,
		glhst_src_id AS strSourceType,
		@intCurrencyId AS intCurrencyId,																									-- intCurrencyId
		0 AS ysnPosted,																														-- ysnPosted
		@intEntityId AS intEntityId,																											-- intEntityId
		1 AS intConcurrencyId,																											-- intConcurrencyId
		NULL AS strReverseLink,
		NULL AS strRecurringStatus,
		GETDATE() AS dtmDateEntered,																												-- dtmJournalDate/dtmDateEntered
		NULL AS dtmReverseDate,																												-- We should not import reversing transactions
		NULL AS dblExchangeRate,																											-- exchange rate
		NULL AS dtmPosted																												-- date posted--convert(varchar,(12),MAX(glhst_period)) removed per liz
	INTO #iRelyImptblGLJournal
	FROM glhstmst
	GROUP BY glhst_period, glhst_src_id, glhst_src_seq

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   INSERT IMPORT LOGS
	--+++++++++++++++++++++++++++++++++

	INSERT INTO tblGLCOAImportLog (strEvent,strIrelySuiteVersion,intEntityId,dtmDate,strMachineName,strJournalType,intConcurrencyId)
					VALUES(''Import Origin Historical Journal'',(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),@intEntityId,GETDATE(),'''','''',1)

	DECLARE @intImportLogId INT
	SELECT @intImportLogId  =SCOPE_IDENTITY()

	INSERT INTO tblGLCOAImportLogDetail (intImportLogId,strEventDescription,strPeriod,strSourceNumber,strSourceSystem,strJournalId,intConcurrencyId)
		SELECT @intImportLogId,strDescription,dtmDate,strSourceId,strSourceType,strJournalId,1 FROM #iRelyImptblGLJournal

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   UPDATE POSTING DATE
	--+++++++++++++++++++++++++++++++++

	--UPDATE #iRelyImptblGLJournal SET dtmDate = SUBSTRING(dtmDate,5,2)+''/01/''+SUBSTRING(dtmDate,1,4) FROM #iRelyImptblGLJournal


	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [HEADER]
	--+++++++++++++++++++++++++++++++++
	DECLARE @intCompanyId INT
	SELECT TOP 1 @intCompanyId =ISNULL(intMultiCompanyId, intCompanySetupID) FROM tblSMCompanySetup
	INSERT tblGLJournal (intCompanyId, dtmReverseDate,strJournalId,strTransactionType, dtmDate,strReverseLink,intCurrencyId,dblExchangeRate,dtmPosted,strDescription,
							ysnPosted,intConcurrencyId,dtmDateEntered,intEntityId,strSourceId,strJournalType,strRecurringStatus,strSourceType)
	SELECT  @intCompanyId,
			dtmReverseDate,
			strJournalId,
			strTransactionType,
			CAST((dbo.[fnGeti21PeriodFromOriginPeriod](SUBSTRING(dtmDate,1,4), SUBSTRING(dtmDate,5,2))) as DATETIME) as dtmDate,
			strReverseLink,
			intCurrencyId,
			dblExchangeRate,
			dtmPosted,
			strDescription,
			ysnPosted,
			intConcurrencyId,
			dtmDateEntered,
			intEntityId,
			strSourceId,
			strJournalType,
			strRecurringStatus,
			strSourceType
	FROM #iRelyImptblGLJournal

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--		 TEMP DETAIL JOURNAL
	--+++++++++++++++++++++++++++++++++

	SELECT
		CONVERT(int,glhst_line_no) AS intLineNo,
		CONVERT(int,1) AS intJournalId,
		glhst_trans_dt,
		tblGLAccount.intAccountId,
		CASE WHEN glhst_dr_cr_ind = ''D'' THEN  ABS(glhst_amt) ELSE 0 END Debit,
		0 AS DebitRate,																						-- debit rate
		CASE WHEN glhst_dr_cr_ind = ''C'' THEN  ABS(glhst_amt) ELSE 0 END Credit,
		0 AS CreditRate,
		CASE WHEN glhst_dr_cr_ind = ''D'' THEN  ABS(glhst_units) ELSE 0 END DebitUnits,
		CASE WHEN glhst_dr_cr_ind = ''C'' THEN  ABS(glhst_units) ELSE 0 END CreditUnits,
		glhst_ref AS strDescription,
		NULL AS intCurrencyId,
		0 AS dblUnitsInlbs,
		glhst_doc AS strDocument,
		glhst_comments AS strComments,
		glhst_ref AS strReference,
		0 AS DebitUnitsInlbs,
		''N'' AS strCorrecting,
		glhst_source_pgm AS strSourcePgm,																	-- aptrxu
		'''' AS strCheckbookNo,																				-- 01
		'''' AS strWorkArea,
		glhst_period,
		CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),(glhst_period)) AS glhst_jrnl_no,
		glhst_src_id,
		glhst_src_seq,
		GETDATE() as gooddate,
		A4GLIdentity
	 INTO #iRelyImptblGLJournalDetail
	 FROM  glhstmst
	 INNER JOIN tblGLCOACrossReference ON
		SUBSTRING(strCurrentExternalId,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glhst_acct9_16
	 INNER JOIN tblGLAccount ON tblGLAccount.intAccountId = tblGLCOACrossReference.inti21Id

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--		 UPDATE COLLATE JOURNAL
	--+++++++++++++++++++++++++++++++++

	ALTER TABLE #iRelyImptblGLJournalDetail
		ALTER COLUMN glhst_jrnl_no
			VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL

	ALTER TABLE #iRelyImptblGLJournalDetail
		ALTER COLUMN glhst_src_id
			CHAR(3) COLLATE Latin1_General_CI_AS NOT NULL

	ALTER TABLE #iRelyImptblGLJournalDetail
		ALTER COLUMN glhst_src_seq
			CHAR(5) COLLATE Latin1_General_CI_AS NOT NULL

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--		 UPDATE DETAIL [intJournalId] BASED ON HEADER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	UPDATE #iRelyImptblGLJournalDetail
		SET #iRelyImptblGLJournalDetail.intJournalId = tblGLJournal.intJournalId
	FROM #iRelyImptblGLJournalDetail
	INNER JOIN tblGLJournal ON
		tblGLJournal.strJournalId = #iRelyImptblGLJournalDetail.glhst_jrnl_no
		AND tblGLJournal.strSourceId = glhst_src_seq

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--++++++++++++++++++++++++++++
	--		UPDATE GOODDATE
	--++++++++++++++++++++++++++++

	SET ROWCOUNT 0

	UPDATE #iRelyImptblGLJournalDetail
	SET gooddate = CAST (substring(convert(varchar(10),glhst_trans_dt),1,4)
					+substring(convert(varchar(10),glhst_trans_dt),5,2)
					+substring(convert(varchar(10),glhst_trans_dt),7,2) AS DATETIME)
	FROM #iRelyImptblGLJournalDetail
	WHERE ISDATE(substring(convert(varchar(10),glhst_trans_dt),1,4) + substring(convert(varchar(10),glhst_trans_dt),5,2) + substring(convert(varchar(10),glhst_trans_dt),7,2) ) = 1


	UPDATE #iRelyImptblGLJournalDetail
	SET gooddate = cast( substring(replace(convert(varchar(20),j.dtmDate,102),''.'',''''),1,6) + ''01''  as datetime )
	FROM #iRelyImptblGLJournalDetail a INNER JOIN
	tblGLJournal j on a.intJournalId =j.intJournalId
	WHERE ISDATE(substring(convert(varchar(10),glhst_trans_dt),1,4) + substring(convert(varchar(10),glhst_trans_dt),5,2) + substring(convert(varchar(10),glhst_trans_dt),7,2) ) = 0
	SELECT @invalidDatesUpdated =  CASE WHEN @@ROWCOUNT > 0  THEN ''1'' ELSE ''0'' END

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [DETAIL]
	--+++++++++++++++++++++++++++++++++

	INSERT tblGLJournalDetail (intCompanyId, intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,dblDebitRate,dblCredit,dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,
								dblUnitsInLBS,strDocument,strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea,strSourceKey)
						SELECT @intCompanyId, intLineNo,intJournalId,gooddate,intAccountId,ROUND(Debit,2),DebitRate,ROUND(Credit,2),CreditRate,DebitUnits,CreditUnits,strDescription,1,
								dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea,A4GLIdentity
						FROM  #iRelyImptblGLJournalDetail

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++++++
	--	UPDATE POST DATE JOURNAL [HEADER]
	--+++++++++++++++++++++++++++++++++++++

	UPDATE tblGLJournal SET dtmDate = (SELECT TOP 1 CAST(CAST(MONTH(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) +''/01/''+ CAST(YEAR(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) as DATETIME) as dtmNewDate FROM tblGLJournalDetail
                                        WHERE tblGLJournalDetail.intJournalId = tblGLJournal.intJournalId)
										WHERE intJournalId IN (SELECT DISTINCT(intJournalId) FROM #iRelyImptblGLJournalDetail)

	--IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

    IF LEN(@result) > 0
		SET @result = @result + '','' + CAST(@intImportLogId AS NVARCHAR(40))  --''SUCCESS SELECT A.intJournalId FROM tblGLJournal A INNER JOIN tblGLCOAImportLogDetail B on A.strJournalId = B.strJournalId WHERE B.intImportLogId IN('' +  @result --(Select (Select CAST(intJournalId AS NVARCHAR(MAX)) + '','' From (select intJournalId from tblGLJournal A left join #iRelyImptblGLJournal B on A.strJournalId = B.strJournalId COLLATE Latin1_General_CI_AS) X FOR XML PATH('''')) as intJournalId)
	ELSE
		SET @result = CAST(@intImportLogId AS NVARCHAR(40));

	
--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
	EXEC dbo.uspGLInsertOffsetAccountForOriginTrans;
	UPDATE tblGLCompanyPreferenceOption  set ysnHistoricalJournalImported = 1
-- for testing only	THROW 51000, ''The record does not exist.'', 1;  
	SELECT ''SUCCESS:''+  @result +'':'' + @invalidDatesUpdated
	

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id(''tempdb..#iRelyImptblGLJournal'')) DROP TABLE #iRelyImptblGLJournal
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id(''tempdb..#iRelyImptblGLJournalDetail'')) DROP TABLE #iRelyImptblGLJournalDetail')
GO
