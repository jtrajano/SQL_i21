CREATE PROC uspRKClearingHouseStatementForRealized	
			@strName nvarchar(100) = null,
			@strAccountNumber nvarchar(100) = null,
			@dtmTransactionFromDate  datetime = null,
			@dtmTransactionToDate datetime = null
AS

SELECT strFutMarketName COLLATE Latin1_General_CI_AS
	,Left(replace(convert(varchar(9), dtmLTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmLTransDate, 8),9) dtmLTransDate
	,Left(replace(convert(varchar(9), dtmSTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmSTransDate, 8),9) dtmSTransDate
	,strFutureMonth COLLATE Latin1_General_CI_AS
	,convert(int,dblMatchQty) dblMatchQty
	,dblLPrice
	,dblSPrice
	,-dblGrossPL dblGrossPL
	,dblFutCommission
	,isnull(dblLPrice,0)-isnull(dblSPrice,0) dblPriceDiff
	,isnull(dblGrossPL,0)-isnull(abs(dblFutCommission),0) dblTotal
	,'Realized (Matched between ''' +Left(replace(convert(varchar(9), @dtmTransactionFromDate, 6), ' ', '-') + ' ' + convert(varchar(8), @dtmTransactionFromDate, 8),9) + ''' and ''' + Left(replace(convert(varchar(9), @dtmTransactionToDate, 6), ' ', '-') + ' ' + convert(varchar(8), @dtmTransactionToDate, 8),9)+''')' COLLATE Latin1_General_CI_AS as strDateHeading
FROM vyuRKRealizedPnL 
WHERE  strName=@strName AND strAccountNumber = @strAccountNumber AND 
convert(datetime,CONVERT(VARCHAR(10),dtmMatchDate,110),110) between convert(datetime,CONVERT(VARCHAR(10),@dtmTransactionFromDate,110),110) and  convert(datetime,CONVERT(VARCHAR(10),@dtmTransactionToDate,110),110)
ORDER BY dtmLTransDate
