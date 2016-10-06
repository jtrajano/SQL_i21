CREATE PROCEDURE  [dbo].[uspGLSummaryRecalculate]
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail GROUP BY strTransactionId, ysnIsUnposted HAVING SUM(dblDebit-dblCredit)<>0 and ysnIsUnposted = 0)
	BEGIN
		RAISERROR(60010,16,1)--'Unable to recalculate summary. General Ledger Detail has out of balance transactions.'
		RETURN
	END
	DELETE [dbo].[tblGLSummary]
	DECLARE @intCompanyId INT
	SELECT TOP 1 @intCompanyId = intCompanySetupID FROM tblSMCompanySetup 
	INSERT INTO tblGLSummary
	(intCompanyId,intAccountId,dtmDate,dblDebit,dblCredit,dblDebitUnit,dblCreditUnit,strCode,intConcurrencyId)
	SELECT
		 @intCompanyId
		,intAccountId
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