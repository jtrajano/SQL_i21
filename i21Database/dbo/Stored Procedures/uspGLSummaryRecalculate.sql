CREATE PROCEDURE  [dbo].[uspGLSummaryRecalculate]
AS
BEGIN

	DELETE [dbo].[tblGLSummary]

	INSERT INTO tblGLSummary
	SELECT
		 intAccountId
		,dtmDate
		,SUM(ISNULL(dblDebit,0)) as dblDebit
		,SUM(ISNULL(dblCredit,0)) as dblCredit
		,SUM(ISNULL(dblDebitUnit,0)) as dblDebitUnit
		,SUM(ISNULL(dblCreditUnit,0)) as dblCreditUnit
		,strCode
		,0 as intConcurrencyId
	FROM
		tblGLDetail
	WHERE ysnIsUnposted = 0	
	GROUP BY intAccountId, dtmDate, strCode
	
	UPDATE tblGLJournalDetail
	SET dblDebitUnit=dblCreditUnit,dblCreditUnit=0
	where dblDebit > 0 and dblCreditUnit > 0 AND dblDebitUnit = 0
 
	UPDATE  tblGLJournalDetail
	SET dblCreditUnit=dblDebitUnit,dblDebitUnit=0
	where dblCredit > 0 and dblDebitUnit > 0 AND dblCreditUnit = 0

 
	update tblGLDetail
	set dblDebitUnit = dblCreditUnit, dblCreditUnit = 0
	where dblDebit > 0 and dblCreditUnit > 0 and dblDebitUnit = 0
 
	update tblGLDetail
	set dblCreditUnit= dblDebitUnit, dblDebitUnit= 0
	where dblCredit > 0 and dblDebitUnit > 0 and dblCreditUnit =0

	
END