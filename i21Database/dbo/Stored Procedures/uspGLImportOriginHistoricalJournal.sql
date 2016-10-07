CREATE PROCEDURE [dbo].[uspGLImportOriginHistoricalJournal]
@intEntityId INT
AS
BEGIN
	--SET XACT_ABORT ON
	SET NoCount ON
	
	BEGIN TRY
		BEGIN TRAN
		
		DECLARE @result NVARCHAR(MAX)
		EXECUTE [dbo].[uspGLImportOriginHistoricalJournalCLOSED] @intEntityId ,@result OUTPUT

		SELECT @result = REPLACE(@result , 'SUCCESS ','')


		DECLARE @intCurrencyId NVARCHAR(100) = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD') END))
	
	INSERT INTO tblGLCOAImportLog (strEvent,strIrelySuiteVersion,intEntityId,dtmDate,strMachineName,strJournalType,intConcurrencyId)
		VALUES('Import Origin Historical Journal',(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),@intEntityId,GETDATE(),'','',1)

	DECLARE @intImportLogId INT, @intCompanyId INT

	SELECT TOP 1 @intCompanyId = intCompanySetupID FROM tblSMCompanySetup
	SELECT @intImportLogId  =SCOPE_IDENTITY()

		;WITH ORIGINHEADER AS
		(
				SELECT 
				CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalId,
				CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate,		
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
				NULL AS dtmPosted
				FROM glhstmst
				GROUP BY glhst_period, glhst_src_id, glhst_src_seq	
			
		), ORIGINHEADER_WITHPERIODDATE AS
		(
		
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
			FROM ORIGINHEADER
		)
		INSERT tblGLJournal (
			intCompanyId,
			dtmReverseDate,
			strJournalId,
			strTransactionType, 
			dtmDate,
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
			strSourceType)
		SELECT  
			@intCompanyId,
			dtmReverseDate,
			strJournalId,
			strTransactionType, 
			dtmDate,
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
		FROM ORIGINHEADER_WITHPERIODDATE

		;WITH
		ORIGINDETAIL AS
		(
			SELECT 
			CONVERT(int,glhst_line_no) AS intLineNo,
			tblGLJournal.intJournalId AS intJournalId,
			glhst_trans_dt ,
			tblGLAccount.intAccountId,
			CASE WHEN glhst_dr_cr_ind = 'D' THEN ABS( glhst_amt)ELSE 0 END AS Debit,			
			0 AS DebitRate,																						-- debit rate		
			CASE WHEN glhst_dr_cr_ind = 'C' THEN ABS( glhst_amt)ELSE 0 END AS Credit,			
			0 AS CreditRate,		
			CASE WHEN glhst_dr_cr_ind = 'D' THEN ABS( AccountUnits.Unit)ELSE 0 END AS DebitUnits,			
			CASE WHEN glhst_dr_cr_ind = 'C' THEN ABS( AccountUnits.Unit)ELSE 0 END AS CreditUnits,			
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
			CONVERT(VARCHAR(3),glhst_src_id ) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),(glhst_period)) AS glhst_jrnl_no  ,
			glhst_src_id,
			glhst_src_seq,    
			CASE WHEN 
				ISDATE(substring(convert(varchar(10),glhst_trans_dt),1,4) + substring(convert(varchar(10),glhst_trans_dt),5,2) + substring(convert(varchar(10),glhst_trans_dt),7,2) ) = 1
			THEN
				 CAST (substring(convert(varchar(10),glhst_trans_dt),1,4)
					+substring(convert(varchar(10),glhst_trans_dt),5,2)
					+substring(convert(varchar(10),glhst_trans_dt),7,2) AS DATETIME)
			ELSE
				cast( substring(replace(convert(varchar(20),tblGLJournal.dtmDate,102),'.',''),1,6) + '01'  as datetime )
			END
			AS dtmDate,
			A4GLIdentity
			FROM  glhstmst 
			INNER JOIN tblGLCOACrossReference ON 
			SUBSTRING(strCurrentExternalId,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glhst_acct9_16 
			INNER JOIN tblGLAccount ON tblGLAccount.intAccountId = tblGLCOACrossReference.inti21Id AND strCompanyId = 'Legacy'
			INNER JOIN tblGLJournal ON
				tblGLJournal.strJournalId COLLATE Latin1_General_CI_AS  = CONVERT(VARCHAR(3),glhst_src_id ) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),(glhst_period)) COLLATE Latin1_General_CI_AS 
				AND tblGLJournal.strSourceId  COLLATE Latin1_General_CI_AS  = glhst_src_seq COLLATE Latin1_General_CI_AS 
			OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM tblGLAccountUnit Unit WHERE intAccountUnitId = tblGLAccount.[intAccountUnitId]) U
			OUTER APPLY dbo.fnGLGetAccountUnit(ABS(glhst_units), U.dblLbsPerUnit) AccountUnits
			
		)
		
		SELECT intLineNo,intJournalId,dtmDate,glhst_trans_dt ,
		intAccountId,ROUND(Debit,2)dblDebit,DebitRate,ROUND(Credit,2) dblCredit,CreditRate,DebitUnits,CreditUnits,strDescription,
				dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea,A4GLIdentity
		INTO  #iRelyImptblGLJournalDetail
		FROM  ORIGINDETAIL
		
		DECLARE @invalidDatesUpdated VARCHAR(1) = '0'
		SELECT TOP 1 @invalidDatesUpdated = '1' FROM #iRelyImptblGLJournalDetail WHERE 
		ISDATE(substring(convert(varchar(10),glhst_trans_dt),1,4) 
			+ substring(convert(varchar(10),glhst_trans_dt),5,2) + substring(convert(varchar(10),glhst_trans_dt),7,2) ) = 0
		                     
       

		
		
		INSERT INTO tblGLJournalDetail (
			intCompanyId, 
			intLineNo,
			intJournalId,
			dtmDate,
			intAccountId,
			dblDebit,
			dblDebitRate,
			dblCredit,
			dblCreditRate,
			dblDebitUnit,
			dblCreditUnit,
			strDescription,
			intConcurrencyId,
			dblUnitsInLBS,
			strDocument,
			strComments,
			strReference,
			dblDebitUnitsInLBS,
			strCorrecting,
			strSourcePgm,
			strCheckBookNo,
			strWorkArea,
			strSourceKey)
		SELECT 
			@intCompanyId, 
			intLineNo,
			intJournalId,
			dtmDate,
			intAccountId,
			dblDebit,
			DebitRate,
			dblCredit,
			CreditRate,
			DebitUnits,
			CreditUnits,
			strDescription,
			1,
			dblUnitsInlbs,
			strDocument,
			strComments,
			strReference,
			DebitUnitsInlbs,
			strCorrecting,
			strSourcePgm,
			strCheckbookNo,
			strWorkArea,
			A4GLIdentity
		FROM  #iRelyImptblGLJournalDetail


		UPDATE tblGLJournal 
		SET dtmDate = (SELECT TOP 1 CAST(CAST(MONTH(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) +'/01/'+ CAST(YEAR(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) as DATETIME) as dtmNewDate 
		FROM tblGLJournalDetail 
        WHERE tblGLJournalDetail.intJournalId = tblGLJournal.intJournalId)
		WHERE intJournalId IN (SELECT DISTINCT(intJournalId) FROM #iRelyImptblGLJournalDetail)

		UPDATE tblSMPreferences set strValue = 'true' where strPreference = 'isHistoricalJournalImported'
		SELECT 'SUCCESS:'+  @result +':' + @invalidDatesUpdated 
		
	END TRY
	BEGIN CATCH
		SELECT 'Importing Historical Journal error :' + ERROR_MESSAGE()
		IF(@@TRANCOUNT > 0)
			ROLLBACK TRAN
	END CATCH;
	

	IF(@@TRANCOUNT > 0)
		COMMIT TRAN

	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyImptblGLJournalDetail') DROP TABLE iRelyImptblGLJournalDetail
	IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyImptblGLJournal') DROP TABLE iRelyImptblGLJournal

END