CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAuditorReport] 
(	
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME,
	@intCurrencyId INT
)
RETURNS @tbl TABLE (
strAccountId NVARCHAR(100),
beginBalance NUMERIC (18,6),
beginBalanceUnit NUMERIC(18,6),
beginBalanceDebit NUMERIC (18,6),
beginBalanceCredit NUMERIC (18,6)
)

AS
BEGIN
	DECLARE @accountType NVARCHAR(30)
	SELECT @accountType= B.strAccountType  FROM tblGLAccount A JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId WHERE
	A.strAccountId = @strAccountId and B.strAccountType IN ('Expense','Revenue','Cost of Goods Sold')
	IF @accountType IS NOT NULL
			INSERT  @tbl
			SELECT  
					strAccountId,
					SUM ( CASE 
						  WHEN D.dtmDateFrom IS NULL THEN 0 
						  WHEN @accountType = 'Revenue' THEN (dblCredit - dblDebit)*-1
						  ELSE dblDebit - dblCredit
					END)  beginBalance,
					SUM( 
					CASE 
						WHEN D.dtmDateFrom IS NULL THEN 0 
						WHEN @accountType = 'Revenue' THEN dblCreditUnit - dblDebitUnit
							ELSE dblDebitUnit - dblCreditUnit
					END)  beginBalanceUnit,
                    SUM(dblDebit) beginBalanceDebit,
                    SUM(dblCredit) beginBalanceCredit	
			FROM tblGLAccount A
				LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
				LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
				CROSS APPLY (
					SELECT dtmDateFrom,dtmDateTo from tblGLFiscalYear WHERE @dtmDate >= dtmDateFrom 
					AND @dtmDate <= dtmDateTo
				) D
			WHERE strAccountId = @strAccountId AND ( C.dtmDate >= D.dtmDateFrom 
			AND  C.dtmDate < @dtmDate) AND strCode <> ''  
			AND ysnIsUnposted = 0
			AND @intCurrencyId = C.intCurrencyId
			GROUP BY strAccountId
	ELSE
		INSERT  @tbl
		SELECT  
				strAccountId,
				SUM( 
				CASE WHEN B.strAccountType = 'Asset' THEN dblDebit - dblCredit
						ELSE (dblCredit - dblDebit)*-1
				END)  beginBalance,
				SUM( 
				CASE WHEN B.strAccountType = 'Asset' THEN dblDebitUnit - dblCreditUnit
						ELSE dblCreditUnit - dblDebitUnit
				END)  beginBalanceUnit,
                SUM(dblDebit) beginBalanceDebit,
                SUM(dblCredit) beginBalanceCredit
		FROM tblGLAccount A
			LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
			LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
		WHERE strAccountId = @strAccountId AND C.dtmDate < @dtmDate 
		AND strCode <> '' AND ysnIsUnposted = 0 
		AND @intCurrencyId = C.intCurrencyId
		GROUP BY strAccountId
    RETURN
END