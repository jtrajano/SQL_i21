CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnit] 
(	
	-- Add the parameters for the function here
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME
)
RETURNS @tbl TABLE (
strAccountId NVARCHAR(100),
beginBalance NUMERIC (18,6),
beginBalanceUnit NUMERIC(18,6)
)

AS
BEGIN
	-- *BOY = BEGINNING OF FISCAL YEAR
	-- *BOT = BEGINNING OF TIME
	--  NOTE : EXPENSE AND REVENUE BEGINNING BALANCE IS COMPUTED VIA *BOY WHILE OTHER ARE COMPUTE VIA *BOT
	--  COGS transferred to Expense / Sales to Revenue 02-29-2016 (See 1_AccountType.sql - Post Deployment script)
	DECLARE @accountType NVARCHAR(30)
	SELECT @accountType= B.strAccountType  FROM tblGLAccount A JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId WHERE
	A.strAccountId = @strAccountId and B.strAccountType IN ('Expense','Revenue')
	IF @accountType IS NOT NULL
			INSERT  @tbl
			SELECT  
					strAccountId,
					SUM ( CASE 
						  WHEN D.dtmDateFrom IS NULL THEN 0 
						  WHEN @accountType = 'Revenue' THEN dblCredit - dblDebit
						  ELSE dblDebit - dblCredit
					END)  beginBalance,
					SUM( 
					CASE 
						WHEN D.dtmDateFrom IS NULL THEN 0 
						WHEN @accountType = 'Revenue' THEN dblCreditUnit - dblDebitUnit
							ELSE dblDebitUnit - dblCreditUnit
					END)  beginBalanceUnit
			FROM tblGLAccount A
				LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
				LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
				CROSS APPLY (SELECT dtmDateFrom,dtmDateTo from tblGLFiscalYear where @dtmDate >= dtmDateFrom AND @dtmDate <= dtmDateTo) D
			WHERE strAccountId = @strAccountId and ( C.dtmDate >= D.dtmDateFrom and  C.dtmDate < @dtmDate) and strCode <> ''
			GROUP BY strAccountId
	ELSE
		INSERT  @tbl
		SELECT  
				strAccountId,
				SUM( 
				CASE WHEN B.strAccountType = 'Asset' THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END)  beginBalance,
				SUM( 
				CASE WHEN B.strAccountType = 'Asset' THEN dblDebitUnit - dblCreditUnit
						ELSE dblCreditUnit - dblDebitUnit
				END)  beginBalanceUnit
		
		FROM tblGLAccount A
			LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
			LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
		WHERE strAccountId = @strAccountId and C.dtmDate < @dtmDate and strCode <> ''
		GROUP BY strAccountId
		RETURN
END
	
	