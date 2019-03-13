CREATE PROC uspRKClearingHouseStatementForRealized	
			@strName nvarchar(100) = null,
			@strAccountNumber nvarchar(100) = null,
		    @dtmTransactionFromDate datetime = null,
		    @dtmTransactionToDate datetime = null
AS

IF @strName = ''
BEGIN
	SET @strName = NULL
END

IF @strAccountNumber = ''
BEGIN
	SET @strAccountNumber = NULL
END
declare @Realized table(
RowNum int, 
strMonthOrder nvarchar(250),
 dblNetPL numeric(24,10),
 dblGrossPL numeric(24,10),
intMatchFuturesPSHeaderId int,
intMatchFuturesPSDetailId int,
intFutOptTransactionId int,
intLFutOptTransactionId int,
intSFutOptTransactionId int,
dblMatchQty numeric(24,10),
dtmLTransDate datetime,
dtmSTransDate datetime,
dblLPrice numeric(24,10),
dblSPrice numeric(24,10),
strLBrokerTradeNo  nvarchar(250),
strSBrokerTradeNo  nvarchar(250),
dblContractSize numeric(24,10),
dblFutCommission numeric(24,10),
strFutMarketName  nvarchar(250),
strFutureMonth  nvarchar(250),
intMatchNo int,
dtmMatchDate datetime ,
strName  nvarchar(250),
strAccountNumber  nvarchar(250),
strCommodityCode  nvarchar(250),
strLocationName  nvarchar(250),
intFutureMarketId int,
intCommodityId int,
ysnExpired bit,intFutureMonthId int,strLInternalTradeNo  nvarchar(250),strSInternalTradeNo  nvarchar(250),strLRollingMonth  nvarchar(250),
strSRollingMonth  nvarchar(250),intLFutOptTransactionHeaderId int,intSFutOptTransactionHeaderId int,
	strBook nvarchar(100),
	strSubBook nvarchar(100),
	intSelectedInstrumentTypeId int
)

INSERT INTO @Realized
exec uspRKRealizedPnL 	 @dtmFromDate =@dtmTransactionFromDate
	,@dtmToDate = @dtmTransactionToDate
	,@intCommodityId=NULL
	,@ysnExpired=0
	,@intFutureMarketId  = NULL
	,@intEntityId  = NULL
	,@intBrokerageAccountId  = NULL
	,@intFutureMonthId  = NULL
	,@strBuySell =NULL
	,@intBookId =NULL
	,@intSubBookId =NULL

SELECT fm.strFutMarketName,Left(replace(convert(varchar(9), dtmLTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmLTransDate, 8),9) dtmLTransDate,
	   Left(replace(convert(varchar(9), dtmSTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmSTransDate, 8),9) dtmSTransDate,
	   strFutureMonth,convert(int,dblMatchQty) dblMatchQty,dblLPrice,dblSPrice,-dblGrossPL dblGrossPL,dblFutCommission,
	   isnull(dblLPrice,0)-isnull(dblSPrice,0) dblPriceDiff,isnull(dblGrossPL,0)-isnull(abs(dblFutCommission),0) dblTotal
	   ,case when isnull(c.ysnSubCurrency,0) = 1 then (select  strCurrency from tblSMCurrency where intCurrencyId=c.intMainCurrencyId) else strCurrency end as strCurrency	  
FROM @Realized p
join tblRKFutureMarket fm on p.intFutureMarketId=fm.intFutureMarketId
join tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
WHERE  strName=isnull(@strName,strName) 
AND strAccountNumber = isnull(@strAccountNumber,strAccountNumber)
ORDER BY dtmLTransDate