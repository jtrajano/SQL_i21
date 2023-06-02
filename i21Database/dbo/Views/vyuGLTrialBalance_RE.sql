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
	0 MTD,
	ExpRev_Prior.intCurrencyId
	--,Fiscal.strPeriod
FROM DETAIL Fiscal
OUTER APPLY ( 
	SELECT  D.intCurrencyId, SUM(ISNULL(dblDebit,0) - ISNULL(dblCredit,0)) beginningBalance
	FROM tblGLAccount A LEFT JOIN  tblGLDetail D on D.intAccountId = A.intAccountId
	LEFT JOIN tblGLAccountGroup G ON G.intAccountGroupId = A.intAccountGroupId
	WHERE D.dtmDate < Fiscal.FiscalStart and D.ysnIsUnposted = 0
	AND G.strAccountType in ('Expense','Revenue')  
	GROUP BY D.intCurrencyId
)ExpRev_Prior