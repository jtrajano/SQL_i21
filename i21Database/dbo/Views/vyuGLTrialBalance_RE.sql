CREATE VIEW [dbo].[vyuGLTrialBalance_RE]
AS

WITH DETAIL as (

	SELECT F.intRetainAccount intAccountId,
		F.intFiscalYearId, 
		P.intGLFiscalYearPeriodId,
		P.dtmEndDate PeriodEnd, 
		P.dtmStartDate PeriodStart, 
		F.dtmDateFrom FiscalStart
	FROM 
		tblGLFiscalYear F JOIN
		tblGLFiscalYearPeriod P on F.intFiscalYearId = P.intFiscalYearId
)
SELECT 
	Fiscal.intAccountId, Fiscal.intFiscalYearId, Fiscal.intGLFiscalYearPeriodId,
	Fiscal.PeriodStart
	,ISNULL(BOF2EOP.beginningBalance,0) + ISNULL( EXPENSEREVENUE.beginningBalance,0) YTD
	,PERIODACTIVITY.beginningBalance MTD
FROM DETAIL Fiscal
CROSS APPLY ( 
	SELECT  SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	LEFT JOIN tblGLAccountGroup G ON G.intAccountGroupId = A.intAccountGroupId
	WHERE D.dtmDate < Fiscal.FiscalStart and D.ysnIsUnposted = 0
	AND G.strAccountType in ('Expense','Revenue')  
)EXPENSEREVENUE
CROSS APPLY(
	SELECT  SUM(isnull(dblDebit,0) - isnull(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	WHERE D.dtmDate < Fiscal.PeriodEnd and D.ysnIsUnposted = 0
	AND Fiscal.intAccountId = A.intAccountId
)BOF2EOP
CROSS APPLY(
	SELECT  SUM(isnull(dblDebit,0) - isnull(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	WHERE D.dtmDate Between Fiscal.PeriodStart and Fiscal.PeriodEnd and D.ysnIsUnposted = 0
	AND Fiscal.intAccountId = A.intAccountId
)PERIODACTIVITY






GO

