CREATE VIEW [dbo].[vyuGLTrialBalance_NonRE]
AS

WITH DETAIL AS(
	SELECT A.intAccountId,A.intAccountGroupId, F.intFiscalYearId, 
		F.dtmDateFrom FiscalStart, P.intGLFiscalYearPeriodId,
		P.dtmStartDate PeriodStart, P.dtmEndDate PeriodEnd
	FROM 
		tblGLAccount A
		inner join tblGLFiscalYear F on 1=1
		JOIN tblGLFiscalYearPeriod P on F.intFiscalYearId = P.intFiscalYearId
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
	,D.intCurrencyId
	,YTD =	SUM(ISNULL(D.dblDebit, 0) - ISNULL(D.dblCredit,0))
	,MTD =	SUM(CASE WHEN D.dtmDate BETWEEN A.PeriodStart AND A.PeriodEnd
				THEN ISNULL(D.dblDebit, 0) - ISNULL(D.dblCredit,0)
				ELSE 0
			END)
FROM 
	ACCOUNTTYPE A
LEFT JOIN tblGLDetail D
	ON D.intAccountId = A.intAccountId
	AND D.ysnIsUnposted = 0
	AND dtmDate BETWEEN 
		CASE WHEN A.strAccountType IN ('Expense', 'Revenue') THEN A.FiscalStart 
		ELSE '01-01-1900'
		END 
	AND A.PeriodEnd
GROUP BY
	A.intAccountId
	,A.intFiscalYearId
	,A.intGLFiscalYearPeriodId
	,A.PeriodStart
	,D.intCurrencyId