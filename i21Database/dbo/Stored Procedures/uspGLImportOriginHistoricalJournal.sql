CREATE PROCEDURE  [dbo].[uspGLImportOriginHistoricalJournal]
@intUserId		INT,
@result			NVARCHAR(500) = '' OUTPUT
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

BEGIN TRANSACTION

--+++++++++++++++++++++++++++++++++
--			VALIDATIONS
--+++++++++++++++++++++++++++++++++
DECLARE @inti21Id int
SELECT @inti21Id = 1 FROM glhstmst LEFT OUTER JOIN tblGLCOACrossReference ON SUBSTRING(strCurrentExternalId,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glhst_acct9_16 WHERE inti21Id IS NULL

IF (SELECT isnull(@inti21Id, 0)) > 0
BEGIN	
	SET @result = 'There are accounts that does not exists at iRely Cross Reference. <br/> Kindly verify at Origin.'
END
ELSE IF (EXISTS(SELECT TOP 1 1 FROM (SELECT SUBSTRING(dtmDate,5,2)+'/01/'+SUBSTRING(dtmDate,1,4) as dtmDate FROM (SELECT CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalId, CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate FROM glhstmst GROUP BY glhst_period, glhst_src_id, glhst_src_seq) tblA) tblB where ISDATE(dtmDate) = 0))
BEGIN	
	SET @result = 'There are invalid dates on Historical Transactions. <br/> Kindly verify at Origin.'
END
ELSE IF (EXISTS(SELECT TOP 1 1 FROM glhstmst where LEN(glhst_trans_dt) <> 8))
BEGIN	
	SET @result = 'There are invalid dates on Historical Transaction Details. <br/> Kindly verify at Origin.'
END
ELSE
BEGIN

	--+++++++++++++++++++++++++++++++++
	--		CLEAN-UP TEMP TABLES
	--+++++++++++++++++++++++++++++++++	
	
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyImptblGLJournal') DROP TABLE iRelyImptblGLJournal
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyImptblGLJournalDetail') DROP TABLE iRelyImptblGLJournalDetail


	--+++++++++++++++++++++++++++++++++
	--		 TEMP HEADER JOURNAL
	--+++++++++++++++++++++++++++++++++	

	DECLARE @intCurrencyId NVARCHAR(100) = (select intCurrencyID from tblSMCurrency where strCurrency = 'USD')

	SELECT 
		CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalId,
		CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate,																					-- took the max period for the unique transaction - glhst_period controls posting period.	
		MAX(glhst_ref) AS strDescription,																									-- strDescription
		'General Journal' AS strTransactionType,																							-- Hard coded the transaction type
		'Adjusted Legacy Journal' AS strJournalType,																						-- Hard coded transaction type.	
		glhst_src_seq AS strSourceId,
		glhst_src_id AS strSourceType,
		@intCurrencyId AS intCurrencyId,																									-- intCurrencyId
		0 AS ysnPosted,																														-- ysnPosted	
		@intUserId AS intUserId,																											-- intUserId
		1 AS intConcurrencyId,																											-- intConcurrencyId
		NULL AS strReverseLink,
		NULL AS strRecurringStatus,
		NULL AS dtmJournalDate,																												-- dtmJournalDate
		NULL AS dtmReverseDate,																												-- We should not import reversing transactions	
		NULL AS dblExchangeRate,																											-- exchange rate
		NULL AS dtmPosted																												-- date posted--convert(varchar,(12),MAX(glhst_period)) removed per liz	
	INTO #iRelyImptblGLJournal
	FROM glhstmst
	GROUP BY glhst_period, glhst_src_id, glhst_src_seq	

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   INSERT IMPORT LOGS
	--+++++++++++++++++++++++++++++++++
	
	INSERT INTO tblGLCOAImportLog (strEvent,strIrelySuiteVersion,intUserId,dtmDate,strMachineName,strJournalType,intConcurrencyId)
					VALUES('Import Origin Historical Journal',(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),@intUserId,GETDATE(),'','',1)

	DECLARE @intImportLogId INT = (SELECT intImportLogId FROM tblGLCOAImportLog WHERE strEvent = 'Import Origin Historical Journal' AND dtmDate = GETDATE())
	
	INSERT INTO tblGLCOAImportLogDetail (intImportLogId,strEventDescription,strPeriod,strSourceNumber,strSourceSystem,strJournalId,intConcurrencyId)
		SELECT @intImportLogId,strDescription,dtmDate,strSourceId,strSourceType,strJournalId,1 FROM #iRelyImptblGLJournal
	
	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   UPDATE POSTING DATE
	--+++++++++++++++++++++++++++++++++

	--UPDATE #iRelyImptblGLJournal SET dtmDate = SUBSTRING(dtmDate,5,2)+'/01/'+SUBSTRING(dtmDate,1,4) FROM #iRelyImptblGLJournal
	
	
	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [HEADER]
	--+++++++++++++++++++++++++++++++++

	INSERT tblGLJournal (dtmReverseDate,strJournalId,strTransactionType, dtmDate,strReverseLink,intCurrencyId,dblExchangeRate,dtmPosted,strDescription,
							ysnPosted,intConcurrencyId,dtmJournalDate,intUserId,strSourceId,strJournalType,strRecurringStatus,strSourceType)
	SELECT  dtmReverseDate,
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
			dtmJournalDate,
			intUserId,
			strSourceId,
			strJournalType,
			strRecurringStatus,
			strSourceType
	FROM #iRelyImptblGLJournal

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--		 TEMP DETAIL JOURNAL
	--+++++++++++++++++++++++++++++++++

	SELECT 
		CONVERT(int,glhst_line_no) AS intLineNo,
		CONVERT(int,1) AS intJournalId,
		glhst_trans_dt,
		tblGLAccount.intAccountId,
		CASE WHEN glhst_correcting = 'Y' THEN
			CASE WHEN glhst_amt >= 0 THEN CASE WHEN glhst_dr_cr_ind = 'D' THEN glhst_amt ELSE 0 END
			ELSE CASE WHEN (glhst_dr_cr_ind='C' OR glhst_dr_cr_ind IS NULL) THEN (glhst_amt * -1) ELSE 0 END END
		ELSE
			CASE WHEN glhst_dr_cr_ind = 'D' THEN glhst_amt ELSE 0 END
		END AS Debit,
		0 AS DebitRate,																						-- debit rate		
		CASE WHEN glhst_correcting = 'Y' THEN
			CASE WHEN glhst_amt >= 0 THEN CASE WHEN (glhst_dr_cr_ind='C' OR glhst_dr_cr_ind IS NULL) THEN glhst_amt ELSE 0 END
			ELSE CASE WHEN glhst_dr_cr_ind = 'D' THEN (glhst_amt * -1) ELSE 0 END END
		ELSE
			CASE WHEN (glhst_dr_cr_ind='C' OR glhst_dr_cr_ind IS NULL) THEN glhst_amt ELSE 0 END
		END AS Credit,		
		0 AS CreditRate,																					-- credit rate
		CASE WHEN glhst_units < 0 THEN (glhst_units * -1) ELSE 0 END AS DebitUnits,
		CASE WHEN glhst_units > 0 THEN glhst_units ELSE 0 END AS CreditUnits,
		glhst_ref AS strDescription,
		NULL AS intCurrencyId,
		0 AS dblUnitsInlbs,
		glhst_doc AS strDocument,
		glhst_comments AS strComments,
		glhst_ref AS strReference,
		0 AS DebitUnitsInlbs,
		'N' AS strCorrecting,
		glhst_source_pgm AS strSourcePgm,																	-- aptrxu
		'' AS strCheckbookNo,																				-- 01
		'' AS strWorkArea,
		glhst_period,
		CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),(glhst_period)) AS glhst_jrnl_no,
		glhst_src_id,
		glhst_src_seq,    
		GETDATE() as gooddate
	 INTO #iRelyImptblGLJournalDetail
	 FROM  glhstmst 
	 INNER JOIN tblGLCOACrossReference ON 
		SUBSTRING(strCurrentExternalId,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glhst_acct9_16 
	 INNER JOIN tblGLAccount ON tblGLAccount.intAccountId = tblGLCOACrossReference.inti21Id
	 
	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT
	 
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

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--		 UPDATE DETAIL [intJournalId] BASED ON HEADER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	UPDATE #iRelyImptblGLJournalDetail 
		SET #iRelyImptblGLJournalDetail.intJournalId = tblGLJournal.intJournalId
	FROM #iRelyImptblGLJournalDetail
	INNER JOIN tblGLJournal ON 
		tblGLJournal.strJournalId = #iRelyImptblGLJournalDetail.glhst_jrnl_no 
		AND tblGLJournal.strSourceId = glhst_src_seq
		--AND glhst_period = convert(varchar(4),SUBSTRING (convert(varchar(100),dtmDate,101),7,4)) + convert(varchar(4),SUBSTRING(convert(varchar(100),dtmDate,101),1,2))

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--		 ASSIGN TRANSACTION Id BASED ON NEW HEADER GROUPING
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	--SET ROWCOUNT 0
	--UPDATE #iRelyImptblGLJournalDetail
	--SET intLineNo = 0

	--DECLARE @last1 INT
	--DECLARE @lastprior INT
	--DECLARE @line1 INT

	--SET @line1 = 0
	--SET @last1 = 0
	--SET @lastprior = 0

	--WHILE (SELECT COUNT(*) FROM #iRelyImptblGLJournalDetail where intLineNo = 0) > 0
	--BEGIN
	--	SELECT @last1= (SELECT MIN(intJournalId) FROM #iRelyImptblGLJournalDetail WHERE intLineNo = 0)

	--	IF @last1 <> @lastprior 
	--	BEGIN
	--		SET @line1 = 0
	--	END

	--	SET ROWCOUNT 0
	--	SELECT @lastprior = @last1
	--	SELECT @line1 = (SELECT Max (intLineNo) FROM #iRelyImptblGLJournalDetail WHERE intJournalId = @last1)

	--	SELECT @line1 = @line1 + 1

	--	SET ROWCOUNT 1
	--	UPDATE #iRelyImptblGLJournalDetail set intLineNo = @line1
	--	WHERE  intLineNo = 0 and intJournalId = @last1

	--END
	

	--++++++++++++++++++++++++++++
	--		UPDATE GOODDATE
	--++++++++++++++++++++++++++++

	SET ROWCOUNT 0

	UPDATE #iRelyImptblGLJournalDetail
	SET gooddate = CAST(substring(convert(varchar(10),glhst_trans_dt),5,2)
					+'/'+substring(convert(varchar(10),glhst_trans_dt),7,2)
					+'/'+substring(convert(varchar(10),glhst_trans_dt),1,4) AS DATETIME)
	FROM #iRelyImptblGLJournalDetail

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [DETAIL]
	--+++++++++++++++++++++++++++++++++

	INSERT tblGLJournalDetail (intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,dblDebitRate,dblCredit,dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,
								dblUnitsInLBS,strDocument,strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea)
						SELECT intLineNo,intJournalId,gooddate,intAccountId,Debit,DebitRate,Credit,CreditRate,DebitUnits,CreditUnits,strDescription,1,
								dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea 
						FROM  #iRelyImptblGLJournalDetail
						
	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT
						
	--+++++++++++++++++++++++++++++++++++++
	--	UPDATE POST DATE JOURNAL [HEADER]
	--+++++++++++++++++++++++++++++++++++++											
						
	UPDATE tblGLJournal SET dtmDate = (SELECT TOP 1 CAST(CAST(MONTH(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) +'/01/'+ CAST(YEAR(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) as DATETIME) as dtmNewDate FROM tblGLJournalDetail 
                                        WHERE tblGLJournalDetail.intJournalId = tblGLJournal.intJournalId)
                                        						
	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT	
                                     

	SET @result = 'SUCCESSFULLY IMPORTED'
						
END
	
--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
COMMIT_INSERT:
	COMMIT TRANSACTION
	GOTO IMPORT_EXIT
	
ROLLBACK_INSERT:
	ROLLBACK TRANSACTION		            
	GOTO IMPORT_EXIT

IMPORT_EXIT:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#iRelyImptblGLJournal')) DROP TABLE #iRelyImptblGLJournal
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#iRelyImptblGLJournalDetail')) DROP TABLE #iRelyImptblGLJournalDetail

GO	