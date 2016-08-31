CREATE PROCEDURE [dbo].uspGLImportOriginHistoricalJournalCLOSED
	@intEntityId INT,
	@result NVARCHAR(MAX)  OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glarcmst]') AND type IN (N'U')) 
BEGIN
DECLARE @sql NVARCHAR(MAX)
DECLARE @ParmDefinition NVARCHAR(100)
	SET @ParmDefinition = N'@intEntityId INT, @resultOut NVARCHAR(MAX) OUTPUT';  
	SET @sql ='
DELETE h FROM glhstmst h
INNER JOIN (SELECT MAX(glarc_period) AS period FROM glarcmst GROUP BY SUBSTRING( CONVERT(VARCHAR(10), glarc_period),1,4)) g
ON h.glhst_period = g.period
WHERE glhst_src_id = ''BBF''


--+++++++++++++++++++++++++++++++++
-- VALIDATIONS
--+++++++++++++++++++++++++++++++++
DECLARE @inti21Id int
SELECT @inti21Id = 1 FROM glarcmst LEFT OUTER JOIN tblGLCOACrossReference ON SUBSTRING(strCurrentExternalId,1,8) = glarc_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glarc_acct9_16 WHERE inti21Id IS NULL
IF (SELECT isnull(@inti21Id, 0)) > 0
BEGIN
 SET @resultOut = ''There are accounts that does not exists at iRely Cross Reference. <br/> Kindly verify at Origin.''
END
ELSE IF (EXISTS(SELECT TOP 1 1 FROM (SELECT SUBSTRING(dtmDate,5,2)+''/01/''+SUBSTRING(dtmDate,1,4) as dtmDate FROM (SELECT CONVERT(VARCHAR(3),glarc_src_id) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),MAX(glarc_period)) AS strJournalId, CONVERT(VARCHAR(12),MAX(glarc_period)) AS dtmDate FROM glarcmst GROUP BY glarc_period, glarc_src_id, glarc_src_seq) tblA) tblB where ISDATE(dtmDate) = 0))
BEGIN
 SET @resultOut = ''There are invalid dates on Historical Transactions. <br/> Kindly verify at Origin.''
END
ELSE IF (EXISTS(SELECT TOP 1 1 FROM glarcmst where LEN(glarc_trans_dt) <> 8))
BEGIN
 SET @resultOut = ''There are invalid dates on Historical Transaction Details. <br/> Kindly verify at Origin.''
END
ELSE
BEGIN
--+++++++++++++++++++++++++++++++++
 -- CLEAN-UP TEMP TABLES
 --+++++++++++++++++++++++++++++++++
   
 IF EXISTS (SELECT top 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''iRelyImptblGLJournal'') DROP TABLE iRelyImptblGLJournal
 IF EXISTS (SELECT top 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''iRelyImptblGLJournalDetail'') DROP TABLE iRelyImptblGLJournalDetail
  
 --+++++++++++++++++++++++++++++++++
 -- TEMP HEADER JOURNAL
 --+++++++++++++++++++++++++++++++++
DECLARE @intCurrencyId NVARCHAR(100) = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE intCurrencyID = (CASE WHEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'') > 0
 THEN (SELECT TOP 1 strValue FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'')
 ELSE (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = ''USD'') END))
SELECT
 CONVERT(VARCHAR(3),glarc_src_id) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),MAX(glarc_period)) AS strJournalId,
 CONVERT(VARCHAR(12),MAX(glarc_period)) AS dtmDate, -- took the max period for the unique transaction - glarc_period controls posting period.
 MAX(glarc_ref) AS strDescription, -- strDescription
 ''General Journal'' AS strTransactionType, -- Hard coded the transaction type
 ''Origin Journal'' AS strJournalType, -- Hard coded transaction type.
 glarc_src_seq AS strSourceId,
 glarc_src_id AS strSourceType,
 @intCurrencyId AS intCurrencyId, -- intCurrencyId
 0 AS ysnPosted, -- ysnPosted
 @intEntityId AS intEntityId, -- intEntityId
 1 AS intConcurrencyId, -- intConcurrencyId
 NULL AS strReverseLink,
 NULL AS strRecurringStatus,
 GETDATE() AS dtmDateEntered, -- dtmJournalDate/dtmDateEntered
 NULL AS dtmReverseDate, -- We should not import reversing transactions
 NULL AS dblExchangeRate, -- exchange rate
 NULL AS dtmPosted -- date posted--convert(varchar,(12),MAX(glarc_period)) removed per liz
 INTO #iRelyImptblGLJournal
 FROM glarcmst
 GROUP BY glarc_period, glarc_src_id, glarc_src_seq
IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
--+++++++++++++++++++++++++++++++++
 -- INSERT IMPORT LOGS
 --+++++++++++++++++++++++++++++++++
 DECLARE @intImportLogId INT
 INSERT INTO tblGLCOAImportLog (strEvent,strIrelySuiteVersion,intEntityId,dtmDate,strMachineName,strJournalType,intConcurrencyId)
 VALUES(''Import Origin Historical Journal'',(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),@intEntityId,GETDATE(),'''','''',1)
 SELECT @intImportLogId = SCOPE_IDENTITY()
   
 INSERT INTO tblGLCOAImportLogDetail (intImportLogId,strEventDescription,strPeriod,strSourceNumber,strSourceSystem,strJournalId,intConcurrencyId)
 SELECT @intImportLogId,strDescription,dtmDate,strSourceId,strSourceType,strJournalId,1 FROM #iRelyImptblGLJournal
   
 IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
--+++++++++++++++++++++++++++++++++
 -- UPDATE POSTING DATE
 --+++++++++++++++++++++++++++++++++
--UPDATE #iRelyImptblGLJournal SET dtmDate = SUBSTRING(dtmDate,5,2)+''/01/''+SUBSTRING(dtmDate,1,4) FROM #iRelyImptblGLJournal
   
   
 --+++++++++++++++++++++++++++++++++
 -- INSERT JOURNAL [HEADER]
 --+++++++++++++++++++++++++++++++++
INSERT tblGLJournal (dtmReverseDate,strJournalId,strTransactionType, dtmDate,strReverseLink,intCurrencyId,dblExchangeRate,dtmPosted,strDescription,
 ysnPosted,intConcurrencyId,dtmDateEntered,intEntityId,strSourceId,strJournalType,strRecurringStatus,strSourceType)
 SELECT dtmReverseDate,
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
IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
--+++++++++++++++++++++++++++++++++
 -- TEMP DETAIL JOURNAL
 --+++++++++++++++++++++++++++++++++
SELECT
 CONVERT(int,glarc_line_no) AS intLineNo,
 CONVERT(int,1) AS intJournalId,
 glarc_trans_dt,
 tblGLAccount.intAccountId,
 CASE WHEN glarc_amt >= 0 THEN CASE WHEN glarc_dr_cr_ind = ''D'' THEN glarc_amt ELSE 0 END
 ELSE CASE WHEN (glarc_dr_cr_ind=''C'' OR glarc_dr_cr_ind IS NULL) THEN (glarc_amt * -1) ELSE 0 END END AS Debit,
 0 AS DebitRate, -- debit rate
 CASE WHEN glarc_amt >= 0 THEN CASE WHEN (glarc_dr_cr_ind=''C'' OR glarc_dr_cr_ind IS NULL) THEN glarc_amt ELSE 0 END
 ELSE CASE WHEN glarc_dr_cr_ind = ''D'' THEN (glarc_amt * -1) ELSE 0 END END AS Credit,
 0 AS CreditRate, -- credit rate
 glarc_units AS DebitUnits,
 glarc_units AS CreditUnits,
 glarc_ref AS strDescription,
 NULL AS intCurrencyId,
 0 AS dblUnitsInlbs,
 glarc_doc AS strDocument,
 glarc_comments AS strComments,
 glarc_ref AS strReference,
 0 AS DebitUnitsInlbs,
 ''N'' AS strCorrecting,
 glarc_source_pgm AS strSourcePgm, -- aptrxu
 '''' AS strCheckbookNo, -- 01
 '''' AS strWorkArea,
 glarc_period,
 CONVERT(VARCHAR(3),glarc_src_id) + CONVERT(VARCHAR(5),glarc_src_seq) + CONVERT(VARCHAR(6),(glarc_period)) AS glarc_jrnl_no,
 glarc_src_id,
 glarc_src_seq,
 GETDATE() as gooddate,
 A4GLIdentity,
 NULL AS NegativeCreditUnits ,
 NULL AS NegativeDebitUnits 
 INTO #iRelyImptblGLJournalDetail
 FROM glarcmst
 INNER JOIN tblGLCOACrossReference ON
 SUBSTRING(strCurrentExternalId,1,8) = glarc_acct1_8 AND SUBSTRING(strCurrentExternalId,10,8) = glarc_acct9_16
 INNER JOIN tblGLAccount ON tblGLAccount.intAccountId = tblGLCOACrossReference.inti21Id
 
--RESET DebitUnits/CreditUnits
UPDATE #iRelyImptblGLJournalDetail SET DebitUnits = 0 ,CreditUnits = 0

UPDATE 
A SET DebitUnits = 
case
	WHEN B.glarc_units < 0	THEN B.glarc_units * -1
	ELSE B.glarc_units END,
	NegativeDebitUnits =
			CASE WHEN B.glarc_units < 0	THEN 1 ELSE 0 END

FROM
#iRelyImptblGLJournalDetail A
JOIN glarcmst B ON A.A4GLIdentity = B.A4GLIdentity
WHERE A.Debit > 0

UPDATE 
A SET CreditUnits = 
	CASE 
		WHEN B.glarc_units < 0	THEN 0 
		ELSE B.glarc_units END,
	NegativeCreditUnits =
		CASE WHEN B.glarc_units < 0	THEN 1 ELSE 0 END
FROM
#iRelyImptblGLJournalDetail A
JOIN glarcmst B ON A.A4GLIdentity = B.A4GLIdentity
WHERE A.Credit > 0

	--GL-2040 For Journal entries - if there is a negative credit break into two entries on import

ALTER TABLE #iRelyImptblGLJournalDetail ALTER COLUMN strDescription CHAR(50) NULL
IF EXISTS(SELECT TOP 1 1 FROM #iRelyImptblGLJournalDetail WHERE NegativeCreditUnits = 1)
	BEGIN
		insert INTO #iRelyImptblGLJournalDetail
		(intJournalId,glarc_trans_dt,intAccountId,Debit,Credit,CreditUnits, DebitUnits,DebitRate,CreditRate,dblUnitsInlbs, DebitUnitsInlbs,strCheckbookNo, strWorkArea,strDescription,strDocument,strComments,strReference,strCorrecting,strSourcePgm,glarc_period,glarc_jrnl_no,glarc_src_id,glarc_src_seq,gooddate,A4GLIdentity)
		SELECT 
		intJournalId,
		A.glarc_trans_dt,
		intAccountId,
		0 AS Debit,
		0 AS Credit,
		CreditUnits = CASE WHEN B.glarc_units < 0 THEN glarc_units * -1 ELSE glarc_units END,
		0 AS DebitUnits,
		0 AS DebitRate,	
		0 AS CreditRate,
		0 AS dblUnitsInlbs,
		0 as DebitUnitsInlbs,
		'''' AS strCheckbookNo,
		'''' AS strWorkArea,
		''Negative Units for amount '' + CAST(ISNULL(glarc_amt,0) AS NVARCHAR(50)) AS strDescription,
		strDocument,
		strComments,
		strReference,
		''N'' AS strCorrecting,
		strSourcePgm,																	-- aptrxu
		A.glarc_period,
		A.glarc_jrnl_no,
		A.glarc_src_id,
		A.glarc_src_seq,    
		gooddate,
		A.A4GLIdentity
		FROM  #iRelyImptblGLJournalDetail A
		JOIN glarcmst B ON A.A4GLIdentity = B.A4GLIdentity
		WHERE NegativeDebitUnits = 1
	END
	IF EXISTS(SELECT TOP 1 1 FROM #iRelyImptblGLJournalDetail WHERE NegativeDebitUnits = 1)
	BEGIN

		INSERT INTO #iRelyImptblGLJournalDetail
		(intJournalId,glarc_trans_dt,intAccountId,Debit,Credit,CreditUnits, DebitUnits,DebitRate,CreditRate,dblUnitsInlbs, DebitUnitsInlbs,strCheckbookNo, strWorkArea,strDescription,strDocument,strComments,strReference,strCorrecting,strSourcePgm,glarc_period,glarc_jrnl_no,glarc_src_id,glarc_src_seq,gooddate,A4GLIdentity)
		SELECT 
		intJournalId,
		A.glarc_trans_dt,
		intAccountId,
		0 AS Debit,
		0 AS Credit,
		0 AS CreditUnits,
		DebitUnits = CASE WHEN B.glarc_units < 0 THEN glarc_units * -1 ELSE glarc_units END,
		0 AS DebitRate,	
		0 AS CreditRate,
		0 AS dblUnitsInlbs,
		0 as DebitUnitsInlbs,
		'''' AS strCheckbookNo,
		'''' AS strWorkArea,
		''Negative Units for amount '' + CAST(ISNULL(glarc_amt,0) AS NVARCHAR(50)) AS strDescription,
		strDocument,
		strComments,
		strReference,
		''N'' AS strCorrecting,
		strSourcePgm,																	-- aptrxu
		A.glarc_period,
		A.glarc_jrnl_no,
		A.glarc_src_id,
		A.glarc_src_seq,    
		gooddate,
		A.A4GLIdentity
		FROM  #iRelyImptblGLJournalDetail A
		JOIN glarcmst B ON A.A4GLIdentity = B.A4GLIdentity
		WHERE NegativeCreditUnits = 1
	END	


 IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
 
  --+++++++++++++++++++++++++++++++++
 -- UPDATE COLLATE JOURNAL
 --+++++++++++++++++++++++++++++++++
ALTER TABLE #iRelyImptblGLJournalDetail
 ALTER COLUMN glarc_jrnl_no
 VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL
ALTER TABLE #iRelyImptblGLJournalDetail
 ALTER COLUMN glarc_src_id
 CHAR(3) COLLATE Latin1_General_CI_AS NOT NULL
ALTER TABLE #iRelyImptblGLJournalDetail
 ALTER COLUMN glarc_src_seq
 CHAR(5) COLLATE Latin1_General_CI_AS NOT NULL
IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 -- UPDATE DETAIL [intJournalId] BASED ON HEADER
 --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATE #iRelyImptblGLJournalDetail
 SET #iRelyImptblGLJournalDetail.intJournalId = tblGLJournal.intJournalId
 FROM #iRelyImptblGLJournalDetail
 INNER JOIN tblGLJournal ON
 tblGLJournal.strJournalId = #iRelyImptblGLJournalDetail.glarc_jrnl_no
 AND tblGLJournal.strSourceId = glarc_src_seq
 --AND glarc_period = convert(varchar(4),SUBSTRING (convert(varchar(100),dtmDate,101),7,4)) + convert(varchar(4),SUBSTRING(convert(varchar(100),dtmDate,101),1,2))
IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 -- ASSIGN TRANSACTION Id BASED ON NEW HEADER GROUPING
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
 -- SELECT @last1= (SELECT MIN(intJournalId) FROM #iRelyImptblGLJournalDetail WHERE intLineNo = 0)
-- IF @last1 <> @lastprior
 -- BEGIN
 -- SET @line1 = 0
 -- END
-- SET ROWCOUNT 0
 -- SELECT @lastprior = @last1
 -- SELECT @line1 = (SELECT Max (intLineNo) FROM #iRelyImptblGLJournalDetail WHERE intJournalId = @last1)
-- SELECT @line1 = @line1 + 1
-- SET ROWCOUNT 1
 -- UPDATE #iRelyImptblGLJournalDetail set intLineNo = @line1
 -- WHERE intLineNo = 0 and intJournalId = @last1
--END
--++++++++++++++++++++++++++++
 -- UPDATE GOODDATE
 --++++++++++++++++++++++++++++
SET ROWCOUNT 0

UPDATE #iRelyImptblGLJournalDetail
SET gooddate = CAST (substring(convert(varchar(10),glarc_trans_dt),1,4)
				+substring(convert(varchar(10),glarc_trans_dt),5,2)
				+substring(convert(varchar(10),glarc_trans_dt),7,2) AS DATETIME)
FROM #iRelyImptblGLJournalDetail
WHERE ISDATE(substring(convert(varchar(10),glarc_trans_dt),1,4) + substring(convert(varchar(10),glarc_trans_dt),5,2) + substring(convert(varchar(10),glarc_trans_dt),7,2) ) = 1

UPDATE #iRelyImptblGLJournalDetail
SET gooddate = CAST (substring(convert(varchar(10),glarc_trans_dt),1,4)
				+substring(convert(varchar(10),glarc_trans_dt),5,2)
				+ ''01'' AS DATETIME)
FROM #iRelyImptblGLJournalDetail
WHERE ISDATE(substring(convert(varchar(10),glarc_trans_dt),1,4) + substring(convert(varchar(10),glarc_trans_dt),5,2) + substring(convert(varchar(10),glarc_trans_dt),7,2) ) = 0

IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
--+++++++++++++++++++++++++++++++++
 -- INSERT JOURNAL [DETAIL]
 --+++++++++++++++++++++++++++++++++
INSERT tblGLJournalDetail (intLineNo,intJournalId,dtmDate,intAccountId,dblDebit,dblDebitRate,dblCredit,dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,
 dblUnitsInLBS,strDocument,strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea,strSourceKey)
 SELECT intLineNo,intJournalId,gooddate,intAccountId,ROUND(Debit,2),DebitRate,ROUND(Credit,2),CreditRate,DebitUnits,CreditUnits,strDescription,1,
 dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea,A4GLIdentity
 FROM #iRelyImptblGLJournalDetail
   
 IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
   
 --+++++++++++++++++++++++++++++++++++++
 -- UPDATE POST DATE JOURNAL [HEADER]
 --+++++++++++++++++++++++++++++++++++++
   
 UPDATE tblGLJournal SET dtmDate = (SELECT TOP 1 CAST(CAST(MONTH(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) +''/01/''+ CAST(YEAR(tblGLJournalDetail.dtmDate) as NVARCHAR(10)) as DATETIME) as dtmNewDate FROM tblGLJournalDetail
 WHERE tblGLJournalDetail.intJournalId = tblGLJournal.intJournalId)
 WHERE intJournalId IN (SELECT DISTINCT(intJournalId) FROM #iRelyImptblGLJournalDetail)

 IF @@ERROR <> 0 GOTO ROLLBACK_INSERT
    
 SET @resultOut = ''SUCCESS '' + CAST(@intImportLogId AS NVARCHAR(40))
   
END
   
--=====================================================================================================================================
-- FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
COMMIT_INSERT:
 GOTO IMPORT_EXIT
   
ROLLBACK_INSERT:
 SELECT @resultOut =  ''One Time Closed Year Conversion error :'' + ERROR_MESSAGE()
 GOTO IMPORT_EXIT

IMPORT_EXIT:
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id(''tempdb..#iRelyImptblGLJournal'')) DROP TABLE #iRelyImptblGLJournal
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id(''tempdb..#iRelyImptblGLJournalDetail'')) DROP TABLE #iRelyImptblGLJournalDetail'
 EXEC sp_executesql @sql, @ParmDefinition,@resultOut = @result OUTPUT
END
ELSE
	SET @result = 'SUCCESS '


 