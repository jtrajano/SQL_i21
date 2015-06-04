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
	
	
END