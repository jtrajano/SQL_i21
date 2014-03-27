CREATE FUNCTION [dbo].[fnGetBeginBalance](@strAccountId nvarchar(50),@dtmDate datetime,@AA nvarchar(50) = '')
RETURNS decimal(18,6)
AS
BEGIN

	DECLARE @beginBalance decimal (18,6)
	SELECT @beginBalance = SUM( 
				CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END)  
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
	WHERE strAccountId = @strAccountId and dtmDate < @dtmDate and strCode <> @AA
	GROUP BY strAccountId

	RETURN @beginBalance
END