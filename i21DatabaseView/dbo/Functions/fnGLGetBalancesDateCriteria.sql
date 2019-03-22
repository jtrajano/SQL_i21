CREATE FUNCTION [dbo].[fnGLGetBalancesDateCriteria]
(
@dtmDate DATETIME,
@strAccountType NVARCHAR(30),
@strBalanceType NVARCHAR(30),
@retainedEarnings INT = 0
)
RETURNS @tbl TABLE 
(
dtmDateFrom DATETIME,
dtmDateTo DATETIME
)

AS 

BEGIN
		
		IF(@strBalanceType = 'MTD')
				INSERT INTO @tbl(dtmDateFrom,dtmDateTo)
				SELECT  Period.dtmStartDate, Period.dtmEndDate
				FROM tblGLFiscalYearPeriod Period WHERE @dtmDate  BETWEEN Period.dtmStartDate AND Period.dtmEndDate 
		ELSE IF
		(@strBalanceType = 'YTD')
				INSERT INTO @tbl(dtmDateFrom,dtmDateTo)
				SELECT 
				CASE WHEN @strAccountType in('Expense','Revenue') OR @retainedEarnings > 0
					THEN Fiscal.dtmDateFrom
					ELSE '1900/01/01'
				END,
				CASE WHEN @retainedEarnings > 0
					THEN @dtmDate
				ELSE
					Period.dtmEndDate
				END
				FROM tblGLFiscalYear Fiscal ,
				tblGLFiscalYearPeriod Period
				WHERE @dtmDate  BETWEEN Fiscal.dtmDateFrom AND Fiscal.dtmDateTo AND @dtmDate BETWEEN Period.dtmStartDate AND Period.dtmEndDate
		ELSE IF
			(@strBalanceType = 'Opening')
			INSERT INTO @tbl(dtmDateFrom,dtmDateTo)
				SELECT 
					CASE WHEN @retainedEarnings > 0
						ThEN (SELECT dtmDateFrom FROM tblGLFiscalYear WHERE @dtmDate BETWEEN dtmDateFrom AND dtmDateTo)
				 ELSE
				 '1900/01/01' END,
				@dtmDate
				


RETURN
END