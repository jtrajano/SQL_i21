CREATE PROCEDURE  [dbo].[usp_GLImportOriginHistoricalJournal]
@intUserID INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

--+++++++++++++++++++++++++++++++++
--			VALIDATIONS
--+++++++++++++++++++++++++++++++++
IF (EXISTS(SELECT * FROM glhstmst LEFT OUTER JOIN tblGLCOACrossReference ON SUBSTRING(strCurrentExternalID,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalID,10,8) = glhst_acct9_16 WHERE inti21ID IS NULL))
BEGIN	
	SELECT 'There are accounts that does not exists at iRely Cross Reference. <br/> Kindly verify at Origin.' as Result
END
ELSE IF (EXISTS(SELECT * FROM (SELECT SUBSTRING(dtmDate,5,2)+'/01/'+SUBSTRING(dtmDate,1,4) as dtmDate FROM (SELECT CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalID, CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate FROM glhstmst GROUP BY glhst_period, glhst_src_id, glhst_src_seq) tblA) tblB where ISDATE(dtmDate) = 0))
BEGIN	
	SELECT 'There are invalid dates on Historical Transactions. <br/> Kindly verify at Origin.' as Result
END
ELSE
BEGIN
	--+++++++++++++++++++++++++++++++++
	--		 TEMP HEADER JOURNAL
	--+++++++++++++++++++++++++++++++++	

	DECLARE @intCurrencyID NVARCHAR(100) = (select intCurrencyID from tblSMCurrency where strCurrency = 'USD')

	SELECT 
		CONVERT(VARCHAR(3),glhst_src_id) + CONVERT(VARCHAR(5),glhst_src_seq) + CONVERT(VARCHAR(6),MAX(glhst_period)) AS strJournalID,
		CONVERT(VARCHAR(12),MAX(glhst_period)) AS dtmDate,																					-- took the max period for the unique transaction - glhst_period controls posting period.	
		MAX(glhst_ref) AS strDescription,																									-- strDescription
		'General Journal' AS strTransactionType,																							-- Hard coded the transaction type
		'Adjusted Legacy Journal' AS strJournalType,																						-- Hard coded transaction type.	
		glhst_src_seq AS strSourceID,
		glhst_src_id AS strSourceType,
		@intCurrencyID AS intCurrencyID,																									-- intCurrencyID
		0 AS ysnPosted,																														-- ysnPosted	
		@intUserID AS intUserID,																											-- intUserID
		1 AS intConcurrencyId,																											-- intConcurrencyId
		NULL AS strReverseLink,
		NULL AS strRecurringStatus,
		NULL AS dtmJournalDate,																												-- dtmJournalDate
		NULL AS dtmReverseDate,																												-- We should not import reversing transactions	
		NULL AS dblExchangeRate,																											-- exchange rate
		NULL AS dtmPosted																												-- date posted--convert(varchar,(12),MAX(glhst_period)) removed per liz	
	INTO iRelyImptblGLJournal
	FROM glhstmst
	GROUP BY glhst_period, glhst_src_id, glhst_src_seq	


	--+++++++++++++++++++++++++++++++++
	--	   UPDATE POSTING DATE
	--+++++++++++++++++++++++++++++++++

	--UPDATE iRelyImptblGLJournal SET dtmDate = SUBSTRING(dtmDate,5,2)+'/01/'+SUBSTRING(dtmDate,1,4) FROM iRelyImptblGLJournal
	
	
	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [HEADER]
	--+++++++++++++++++++++++++++++++++

	INSERT tblGLJournal (dtmReverseDate,strJournalID,strTransactionType, dtmDate,strReverseLink,intCurrencyID,dblExchangeRate,dtmPosted,strDescription,
							ysnPosted,intConcurrencyId,dtmJournalDate,intUserID,strSourceID,strJournalType,strRecurringStatus,strSourceType)
	SELECT  dtmReverseDate,
			strJournalID,
			strTransactionType, 
			CAST((dbo.[fn_geti21PeriodFromOriginPeriod](SUBSTRING(dtmDate,1,4), SUBSTRING(dtmDate,5,2))) as DATETIME) as dtmDate,
			strReverseLink,
			intCurrencyID,
			dblExchangeRate,
			dtmPosted,
			strDescription,
			ysnPosted,
			intConcurrencyId,
			dtmJournalDate,
			intUserID,
			strSourceID,
			strJournalType,
			strRecurringStatus,
			strSourceType
	FROM iRelyImptblGLJournal


	--+++++++++++++++++++++++++++++++++
	--		 TEMP DETAIL JOURNAL
	--+++++++++++++++++++++++++++++++++

	SELECT 
		CONVERT(int,glhst_line_no) AS intLineNo,
		CONVERT(int,1) AS intJournalID,
		glhst_trans_dt,
		tblGLAccount.intAccountID,
		CASE WHEN glhst_dr_cr_ind='D' THEN glhst_amt ELSE 0 END AS Debit,									-- use debit indicator to show debit column.
		0 AS DebitRate,																						-- debit rate
		CASE WHEN (glhst_dr_cr_ind='C' OR glhst_dr_cr_ind IS NULL) THEN glhst_amt ELSE 0 END AS Credit,
		0 AS CreditRate,																					-- credit rate
		CASE WHEN glhst_units>0 THEN glhst_units ELSE 0 END AS DebitUnits,
		CASE WHEN glhst_units<0 THEN glhst_units*-1 ELSE 0 END AS CreditUnits,
		glhst_ref AS strDescription,
		NULL AS intCurrencyID,
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
	 INTO iRelyImptblGLJournalDetail
	 FROM  glhstmst 
	 INNER JOIN tblGLCOACrossReference ON 
		SUBSTRING(strCurrentExternalID,1,8) = glhst_acct1_8 AND SUBSTRING(strCurrentExternalID,10,8) = glhst_acct9_16 
	 INNER JOIN tblGLAccount ON tblGLAccount.intAccountID = tblGLCOACrossReference.inti21ID
	 
	--+++++++++++++++++++++++++++++++++
	--		 UPDATE COLLATE JOURNAL
	--+++++++++++++++++++++++++++++++++

	ALTER TABLE iRelyImptblGLJournalDetail
		ALTER COLUMN glhst_jrnl_no
			VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL

	ALTER TABLE iRelyImptblGLJournalDetail
		ALTER COLUMN glhst_src_id
			CHAR(3) COLLATE Latin1_General_CI_AS NOT NULL

	ALTER TABLE iRelyImptblGLJournalDetail
		ALTER COLUMN glhst_src_seq
			CHAR(5) COLLATE Latin1_General_CI_AS NOT NULL


	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--		 UPDATE DETAIL [intJournalID] BASED ON HEADER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	UPDATE iRelyImptblGLJournalDetail 
		SET iRelyImptblGLJournalDetail.intJournalID = tblGLJournal.intJournalID
	FROM iRelyImptblGLJournalDetail
	INNER JOIN tblGLJournal ON 
		tblGLJournal.strJournalID = iRelyImptblGLJournalDetail.glhst_jrnl_no 
		AND tblGLJournal.strSourceID = glhst_src_seq
		AND glhst_period = convert(varchar(4),SUBSTRING (convert(varchar(100),dtmDate,101),7,4)) + convert(varchar(4),SUBSTRING(convert(varchar(100),dtmDate,101),1,2))


	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--		 ASSIGN TRANSACTION ID BASED ON NEW HEADER GROUPING
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	--SET ROWCOUNT 0
	--UPDATE iRelyImptblGLJournalDetail
	--SET intLineNo = 0

	--DECLARE @last1 INT
	--DECLARE @lastprior INT
	--DECLARE @line1 INT

	--SET @line1 = 0
	--SET @last1 = 0
	--SET @lastprior = 0

	--WHILE (SELECT COUNT(*) FROM iRelyImptblGLJournalDetail where intLineNo = 0) > 0
	--BEGIN
	--	SELECT @last1= (SELECT MIN(intJournalID) FROM iRelyImptblGLJournalDetail WHERE intLineNo = 0)

	--	IF @last1 <> @lastprior 
	--	BEGIN
	--		SET @line1 = 0
	--	END

	--	SET ROWCOUNT 0
	--	SELECT @lastprior = @last1
	--	SELECT @line1 = (SELECT Max (intLineNo) FROM iRelyImptblGLJournalDetail WHERE intJournalID = @last1)

	--	SELECT @line1 = @line1 + 1

	--	SET ROWCOUNT 1
	--	UPDATE iRelyImptblGLJournalDetail set intLineNo = @line1
	--	WHERE  intLineNo = 0 and intJournalID = @last1

	--END
	

	--++++++++++++++++++++++++++++
	--		UPDATE GOODDATE
	--++++++++++++++++++++++++++++

	SET ROWCOUNT 0

	UPDATE iRelyImptblGLJournalDetail
	SET gooddate = CAST(substring(convert(varchar(10),glhst_trans_dt),5,2)
					+'/'+substring(convert(varchar(10),glhst_trans_dt),7,2)
					+'/'+substring(convert(varchar(10),glhst_trans_dt),1,4) AS DATETIME)
	FROM iRelyImptblGLJournalDetail


	--+++++++++++++++++++++++++++++++++
	--	   INSERT JOURNAL [DETAIL]
	--+++++++++++++++++++++++++++++++++

	INSERT tblGLJournalDetail (intLineNo,intJournalID,dtmDate,intAccountID,dblDebit,dblDebitRate,dblCredit,dblCreditRate,dblDebitUnit,dblCreditUnit,strDescription,intConcurrencyId,
								dblUnitsInLBS,strDocument,strComments,strReference,dblDebitUnitsInLBS,strCorrecting,strSourcePgm,strCheckBookNo,strWorkArea)
						SELECT intLineNo,intJournalID,gooddate,intAccountID,Debit,DebitRate,Credit,CreditRate,DebitUnits,CreditUnits,strDescription,1,
								dblUnitsInlbs,strDocument,strComments,strReference,DebitUnitsInlbs,strCorrecting,strSourcePgm,strCheckbookNo,strWorkArea 
						FROM  iRelyImptblGLJournalDetail
						
						
	DROP TABLE iRelyImptblGLJournal						
	DROP TABLE iRelyImptblGLJournalDetail

	SELECT 'SUCCESSFULLY IMPORTED'
						
END
