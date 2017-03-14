CREATE FUNCTION [dbo].[fnGLGetMTDActivity] 
(	
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @accountType NVARCHAR(30)
	DECLARE @activity DECIMAL(18,6)
	SELECT @accountType= B.strAccountType  FROM tblGLAccount A JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId WHERE
	A.strAccountId = @strAccountId and B.strAccountType IN ('Expense','Revenue','Cost of Goods Sold')
	
	SELECT  
			@activity =
			SUM ( CASE 
					WHEN @accountType = 'Revenue' THEN (dblCredit - dblDebit)*-1
					ELSE dblDebit - dblCredit
			END)  
					
	FROM tblGLAccount A
		LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
		CROSS APPLY (SELECT dtmStartDate,dtmEndDate from tblGLFiscalYearPeriod where @dtmDate between dtmStartDate AND  dtmEndDate) D
	WHERE strAccountId = @strAccountId and ( C.dtmDate BETWEEN D.dtmStartDate and  D.dtmEndDate) and strCode <> ''  and ysnIsUnposted = 0
	GROUP BY strAccountId

	IF @activity IS NULL SET @activity = 0
	RETURN @activity
END