CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnitRETB]
(
	@strAccountId NVARCHAR(100),
	@dtmDate DATETIME,
	@multiFiscal BIT,
	@intGLDetailId INT = -1
)
RETURNS @tbl TABLE (
strAccountId NVARCHAR(100),
beginBalance NUMERIC (18,6),
beginBalanceUnit NUMERIC(18,6)
)

AS
BEGIN
	BEGIN
		IF @intGLDetailId = -1
		BEGIN
			;WITH cte as(
			SELECT
					 @strAccountId AS strAccountId,
					 (dblDebit - dblCredit)
					as beginbalance,
					(dblDebitUnit - dblCreditUnit) as beginbalanceunit

			FROM tblGLAccount A
				LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
				LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
				cross apply (select top 1 dtmDateFrom from tblGLFiscalYear where @dtmDate between dtmDateFrom and dtmDateTo) fiscal
			WHERE
			(B.strAccountType in ('Expense','Revenue')
			and C.dtmDate <
			CASE WHEN @multiFiscal = 1
			THEN
				@dtmDate
			else
				fiscal.dtmDateFrom
			end

			 and ysnIsUnposted = 0 and isnull(strCode,'') <> '' )
			OR (
				strAccountId =@strAccountId AND
				C.dtmDate <  @dtmDate
				and ysnIsUnposted = 0
				and isnull(strCode,'') <> '' )

			)


			insert into @tbl
			select strAccountId, sum(beginbalance) beginBalance ,sum(beginbalanceunit) beginBalanceUnit from cte group by strAccountId
		END
		ELSE
		BEGIN
			;WITH cte as(
			SELECT
					 @strAccountId AS strAccountId,
					 (dblDebit - dblCredit)
					as beginbalance,
					(dblDebitUnit - dblCreditUnit) as beginbalanceunit

			FROM tblGLAccount A
				LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId
				LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId
				cross apply (select top 1 dtmDateFrom from tblGLFiscalYear where @dtmDate between dtmDateFrom and dtmDateTo) fiscal
			WHERE
			(B.strAccountType in ('Expense','Revenue')  and C.dtmDate < fiscal.dtmDateFrom and ysnIsUnposted = 0 and isnull(strCode,'') <> '' )
			OR (
				strAccountId =@strAccountId AND
				C.dtmDate <
					case when @multiFiscal = 1
				then
					@dtmDate
				else
					fiscal.dtmDateFrom
				end
				and ysnIsUnposted = 0
				and isnull(strCode,'') <> '' )

			AND C.intGLDetailId < @intGLDetailId
			)
			insert into @tbl
			select strAccountId, sum(beginbalance) beginBalance ,sum(beginbalanceunit) beginBalanceUnit from cte group by strAccountId
		END
	END
	RETURN

END