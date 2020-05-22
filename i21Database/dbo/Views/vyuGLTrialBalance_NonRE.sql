CREATE VIEW [dbo].[vyuGLTrialBalance_NonRE]
AS

WITH DETAIL AS(
	SELECT A.intAccountId,A.intAccountGroupId, F.intFiscalYearId, 
		F.dtmDateFrom FiscalStart, P.intGLFiscalYearPeriodId,
		P.dtmStartDate PeriodStart, P.dtmEndDate PeriodEnd
	FROM 
		tblGLAccount A,
		tblGLFiscalYear F 
	JOIN tblGLFiscalYearPeriod P on F.intFiscalYearId = P.intFiscalYearId
	WHERE A.intAccountId <> F.intRetainAccount
)
,ACCOUNTTYPE AS
(
	SELECT D.*, G.strAccountType 
	FROM DETAIL D LEFT JOIN tblGLAccountGroup G 
	ON G.intAccountGroupId = D.intAccountGroupId
)
SELECT
	A.intAccountId, A.intFiscalYearId,A.intGLFiscalYearPeriodId
	,A.PeriodStart
	,ISNULL(YTD.beginningBalance,0) YTD
	,ISNULL(MTD.beginningBalance,0) MTD  
FROM 
	ACCOUNTTYPE A 
OUTER APPLY (  
	SELECT SUM(ISNULL(dblDebit, 0) - ISNULL(dblCredit,0)) beginningBalance
	FROM  tblGLDetail D  WHERE D.intAccountId = A.intAccountId
	AND D.ysnIsUnposted = 0
	AND dtmDate BETWEEN 
		CASE WHEN A.strAccountType IN ('Expense', 'Revenue') THEN A.FiscalStart 
		ELSE '01-01-1900'
		END 
	AND A.PeriodEnd
)YTD
OUTER APPLY (  
	SELECT SUM(ISNULL(dblDebit, 0) - ISNULL(dblCredit,0)) beginningBalance
	FROM tblGLDetail D 
	WHERE D.dtmDate BETWEEN A.PeriodStart AND A.PeriodEnd and D.ysnIsUnposted = 0
	AND D.intAccountId = A.intAccountId
)MTD