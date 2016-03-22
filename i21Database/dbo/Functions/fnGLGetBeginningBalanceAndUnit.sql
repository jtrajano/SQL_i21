﻿CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnit] 
(	
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
	IF EXISTS(SELECT TOP 1 1 FROM tblGLAccount A JOIN tblGLFiscalYear B ON A.intAccountId = B.intRetainAccount WHERE A.strAccountId = @strAccountId)
	BEGIN
		DECLARE @dte DATETIME
		SELECT TOP 1 @dte= dtmDateFrom from tblGLFiscalYear WHERE @dtmDate >= dtmDateFrom  and @dtmDate <= dtmDateTo ORDER BY dtmDateFrom DESC

		;WITH cte as(
		SELECT  
				 @strAccountId AS strAccountId,
				(dblCredit - dblDebit) as beginbalance,
				(dblCreditUnit - dblDebitUnit) as beginbalanceunit
		  
		FROM tblGLAccount A
			LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
			LEFT JOIN tblGLSummary C ON A.intAccountId = C.intAccountId
		WHERE
		(B.strAccountType in ('Expense','Revenue')  and C.dtmDate < ISNULL(@dte,@dtmDate) )
		OR (strAccountId =@strAccountId AND C.dtmDate < @dtmDate) and strCode <> '')
		insert into @tbl
		select strAccountId, sum(beginbalance) beginBalance ,sum(beginbalanceunit) beginBalanceUnit from cte group by strAccountId
		
		RETURN 
	END

	DECLARE @accountType NVARCHAR(30)
	SELECT @accountType= B.strAccountType  FROM tblGLAccount A JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId WHERE
	A.strAccountId = @strAccountId and B.strAccountType IN ('Expense','Revenue','Cost of Goods Sold')
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