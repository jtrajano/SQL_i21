CREATE PROC [dbo].[uspRKClearingHouseStatementForUnRealized]    
              @strName nvarchar(100) = null,
              @strAccountNumber nvarchar(100) = null,
              @dtmTransactionFromDate datetime = null,
              @dtmTransactionToDate datetime = null
AS
--Sanitize the parameters, set to null if empty string. We are catching it on where clause by isnull function

if  (@dtmTransactionFromDate is null)
set @dtmTransactionFromDate ='1900-01-01'

if(@dtmTransactionToDate is null)
set @dtmTransactionToDate =getdate()
IF @strName = ''
BEGIN
       SET @strName = NULL
END

IF @strAccountNumber = ''
BEGIN
       SET @strAccountNumber = NULL
END

declare @intSelectedInstrumentTypeId int =1

declare @Unrealized table(
RowNum int, 
strMonthOrder nvarchar(250),
intFutOptTransactionId int,
dblGrossPnL numeric(24,10),
dblLong  numeric(24,10),
dblShort  numeric(24,10),
dblFutCommission  numeric(24,10),
strFutMarketName  nvarchar(250),
strFutureMonth  nvarchar(250),
dtmTradeDate datetime,
strInternalTradeNo  nvarchar(250),
strName  nvarchar(250),
intEntityId int,
strAccountNumber  nvarchar(250)
,strBook  nvarchar(250),
strSubBook  nvarchar(250),
strSalespersonId  nvarchar(250),
strCommodityCode  nvarchar(250),
strLocationName  nvarchar(250),
dblLong1  numeric(24,10),
dblSell1  numeric(24,10),  
dblNet  numeric(24,10),
dblActual  numeric(24,10),
dblClosing  numeric(24,10),
dblPrice  numeric(24,10),
dblContractSize  numeric(24,10),
dblFutCommission1  numeric(24,10)
,dblMatchLong  numeric(24,10),
dblMatchShort  numeric(24,10),
dblNetPnL  numeric(24,10),
intFutureMarketId int,
intFutureMonthId int,
dblOriginalQty  numeric(24,10),
intFutOptTransactionHeaderId int,
intCommodityId int,
ysnExpired bit,
dblVariationMargin  numeric(24,10) ,
dblInitialMargin   numeric(24,10)
,LongWaitedPrice  numeric(24,10),
ShortWaitedPrice  numeric(24,10),
intSelectedInstrumentTypeId int)

INSERT INTO @Unrealized
exec uspRKUnrealizedPnL    @dtmFromDate =@dtmTransactionFromDate
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
                                         ,@intSelectedInstrumentTypeId=@intSelectedInstrumentTypeId

SELECT * FROM (
SELECT RANK() OVER(PARTITION BY strFutMarketName order by strFutMarketName,CONVERT(DATETIME,'01 '+strFutureMonth) Asc) AS intRowNumber ,*,
(dblClosingPrice-dblPrice)*dblNet*dblContractSize as dblNetPnL
FROM (
SELECT p.strFutMarketName,strInternalTradeNo,strFutureMonth,
LEFT(REPLACE(CONVERT(VARCHAR(9), dtmTradeDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmTradeDate, 8),9) dtmTradeDate,
dblLong,dblShort,isnull(dblLong,0) - isnull(dblShort,0) dblNet,dblPrice,
       dblClosing dblClosingPrice,dblGrossPnL,dblFutCommission,
       case when isnull(c.ysnSubCurrency,0) = 1 then p.dblContractSize/100 else p.dblContractSize end dblContractSize
FROM @Unrealized p
join tblRKFutureMarket fm on p.intFutureMarketId=fm.intFutureMarketId
join tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
WHERE  strName=isnull(@strName,strName) 
AND strAccountNumber = isnull(@strAccountNumber,strAccountNumber)
)t )t1 ORDER BY strFutMarketName,intRowNumber