CREATE PROC uspRKClearingHouseStatementForRealized
	@strName nvarchar(100) = null
	, @strAccountNumber nvarchar(100) = null
	, @dtmTransactionFromDate datetime = null
	, @dtmTransactionToDate datetime = null

AS

IF @strName = ''
BEGIN
	SET @strName = NULL
END

IF @strAccountNumber = ''
BEGIN
	SET @strAccountNumber = NULL
END

DECLARE @Realized TABLE (RowNum int
	, strMonthOrder nvarchar(250) COLLATE Latin1_General_CI_AS
	, dblNetPL numeric(24,10)
	, dblGrossPL numeric(24,10)
	, intMatchFuturesPSHeaderId int
	, intMatchFuturesPSDetailId int
	, intFutOptTransactionId int
	, intLFutOptTransactionId int
	, intSFutOptTransactionId int
	, dblMatchQty numeric(24,10)
	, dtmLTransDate datetime
	, dtmSTransDate datetime
	, dblLPrice numeric(24,10)
	, dblSPrice numeric(24,10)
	, strLBrokerTradeNo nvarchar(250) COLLATE Latin1_General_CI_AS
	, strSBrokerTradeNo nvarchar(250) COLLATE Latin1_General_CI_AS
	, dblContractSize numeric(24,10)
	, dblFutCommission numeric(24,10)
	, strFutMarketName nvarchar(250) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(250) COLLATE Latin1_General_CI_AS
	, intMatchNo int
	, dtmMatchDate datetime
	, strName nvarchar(250) COLLATE Latin1_General_CI_AS
	, strAccountNumber nvarchar(250) COLLATE Latin1_General_CI_AS
	, strCommodityCode nvarchar(250) COLLATE Latin1_General_CI_AS
	, strLocationName nvarchar(250) COLLATE Latin1_General_CI_AS
	, intFutureMarketId int
	, intCommodityId int
	, ysnExpired bit
	, intFutureMonthId int
	, strLInternalTradeNo nvarchar(250) COLLATE Latin1_General_CI_AS
	, strSInternalTradeNo nvarchar(250) COLLATE Latin1_General_CI_AS
	, strLRollingMonth nvarchar(250) COLLATE Latin1_General_CI_AS
	, strSRollingMonth nvarchar(250) COLLATE Latin1_General_CI_AS
	, intLFutOptTransactionHeaderId int
	, intSFutOptTransactionHeaderId int
	, strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	, strSubBook nvarchar(100) COLLATE Latin1_General_CI_AS)

INSERT INTO @Realized
EXEC uspRKRealizedPnL @dtmFromDate = @dtmTransactionFromDate
	, @dtmToDate = @dtmTransactionToDate
	, @intCommodityId = NULL
	, @ysnExpired = 'false'
	, @intFutureMarketId = NULL
	, @intEntityId = NULL
	, @intBrokerageAccountId = NULL
	, @intFutureMonthId = NULL
	, @strBuySell = NULL
	, @intBookId = NULL
	, @intSubBookId = NULL

SELECT fm.strFutMarketName
	, (Left(replace(convert(varchar(9), dtmLTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmLTransDate, 8),9)) COLLATE Latin1_General_CI_AS dtmLTransDate
	, (Left(replace(convert(varchar(9), dtmSTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmSTransDate, 8),9)) COLLATE Latin1_General_CI_AS dtmSTransDate
	, strFutureMonth
	, convert(int,dblMatchQty) dblMatchQty
	, dblLPrice
	, dblSPrice
	, -dblGrossPL dblGrossPL
	, dblFutCommission
	, isnull(dblLPrice,0) - isnull(dblSPrice,0) dblPriceDiff
	, isnull(dblGrossPL,0) - isnull(abs(dblFutCommission),0) dblTotal
	, strCurrency as strCurrency
FROM @Realized p
join tblRKFutureMarket fm on p.intFutureMarketId=fm.intFutureMarketId
join tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
WHERE strName = isnull(@strName, strName)
	AND strAccountNumber = isnull(@strAccountNumber, strAccountNumber)
ORDER BY dtmLTransDate