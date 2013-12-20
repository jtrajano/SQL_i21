CREATE FUNCTION [dbo].[fn_getBeginBalance](@strAccountID nvarchar(50),@dtmDate datetime,@AA nvarchar(50) = '')
RETURNS decimal(18,6)
AS
BEGIN

	DECLARE @beginBalance decimal (18,6)
	SELECT @beginBalance = SUM( 
				CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END)  
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupID = B.intAccountGroupID
		LEFT JOIN tblGLSummary C ON A.intAccountID = C.intAccountID
	WHERE strAccountID = @strAccountID and dtmDate < @dtmDate and strCode <> @AA
	GROUP BY strAccountID

	RETURN @beginBalance
END
