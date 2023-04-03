CREATE VIEW [dbo].[vyuGLTrialBalance_RE]
AS
WITH DETAIL as (
	SELECT F.intRetainAccount intAccountId,
		F.intFiscalYearId, 
		P.intGLFiscalYearPeriodId,
		P.dtmEndDate PeriodEnd, 
		P.dtmStartDate PeriodStart, 
		F.dtmDateFrom FiscalStart,
		P.strPeriod,
		DATEDIFF(DAY,F.dtmDateTo, F.dtmDateFrom) FiscalDays
	FROM 
		tblGLFiscalYear F JOIN
		tblGLFiscalYearPeriod P on F.intFiscalYearId = P.intFiscalYearId
)
SELECT 
	Fiscal.*,
	ISNULL(ExpRev_Prior.beginningBalance,0) YTD,
	PERIODACTIVITY.beginningBalance MTD,
	ExpRev_Prior.intCurrencyId
	--,Fiscal.strPeriod
FROM DETAIL Fiscal
-- OUTER APPLY ( 
-- 	SELECT  SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)) beginningBalance
-- 	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
-- 	LEFT JOIN tblGLAccountGroup G ON G.intAccountGroupId = A.intAccountGroupId
-- 	WHERE D.dtmDate BETWEEN Fiscal.FiscalStart and PeriodEnd and D.ysnIsUnposted = 0
-- 	AND G.strAccountType in ('Expense','Revenue')  
-- )ExpRev_Current
OUTER APPLY ( 
	SELECT  D.intCurrencyId, SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	LEFT JOIN tblGLAccountGroup G ON G.intAccountGroupId = A.intAccountGroupId
	WHERE D.dtmDate < Fiscal.FiscalStart and D.ysnIsUnposted = 0
	AND G.strAccountType in ('Expense','Revenue')  
	GROUP BY D.intCurrencyId
)ExpRev_Prior
OUTER APPLY(
	SELECT  SUM(ISNULL(dblDebit,0) - isnull(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	WHERE D.dtmDate Between Fiscal.PeriodStart and Fiscal.PeriodEnd and D.ysnIsUnposted = 0
	AND Fiscal.intAccountId = A.intAccountId
	AND ExpRev_Prior.intCurrencyId = D.intCurrencyId
	GROUP BY A.intAccountId, D.intCurrencyId
)PERIODACTIVITY