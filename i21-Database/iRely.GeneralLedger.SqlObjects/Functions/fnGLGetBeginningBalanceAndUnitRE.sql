CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnitRE]
(	
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME,
	@dtmDate1 DATETIME = NULL,
	@multiFiscal BIT = 0
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
		;WITH cte as(
		SELECT  
				 @strAccountId AS strAccountId,
				 CASE WHEN B.strAccountType IN ('Asset', 'Expense','Cost of Goods Sold') 
				THEN (dblDebit - dblCredit) 
				ELSE (dblCredit - dblDebit) *-1 END
				as beginbalance,
				(dblCreditUnit - dblDebitUnit) as beginbalanceunit
		  
		FROM tblGLAccount A
			LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
			LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
		WHERE
		(B.strAccountType in ('Expense','Revenue')  and C.dtmDate < CASE WHEN @multiFiscal= 1 THEN @dtmDate ELSE @dtmDate1 end
		OR (strAccountId =@strAccountId 
		--AND C.dtmDate >=  @dtmDate1 
		AND C.dtmDate < @dtmDate) and isnull(strCode,'') <> '' 
		AND ysnIsUnposted = 0))  
		insert into @tbl
		select strAccountId, sum(beginbalance) beginBalance ,sum(beginbalanceunit) beginBalanceUnit from cte group by strAccountId
		
		
	END
	RETURN
	
END