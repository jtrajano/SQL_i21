CREATE PROC uspRKClearingHouseStatementForUnRealized	
			@strName nvarchar(100) = null,
			@strAccountNumber nvarchar(100) = null,
			@dtmTransactionFromDate  datetime = null,
			@dtmTransactionToDate datetime = null
AS

--Sanitize the parameters, set to null if empty string. We are catching it on where clause by isnull function
IF @strName = ''
BEGIN
	SET @strName = NULL
END

IF @strAccountNumber = ''
BEGIN
	SET @strAccountNumber = NULL
END

IF @dtmTransactionFromDate = ''
BEGIN
	SET @dtmTransactionFromDate = NULL
END

IF @dtmTransactionToDate = ''
BEGIN
	SET @dtmTransactionToDate = NULL
END


SELECT * FROM (
SELECT RANK() OVER(PARTITION BY strFutMarketName order by strFutMarketName,CONVERT(DATETIME,'01 '+strFutureMonth) Asc) AS intRowNumber ,*,(GrossPnL*(dblClosingPrice-dblPrice))-dblFutCommission as dblNetPnL,
 'Open futures lots between ''' +LEFT(REPLACE(CONVERT(VARCHAR(9), @dtmTransactionFromDate, 6), ' ', '-') + ' ' + convert(varchar(8), @dtmTransactionFromDate, 8),9) + ''' and ''' + Left(replace(convert(varchar(9), @dtmTransactionToDate, 6), ' ', '-') + ' ' + convert(varchar(8), @dtmTransactionToDate, 8),9)+'''' as strDateHeading
FROM (
SELECT strFutMarketName,strInternalTradeNo,strFutureMonth,
LEFT(REPLACE(CONVERT(VARCHAR(9), dtmTradeDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmTradeDate, 8),9) dtmTradeDate,
dblLong,dblShort,isnull(dblLong,0) - isnull(dblShort,0) dblNet,dblPrice,
	IsNull(dbo.fnRKGetLatestClosingPrice (intFutureMarketId,intFutureMonthId ,dtmTradeDate), 0.0) dblClosingPrice,GrossPnL,dblFutCommission
FROM vyuRKUnrealizedPnL 
WHERE  strName=isnull(@strName,strName) 
AND strAccountNumber = isnull(@strAccountNumber,strAccountNumber)
AND convert(datetime,CONVERT(VARCHAR(10),dtmTradeDate,110),110) between convert(datetime,CONVERT(VARCHAR(10),isnull(@dtmTransactionFromDate,dtmTradeDate),110),110) and  convert(datetime,CONVERT(VARCHAR(10),isnull(@dtmTransactionToDate,dtmTradeDate),110),110)
)t )t1 ORDER BY strFutMarketName,intRowNumber
