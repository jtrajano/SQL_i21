CREATE FUNCTION [dbo].[fnGLGetBalancesDateCriteria]
(
@dtmDate DATETIME,
@strAccountId NVARCHAR(30),
@strBalanceType NVARCHAR(30)
)
RETURNS @tbl TABLE 
(
dtmDateFrom DATETIME,
dtmDateTo DATETIME
)

AS 

BEGIN

DECLARE @dtmDate1 DATETIME
DECLARE @dtmDate2 DATETIME
DECLARE @strAccountType NVARCHAR(50)
DECLARE @reAccount BIT = 0
SELECT @strAccountType=G.strAccountType from tblGLAccount A JOIN tblGLAccountGroup G ON A.intAccountGroupId = G.intAccountGroupId WHERE strAccountId = @strAccountId 
SELECT @reAccount = 1  from tblGLFiscalYear F JOIN tblGLAccount A ON F.intRetainAccount = A.intAccountId WHERE A.strAccountId = @strAccountId

	;WITH Cte AS(

	
	SELECT 
			TOP 1
			CASE WHEN @strBalanceType= 'YTD' OR @strBalanceType= 'OPENING' THEN 
					CASE WHEN @reAccount = 1 OR @strAccountType IN ('Expense','Revenue','Cost of Goods Sold')
						 THEN FiscalYear.dtmDateFrom
						 ELSE CAST('1900/01/01' AS datetime)--ALE
					 	 
					END
				WHEN @strBalanceType ='MTD' THEN FiscalPeriod.dtmStartDate
			END
			dtmDate1,
			CASE WHEN @strBalanceType= 'YTD' THEN 
					CASE  WHEN @reAccount = 1 THEN @dtmDate
					 	 ELSE FiscalPeriod.dtmEndDate
					END
				WHEN @strBalanceType ='MTD' THEN FiscalPeriod.dtmStartDate
				WHEN @strBalanceType= 'OPENING' THEN @dtmDate
			END
			dtmDate2
		FROM

		tblGLFiscalYear FiscalYear,
		tblGLFiscalYearPeriod FiscalPeriod
		WHERE @dtmDate BETWEEN FiscalYear.dtmDateFrom AND FiscalYear.dtmDateTo
		AND @dtmDate BETWEEN FiscalPeriod.dtmStartDate AND FiscalPeriod.dtmEndDate

	)
	INSERT INTO @tbl(dtmDateFrom,dtmDateTo)
	SELECT dtmDate1,dtmDate2 from Cte
RETURN
END
