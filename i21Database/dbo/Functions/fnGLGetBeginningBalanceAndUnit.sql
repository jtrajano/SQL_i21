CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnit] 
(	
	-- Add the parameters for the function here
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT  
			strAccountId,
			SUM( 
			CASE WHEN  D.dtmDate IS NOT NULL  AND B.strAccountType IN ('Revenue','Expense') THEN 0 
			     WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebit - dblCredit
					ELSE dblCredit - dblDebit
			END)  beginBalance,
			SUM( 
			CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebitUnit - dblCreditUnit
					ELSE dblCreditUnit - dblDebitUnit
			END)  beginBalanceUnit
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
		CROSS APPLY (SELECT dtmDate from tblGLFiscalYear where dtmDateFrom = @dtmDate) D
	WHERE strAccountId = @strAccountId and C.dtmDate < @dtmDate and strCode <> ''
	GROUP BY strAccountId
)