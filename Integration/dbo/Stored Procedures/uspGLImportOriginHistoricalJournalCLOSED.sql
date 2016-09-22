CREATE PROCEDURE [dbo].[uspGLImportOriginHistoricalJournalCLOSED]
@intEntityId INT,
@result NVARCHAR(MAX)  OUTPUT
AS
BEGIN

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glarcmst]') AND type IN (N'U')) 
	BEGIN
		SELECT @result = 'SUCCESS '
		RETURN
	END

	DECLARE @sql NVARCHAR(MAX)
	DECLARE @ParmDefinition NVARCHAR(100)
	SET @ParmDefinition = N'@intEntityId INT, @resultOut NVARCHAR(MAX) OUTPUT';  
	SET @sql =
		'DELETE h FROM glarcmst h
		INNER JOIN (SELECT MAX(glarc_period) AS period FROM glarcmst GROUP BY SUBSTRING( CONVERT(VARCHAR(10), glarc_period),1,4)) g
		ON h.glarc_period = g.period
		WHERE glarc_src_id = ''BBF''


		--+++++++++++++++++++++++++++++++++
		-- VALIDATIONS
		--+++++++++++++++++++++++++++++++++
		DECLARE @inti21Id int
		SELECT @inti21Id = 1 FROM glarcmst LEFT OUTER JOIN tblGLCOACrossReference ON SUBSTRING(strCurrentExternalId,1,8) = glarc_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glarc_acct9_16 WHERE inti21Id IS NULL
		IF (SELECT isnull(@inti21Id, 0)) > 0
		 SET @resultOut = ''There are accounts that does not exists at iRely Cross Reference. <br/> Kindly verify at Origin.''
		ELSE
		IF (EXISTS(SELECT TOP 1 1 FROM (SELECT SUBSTRING(dtmDate,5,2)+''/01/''+SUBSTRING(dtmDate,1,4) as dtmDate FROM (SELECT CONVERT(VARCHAR(3),glarc_src_id) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),MAX(glarc_period)) AS strJournalId, CONVERT(VARCHAR(12),MAX(glarc_period)) AS dtmDate FROM glarcmst GROUP BY glarc_period, glarc_src_id, glarc_src_seq) tblA) tblB where ISDATE(dtmDate) = 0))
		 SET @resultOut = ''There are invalid dates on Historical Transactions. <br/> Kindly verify at Origin.''
		ELSE
		IF (EXISTS(SELECT TOP 1 1 FROM glarcmst where LEN(glarc_trans_dt) <> 8))
		 SET @resultOut = ''There are invalid dates on Historical Transaction Details. <br/> Kindly verify at Origin.''

		IF(@resultOut IS NOT NULL)
			RETURN 


		IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''iRelyImptblGLJournalDetail'') DROP TABLE iRelyImptblGLJournalDetail
		IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''iRelyImptblGLJournal'') DROP TABLE iRelyImptblGLJournal

		DECLARE @intCurrencyId NVARCHAR(100) = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'') > 0 
																		THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'')
																		ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD'') END))
	
		INSERT INTO tblGLCOAImportLog (strEvent,strIrelySuiteVersion,intEntityId,dtmDate,strMachineName,strJournalType,intConcurrencyId)
			VALUES(''Import Origin Historical Journal'',(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),@intEntityId,GETDATE(),'','',1)

		DECLARE @intImportLogId INT

		SELECT @intImportLogId  =SCOPE_IDENTITY()
		;WITH ORIGINHEADER AS
		(
				SELECT 
				CONVERT(VARCHAR(3),glarc_src_id) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),MAX(glarc_period)) AS strJournalId,
				CONVERT(VARCHAR(12),MAX(glarc_period)) AS dtmDate,		
				MAX(glarc_ref) AS strDescription,																									-- strDescription
				''General Journal'' AS strTransactionType,																							-- Hard coded the transaction type
				''Origin Journal'' AS strJournalType,																						-- Hard coded transaction type.	
				glarc_src_seq AS strSourceId,
				glarc_src_id AS strSourceType,
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
				FROM glarcmst
				GROUP BY glarc_period, glarc_src_id, glarc_src_seq	
			
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
			dtmReverseDate,strJournalId,strTransactionType, 
		dtmDate,
		strReverseLink,intCurrencyId,dblExchangeRate,dtmPosted,strDescription,
							ysnPosted,intConcurrencyId,dtmDateEntered,intEntityId,strSourceId,strJournalType,strRecurringStatus,strSourceType)
		SELECT  dtmReverseDate,
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
			CONVERT(int,glarc_line_no) AS intLineNo,
			tblGLJournal.intJournalId AS intJournalId,
			glarc_trans_dt ,
			tblGLAccount.intAccountId,
			CASE WHEN glarc_dr_cr_ind = ''D'' THEN ABS( glarc_amt)ELSE 0 END AS Debit,			
			0 AS DebitRate,																						-- debit rate		
			CASE WHEN glarc_dr_cr_ind = ''C'' THEN ABS( glarc_amt)ELSE 0 END AS Credit,			
			0 AS CreditRate,		
			CASE WHEN glarc_dr_cr_ind = ''D'' THEN ABS( AccountUnits.Unit)ELSE 0 END AS DebitUnits,			
			CASE WHEN glarc_dr_cr_ind = ''C'' THEN ABS( AccountUnits.Unit)ELSE 0 END AS CreditUnits,			
			glarc_ref AS strDescription,
			NULL AS intCurrencyId,
			0 AS dblUnitsInlbs,
			glarc_doc AS strDocument,
			glarc_comments AS strComments,
			glarc_ref AS strReference,
			0 AS DebitUnitsInlbs,
			''N'' AS strCorrecting,
			glarc_source_pgm AS strSourcePgm,																	-- aptrxu
			'' AS strCheckbookNo,																				-- 01
			'' AS strWorkArea,
			glarc_period,
			CONVERT(VARCHAR(3),glarc_src_id ) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),(glarc_period)) AS glarc_jrnl_no  ,
			glarc_src_id,
			glarc_src_seq,    
			CASE WHEN 
				ISDATE(substring(convert(varchar(10),glarc_trans_dt),1,4) + substring(convert(varchar(10),glarc_trans_dt),5,2) + substring(convert(varchar(10),glarc_trans_dt),7,2) ) = 1
			THEN
				 CAST (substring(convert(varchar(10),glarc_trans_dt),1,4)
					+substring(convert(varchar(10),glarc_trans_dt),5,2)
					+substring(convert(varchar(10),glarc_trans_dt),7,2) AS DATETIME)
			ELSE
				cast( substring(replace(convert(varchar(20),tblGLJournal.dtmDate,102),''.'',''),1,6) + ''01''  as datetime )
			END
			AS dtmDate,
			A4GLIdentity
			FROM  glarcmst 
			INNER JOIN tblGLCOACrossReference ON 
			SUBSTRING(strCurrentExternalId,1,8) = glarc_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glarc_acct9_16 
			INNER JOIN tblGLAccount ON tblGLAccount.intAccountId = tblGLCOACrossReference.inti21Id
			INNER JOIN tblGLJournal ON
				tblGLJournal.strJournalId COLLATE Latin1_General_CI_AS  = CONVERT(VARCHAR(3),glarc_src_id ) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),(glarc_period)) COLLATE Latin1_General_CI_AS 
				AND tblGLJournal.strSourceId  COLLATE Latin1_General_CI_AS  = glarc_src_seq COLLATE Latin1_General_CI_AS 
			OUTER APPLY (SELECT dblLbsPerUnit,[strUOMCode] FROM tblGLAccountUnit Unit WHERE intAccountUnitId = tblGLAccount.[intAccountUnitId]) U
			OUTER APPLY dbo.fnGLGetAccountUnit(ABS(glarc_units), U.dblLbsPerUnit) AccountUnits
		)
		
		SELECT intLineNo,intJournalId,dtmDate,glarc_trans_dt ,
		intAccountId,ROUND(Debit,2)dblDebit,DebitRate,ROUND(Credit,2) dblCredit,CreditRate,DebitUnits,CreditUnits,strDescription,
				dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea,A4GLIdentity
		INTO  #iRelyImptblGLJournalDetail
		FROM  ORIGINDETAIL
		
		DECLARE @invalidDatesUpdated VARCHAR(1) = ''0''
		SELECT TOP 1 @invalidDatesUpdated = ''1'' FROM #iRelyImptblGLJournalDetail WHERE 
		ISDATE(substring(convert(varchar(10),glarc_trans_dt),1,4) 
			+ substring(convert(varchar(10),glarc_trans_dt),5,2) + substring(convert(varchar(10),glarc_trans_dt),7,2) ) = 0
		 
		
		
		INSERT INTO tblGLJournalDetail (intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,dblDebitRate,dblCredit,dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,
								dblUnitsInLBS,strDocument,strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea,strSourceKey)
						SELECT intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,DebitRate,dblCredit,CreditRate,DebitUnits,CreditUnits,strDescription,1,
								dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea,A4GLIdentity
						FROM  #iRelyImptblGLJournalDetail


		UPDATE tblGLJournal SET dtmDate = (SELECT TOP 1 CAST(CAST(MONTH(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) +''/01/''+ CAST(YEAR(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) as DATETIME) as dtmNewDate FROM tblGLJournalDetail 
                                        WHERE tblGLJournalDetail.intJournalId = tblGLJournal.intJournalId)
										WHERE intJournalId IN (SELECT DISTINCT(intJournalId) FROM #iRelyImptblGLJournalDetail)'
	EXEC sp_executesql @sql, @ParmDefinition,@intEntityId = @intEntityId, @resultOut = @result OUTPUT
END