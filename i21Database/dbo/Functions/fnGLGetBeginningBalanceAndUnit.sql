﻿CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnit] 
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
			CASE WHEN D.dtmDateFrom IS NOT NULL AND B.strAccountType IN ('Revenue','Expense') THEN 0 
			     WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebit - dblCredit
				 ELSE dblCredit - dblDebit
			END)   beginBalance,
			SUM( 
			CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebitUnit - dblCreditUnit
					ELSE dblCreditUnit - dblDebitUnit
			END)  beginBalanceUnit
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
		LEFT JOIN tblGLFiscalYear D ON C.dtmDate = D.dtmDateFrom
	WHERE strAccountId = @strAccountId and dtmDate < @dtmDate and strCode <> ''
	GROUP BY strAccountId
)
