CREATE VIEW [dbo].[vyuGLTrialBalance_RE]
AS
WITH DETAIL as (

	SELECT F.intRetainAccount intAccountId,
		F.intFiscalYearId, 
		P.intGLFiscalYearPeriodId,
		P.dtmEndDate PeriodEnd, 
		P.dtmStartDate PeriodStart, 
		F.dtmDateFrom FiscalStart,
		B.strAccountId
	FROM 
		tblGLFiscalYear F 
		JOIN tblGLFiscalYearPeriod P on F.intFiscalYearId = P.intFiscalYearId
		JOIN tblGLAccount B on B.intAccountId = F.intRetainAccount
)
SELECT 
	Fiscal.intAccountId, 
	Fiscal.intFiscalYearId, 
	Fiscal.intGLFiscalYearPeriodId,
	Fiscal.PeriodStart,
	PeriodEnd.beginBalance YTD,
	PERIODACTIVITY.beginningBalance MTD
FROM DETAIL Fiscal
OUTER APPLY dbo.fnGLGetBeginningBalanceAndUnitRETB(Fiscal.strAccountId,DATEADD(DAY, 1, Fiscal.PeriodEnd)) PeriodEnd
OUTER APPLY(
	SELECT  SUM(isnull(dblDebit,0) - isnull(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	WHERE D.dtmDate Between Fiscal.PeriodStart and Fiscal.PeriodEnd and D.ysnIsUnposted = 0
	AND Fiscal.intAccountId = A.intAccountId
)PERIODACTIVITY

