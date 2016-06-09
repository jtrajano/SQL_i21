CREATE FUNCTION [dbo].[fnGLComputeBalance]
(	
	@intAccountId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
	@strAccountType NVARCHAR(30),
	@strBalanceOrUnit NVARCHAR(10),
	@retainFiscalYear DATETIME,
	@retainedEarnings INT = 0
	
)
RETURNS TABLE
AS
RETURN

(	
	SELECT 
		CASE WHEN @strBalanceOrUnit = 'Debit' THEN SUM(dblDebit)
			 WHEN @strBalanceOrUnit = 'Credit' THEN SUM(dblCredit)
			 WHEN @strBalanceOrUnit = 'DebitUnit' THEN SUM(dblDebitUnit)
			 WHEN @strBalanceOrUnit = 'CreditUnit' THEN SUM(dblCreditUnit)
			 
		ELSE

			CASE WHEN @strAccountType in ('Asset','Expense')  THEN 
				CASE WHEN @strBalanceOrUnit = 'Balance' THEN sum(dblDebit) - sum(dblCredit)  
					ELSE sum(dblDebitUnit) - sum(dblCreditUnit)  --@strBalanceOrUnit = Unit
				END
				ELSE 
				CASE WHEN  @strBalanceOrUnit = 'Balance' THEN (sum(dblCredit) - sum(dblDebit)) *-1 
					ELSE (sum(dblCreditUnit) - sum(dblDebitUnit)) --@strBalanceOrUnit = Unit
				END
			END
		END
	balance
	FROM tblGLDetail detail  
	JOIN tblGLAccount account on detail.intAccountId = account.intAccountId
	join tblGLAccountGroup grp ON account.intAccountGroupId = grp.intAccountGroupId
	WHERE (detail.ysnIsUnposted= 0	AND detail.intAccountId = @intAccountId	AND dtmDate BETWEEN ISNULL( @retainFiscalYear,@dtmDateFrom)  AND @dtmDateTo)
	OR (detail.ysnIsUnposted= 0	AND dtmDate < ISNULL( @retainFiscalYear,@dtmDateFrom) AND grp.strAccountType IN ('Expense','Revenue') AND @retainedEarnings > 0)
)