CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnitRE] 
(	
	-- Add the parameters for the function here
	@strAccountId NVARCHAR(100),
	@dtmDate NVARCHAR(20) = ''
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	
	WITH cte as(
	SELECT  
			 @strAccountId AS strAccountId,
			(dblCredit - dblDebit) as beginbalance,
			(dblCreditUnit - dblDebitUnit) as beginbalanceunit
		  
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
	WHERE B.strAccountType in ('Expense','Revenue') and C.dtmDate < (CASE WHEN @dtmDate= '' THEN '2100-01-01' ELSE @dtmDate END) and strCode <> ''
	)
	select sum(beginbalance) beginBalance ,sum(beginbalanceunit) beginBalanceUnit from cte group by strAccountId
)