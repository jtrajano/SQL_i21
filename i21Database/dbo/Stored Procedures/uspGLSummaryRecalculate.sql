CREATE PROCEDURE  [dbo].[uspGLSummaryRecalculate]
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail WHERE dblDebit IS NULL) UPDATE tblGLDetail SET dblDebit = 0 WHERE dblDebit IS NULL 
	IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail WHERE dblCredit IS NULL) UPDATE tblGLDetail SET dblCredit = 0 WHERE dblCredit IS NULL 
	IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail WHERE dblDebitForeign IS NULL) UPDATE tblGLDetail SET dblDebitForeign = 0 WHERE dblDebitForeign IS NULL 
	IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail WHERE dblCreditForeign IS NULL) UPDATE tblGLDetail SET dblCreditForeign = 0 WHERE dblCreditForeign IS NULL 
	IF EXISTS( SELECT TOP 1 1 FROM tblGLDetail WHERE dblDebitUnit IS NULL) UPDATE tblGLDetail SET dblDebitUnit = 0 where dblDebitUnit IS NULL
	IF EXISTS( SELECT TOP 1 1 FROM tblGLDetail WHERE dblCreditUnit IS NULL) UPDATE tblGLDetail SET dblCreditUnit = 0 where dblCreditUnit IS NULL

	IF EXISTS (SELECT TOP 1 1 FROM tblGLDetail GROUP BY strTransactionId, ysnIsUnposted HAVING SUM(dblDebit-dblCredit)<>0 and ysnIsUnposted = 0)
	BEGIN
		RAISERROR('Unable to recalculate summary. General Ledger Detail has out of balance transactions.',16,1)--'Unable to recalculate summary. General Ledger Detail has out of balance transactions.'
		RETURN
	END
	DELETE [dbo].[tblGLSummary]
	DECLARE @intCompanyId INT
	SELECT TOP 1 @intCompanyId = intCompanySetupID FROM tblSMCompanySetup 
	INSERT INTO tblGLSummary
	(intCompanyId,intAccountId,dtmDate,dblDebit,dblCredit,dblDebitForeign, dblCreditForeign,dblDebitUnit,dblCreditUnit,strCode,intConcurrencyId)
	SELECT
		 @intCompanyId
		,intAccountId
		,dtmDate
		,SUM(dblDebit) as dblDebit
		,SUM(dblCredit) as dblCredit
		,SUM(dblDebitForeign) as dblDebitForeign
		,SUM(dblCreditForeign) as dblCreditForeign
		,SUM(dblDebitUnit) as dblDebitUnit
		,SUM(dblCreditUnit) as dblCreditUnit
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