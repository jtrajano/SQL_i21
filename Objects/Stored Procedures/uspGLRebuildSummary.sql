CREATE PROCEDURE [dbo].[uspGLRebuildSummary]
AS
TRUNCATE TABLE [dbo].[tblGLSummary]
DECLARE @intCompanyId INT
SELECT TOP 1 @intCompanyId = intMultiCompanyId FROM tblSMCompanySetup 

INSERT INTO tblGLSummary(
	intAccountId
	,intMultiCompanyId
	,dtmDate
	,dblDebit
	,dblCredit
	,dblDebitForeign
	,dblCreditForeign 
	,dblDebitUnit
	,dblCreditUnit
	,strCode
	,intConcurrencyId
)
SELECT
	intAccountId
	,intMultiCompanyId = ISNULL(intMultiCompanyId, @intCompanyId) 
	,dtmDate
	,dblDebit = SUM(ISNULL(dblDebit,0)) 
	,dblCredit = SUM(ISNULL(dblCredit,0)) 
	,dblDebitForeign = SUM(ISNULL(dblDebitForeign,0))
	,dblCreditForeign = SUM(ISNULL(dblCreditForeign,0)) 
	,dblDebitUnit = SUM(ISNULL(dblDebitUnit,0))
	,dblCreditUnit = SUM(ISNULL(dblCreditUnit,0)) 
	,strCode
	,1 
FROM tblGLDetail
WHERE ysnIsUnposted = 0	
GROUP BY   
	intAccountId
	,ISNULL(intMultiCompanyId, @intCompanyId)
	,dtmDate
	,strCode

EXEC uspGLRecalcTrialBalance