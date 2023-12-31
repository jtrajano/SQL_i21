﻿CREATE FUNCTION [dbo].[fnGetEndBalanceUnit](@strAccountId nvarchar(50),@dtmDate datetime,@AA nvarchar(50) = '')
RETURNS decimal(18,6)
AS
BEGIN

	DECLARE @endBalanceUnit decimal(18,6)
	SELECT @endBalanceUnit = SUM( 
				CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebitUnit - dblCreditUnit
						ELSE dblCreditUnit - dblDebitUnit
				END)  
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
		LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
	WHERE strAccountId = @strAccountId and dtmDate <= @dtmDate
			and 1 = CASE WHEN strCode in ('CY', 'RE') and cast(floor(cast(dtmDate as float)) as datetime) = @dtmDate THEN 0 ELSE 1 END
			and strCode <> @AA
	GROUP BY strAccountId

	RETURN @endBalanceUnit
END