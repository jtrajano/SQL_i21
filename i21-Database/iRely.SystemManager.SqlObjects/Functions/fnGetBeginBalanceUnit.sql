CREATE FUNCTION [dbo].[fnGetBeginBalanceUnit](@strAccountId nvarchar(50),@dtmDate datetime,@AA nvarchar(50) = '')
RETURNS decimal(18,6)
AS
BEGIN

	DECLARE @beginBalanceUnit decimal(18,6)
	SELECT @beginBalanceUnit = SUM( 
				CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebitUnit - dblCreditUnit
						ELSE dblCreditUnit - dblDebitUnit
				END)  
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
	WHERE strAccountId = @strAccountId and dtmDate < @dtmDate and strCode <> @AA
	GROUP BY strAccountId

	RETURN @beginBalanceUnit
END