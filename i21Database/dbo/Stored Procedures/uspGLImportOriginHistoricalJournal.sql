﻿CREATE PROCEDURE  [dbo].[uspGLImportOriginHistoricalJournal]
@intEntityId		INT
AS
SET ANSI_WARNINGS OFF
SET NOCOUNT ON
DECLARE @result NVARCHAR(MAX)
DECLARE @invalidDatesUpdated VARCHAR(1)

BEGIN TRANSACTION
EXECUTE [dbo].[uspGLImportOriginHistoricalJournalCLOSED] @intEntityId ,@result OUTPUT

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	IF CHARINDEX('SUCCESS', @result,1)= 0 RETURN
SELECT @result = REPLACE(@result , 'SUCCESS ','')

	--+++++++++++++++++++++++++++++++++
	--		CLEAN-UP TEMP TABLES
	--+++++++++++++++++++++++++++++++++	
	
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyImptblGLJournal') DROP TABLE iRelyImptblGLJournal
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyImptblGLJournalDetail') DROP TABLE iRelyImptblGLJournalDetail


	--+++++++++++++++++++++++++++++++++
	--		 TEMP HEADER JOURNAL
	--+++++++++++++++++++++++++++++++++	

	DECLARE @intCurrencyId NVARCHAR(100) = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))

	SELECT 
		CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalId,
		CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate,																					-- took the max period for the unique transaction - glhst_period controls posting period.	
		MAX(glhst_ref) AS strDescription,																									-- strDescription
		'General Journal' AS strTransactionType,																							-- Hard coded the transaction type
		'Origin Journal' AS strJournalType,																						-- Hard coded transaction type.	
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

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   INSERT IMPORT LOGS
	--+++++++++++++++++++++++++++++++++
	
	INSERT INTO tblGLCOAImportLog (strEvent,strIrelySuiteVersion,intEntityId,dtmDate,strMachineName,strJournalType,intConcurrencyId)
					VALUES('Import Origin Historical Journal',(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),@intEntityId,GETDATE(),'','',1)

	DECLARE @intImportLogId INT
	SELECT @intImportLogId  =SCOPE_IDENTITY()
	
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
							ysnPosted,intConcurrencyId,dtmDateEntered,intEntityId,strSourceId,strJournalType,strRecurringStatus,strSourceType)
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
			dtmDateEntered,
			intEntityId,
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
		CASE WHEN glhst_amt >= 0 THEN 
			CASE WHEN glhst_dr_cr_ind = 'D' THEN glhst_amt ELSE 0 END
			ELSE CASE WHEN (glhst_dr_cr_ind='C' OR glhst_dr_cr_ind IS NULL) THEN (glhst_amt * -1) ELSE 0 END 
			END AS Debit,			
		0 AS DebitRate,																						-- debit rate		
		CASE WHEN glhst_amt >= 0 THEN 
			CASE WHEN (glhst_dr_cr_ind='C' OR glhst_dr_cr_ind IS NULL) THEN glhst_amt ELSE 0 END
			ELSE CASE WHEN glhst_dr_cr_ind = 'D' THEN (glhst_amt * -1) ELSE 0 END 
			END AS Credit,		
		0 AS CreditRate,		
		glhst_units AS DebitUnits,
		glhst_units AS CreditUnits, -- credit unit rate
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
		GETDATE() as gooddate,
		A4GLIdentity,
		NULL AS NegativeCreditUnits,
		NULL AS NegativeDebitUnits 
	 INTO #iRelyImptblGLJournalDetail
	 FROM  glhstmst 
	 INNER JOIN tblGLCOACrossReference ON 
		SUBSTRING(strCurrentExternalId,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glhst_acct9_16 
	 INNER JOIN tblGLAccount ON tblGLAccount.intAccountId = tblGLCOACrossReference.inti21Id
	 
	 --RESET DebitUnits/CreditUnits
	 UPDATE #iRelyImptblGLJournalDetail SET DebitUnits = 0 ,CreditUnits = 0
	 
	 UPDATE 
	A SET DebitUnits = 
	case
		WHEN B.glhst_units < 0	THEN 0
		ELSE B.glhst_units END,
		NegativeDebitUnits =
			CASE WHEN B.glhst_units < 0	THEN 1 ELSE 0 END

	FROM
	#iRelyImptblGLJournalDetail A
	JOIN glhstmst B ON A.A4GLIdentity = B.A4GLIdentity
	WHERE A.Debit > 0

	UPDATE 
	A SET CreditUnits = 
		CASE 
			WHEN B.glhst_units < 0	THEN 0 --B.glhst_units * -1
			ELSE B.glhst_units END,
		NegativeCreditUnits =
			CASE WHEN B.glhst_units < 0	THEN 1 ELSE 0 END
	FROM
	#iRelyImptblGLJournalDetail A
	JOIN glhstmst B ON A.A4GLIdentity = B.A4GLIdentity
	WHERE A.Credit > 0

	--GL-2040 For Journal entries - if there is a negative credit break into two entries on import
	IF EXISTS(SELECT TOP 1 1 FROM #iRelyImptblGLJournalDetail WHERE NegativeCreditUnits = 1)
	BEGIN
		insert INTO #iRelyImptblGLJournalDetail
		(intJournalId,glhst_trans_dt,intAccountId,Debit,Credit,CreditUnits, DebitUnits,DebitRate,CreditRate,dblUnitsInlbs, DebitUnitsInlbs,strCheckbookNo, strWorkArea,strDescription,strDocument,strComments,strReference,strCorrecting,strSourcePgm,glhst_period,glhst_jrnl_no,glhst_src_id,glhst_src_seq,gooddate,A4GLIdentity)
		SELECT 
		intJournalId,
		A.glhst_trans_dt,
		intAccountId,
		0 AS Debit,
		0 AS Credit,
		CreditUnits = CASE WHEN B.glhst_units < 0 THEN glhst_units * -1 ELSE glhst_units END,
		0 AS DebitUnits,
		0 AS DebitRate,	
		0 AS CreditRate,
		0 AS dblUnitsInlbs,
		0 as DebitUnitsInlbs,
		'' AS strCheckbookNo,
		'' AS strWorkArea,
		'Negative Units for amount ' + CAST(ISNULL(glhst_amt,0) AS NVARCHAR(50)) AS strDescription,
		strDocument,
		strComments,
		strReference,
		'N' AS strCorrecting,
		strSourcePgm,																	-- aptrxu
		A.glhst_period,
		A.glhst_jrnl_no,
		A.glhst_src_id,
		A.glhst_src_seq,    
		gooddate,
		A.A4GLIdentity
		FROM  #iRelyImptblGLJournalDetail A
		JOIN glhstmst B ON A.A4GLIdentity = B.A4GLIdentity
		WHERE NegativeDebitUnits = 1
	END
	IF EXISTS(SELECT TOP 1 1 FROM #iRelyImptblGLJournalDetail WHERE NegativeDebitUnits = 1)
	BEGIN

		INSERT INTO #iRelyImptblGLJournalDetail
		(intJournalId,glhst_trans_dt,intAccountId,Debit,Credit,CreditUnits, DebitUnits,DebitRate,CreditRate,dblUnitsInlbs, DebitUnitsInlbs,strCheckbookNo, strWorkArea,strDescription,strDocument,strComments,strReference,strCorrecting,strSourcePgm,glhst_period,glhst_jrnl_no,glhst_src_id,glhst_src_seq,gooddate,A4GLIdentity)
		SELECT 
		intJournalId,
		A.glhst_trans_dt,
		intAccountId,
		0 AS Debit,
		0 AS Credit,
		0 AS CreditUnits,
		DebitUnits = CASE WHEN B.glhst_units < 0 THEN glhst_units * -1 ELSE glhst_units END,
		0 AS DebitRate,	
		0 AS CreditRate,
		0 AS dblUnitsInlbs,
		0 as DebitUnitsInlbs,
		'' AS strCheckbookNo,
		'' AS strWorkArea,
		'Negative Units for amount ' + CAST(ISNULL(glhst_amt,0) AS NVARCHAR(50)) AS strDescription,
		strDocument,
		strComments,
		strReference,
		'N' AS strCorrecting,
		strSourcePgm,																	-- aptrxu
		A.glhst_period,
		A.glhst_jrnl_no,
		A.glhst_src_id,
		A.glhst_src_seq,    
		gooddate,
		A.A4GLIdentity
		FROM  #iRelyImptblGLJournalDetail A
		JOIN glhstmst B ON A.A4GLIdentity = B.A4GLIdentity
		WHERE NegativeCreditUnits = 1
	END

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
	SET gooddate = CAST (substring(convert(varchar(10),glhst_trans_dt),1,4)
					+substring(convert(varchar(10),glhst_trans_dt),5,2)
					+substring(convert(varchar(10),glhst_trans_dt),7,2) AS DATETIME)
	FROM #iRelyImptblGLJournalDetail
	WHERE ISDATE(substring(convert(varchar(10),glhst_trans_dt),1,4) + substring(convert(varchar(10),glhst_trans_dt),5,2) + substring(convert(varchar(10),glhst_trans_dt),7,2) ) = 1

	
	UPDATE #iRelyImptblGLJournalDetail
	SET gooddate = cast( substring(replace(convert(varchar(20),j.dtmDate,102),'.',''),1,6) + '01'  as datetime )
	FROM #iRelyImptblGLJournalDetail a INNER JOIN
	tblGLJournal j on a.intJournalId =j.intJournalId
	WHERE ISDATE(substring(convert(varchar(10),glhst_trans_dt),1,4) + substring(convert(varchar(10),glhst_trans_dt),5,2) + substring(convert(varchar(10),glhst_trans_dt),7,2) ) = 0
	SELECT @invalidDatesUpdated =  CASE WHEN @@ROWCOUNT > 0  THEN '1' ELSE '0' END

	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT

	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [DETAIL]
	--+++++++++++++++++++++++++++++++++

	INSERT tblGLJournalDetail (intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,dblDebitRate,dblCredit,dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,
								dblUnitsInLBS,strDocument,strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea,strSourceKey)
						SELECT intLineNo,intJournalId,gooddate,intAccountId,Debit,DebitRate,Credit,CreditRate,DebitUnits,CreditUnits,strDescription,1,
								dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea,A4GLIdentity
						FROM  #iRelyImptblGLJournalDetail
						
	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT
						
	--+++++++++++++++++++++++++++++++++++++
	--	UPDATE POST DATE JOURNAL [HEADER]
	--+++++++++++++++++++++++++++++++++++++											
						
	UPDATE tblGLJournal SET dtmDate = (SELECT TOP 1 CAST(CAST(MONTH(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) +'/01/'+ CAST(YEAR(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) as DATETIME) as dtmNewDate FROM tblGLJournalDetail 
                                        WHERE tblGLJournalDetail.intJournalId = tblGLJournal.intJournalId)
										WHERE intJournalId IN (SELECT DISTINCT(intJournalId) FROM #iRelyImptblGLJournalDetail)
                                        						
	IF @@ERROR <> 0	GOTO ROLLBACK_INSERT	

    IF LEN(@result) > 0                                 
		SET @result = @result + ',' + CAST(@intImportLogId AS NVARCHAR(40))  --'SUCCESS SELECT A.intJournalId FROM tblGLJournal A INNER JOIN tblGLCOAImportLogDetail B on A.strJournalId = B.strJournalId WHERE B.intImportLogId IN(' +  @result --(Select (Select CAST(intJournalId AS NVARCHAR(MAX)) + ',' From (select intJournalId from tblGLJournal A left join #iRelyImptblGLJournal B on A.strJournalId = B.strJournalId COLLATE Latin1_General_CI_AS) X FOR XML PATH('')) as intJournalId)
	ELSE
		SET @result = CAST(@intImportLogId AS NVARCHAR(40))				
	
	--SET @result = 'SUCCESS ' + @result
	UPDATE tblSMPreferences set strValue = 'true' where strPreference = 'isHistoricalJournalImported'
	SELECT 'SUCCESS:'+  @result +':' + @invalidDatesUpdated 
--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
COMMIT_INSERT:
	COMMIT TRANSACTION
	GOTO IMPORT_EXIT
ROLLBACK_INSERT:
	ROLLBACK TRANSACTION		            
	SELECT 'Importing Historical Journal error :' + ERROR_MESSAGE()
	GOTO IMPORT_EXIT

IMPORT_EXIT:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#iRelyImptblGLJournal')) DROP TABLE #iRelyImptblGLJournal
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id('tempdb..#iRelyImptblGLJournalDetail')) DROP TABLE #iRelyImptblGLJournalDetail