CREATE PROC uspRKClearingHouseStatementForUnRealized
	@strName nvarchar(100) = null
	, @strAccountNumber nvarchar(100) = null
	, @dtmTransactionFromDate datetime = null
	, @dtmTransactionToDate datetime = null

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

DECLARE @Unrealized TABLE (RowNum INT
	, strMonthOrder nvarchar(250) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionId int
	, dblGrossPnL numeric(24,10)
	, dblLong numeric(24,10)
	, dblShort numeric(24,10)
	, dblFutCommission numeric(24,10)
	, strFutMarketName nvarchar(250) COLLATE Latin1_General_CI_AS
	, strFutureMonth nvarchar(250) COLLATE Latin1_General_CI_AS
	, dtmTradeDate datetime
	, strInternalTradeNo nvarchar(250) COLLATE Latin1_General_CI_AS
	, strName nvarchar(250) COLLATE Latin1_General_CI_AS
	, strAccountNumber nvarchar(250) COLLATE Latin1_General_CI_AS
	, strBook nvarchar(250) COLLATE Latin1_General_CI_AS
	, strSubBook nvarchar(250) COLLATE Latin1_General_CI_AS
	, strSalespersonId nvarchar(250) COLLATE Latin1_General_CI_AS
	, strCommodityCode nvarchar(250) COLLATE Latin1_General_CI_AS
	, strLocationName nvarchar(250) COLLATE Latin1_General_CI_AS
	, dblLong1 numeric(24,10)
	, dblSell1 numeric(24,10)
	, dblNet numeric(24,10)
	, dblActual numeric(24,10)
	, dblClosing numeric(24,10)
	, dblPrice numeric(24,10)
	, dblContractSize numeric(24,10)
	, dblFutCommission1 numeric(24,10)
	, dblMatchLong numeric(24,10)
	, dblMatchShort numeric(24,10)
	, dblNetPnL numeric(24,10)
	, intFutureMarketId int
	, intFutureMonthId int
	, dblOriginalQty numeric(24,10)
	, intFutOptTransactionHeaderId int
	, intCommodityId int
	, ysnExpired bit
	, dblVariationMargin numeric(24,10)
	, dblInitialMargin numeric(24,10)
	, LongWaitedPrice numeric(24,10)
	, ShortWaitedPrice numeric(24,10))

INSERT INTO @Unrealized
EXEC uspRKUnrealizedPnL @dtmFromDate = @dtmTransactionFromDate
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

SELECT * FROM (
	SELECT RANK() OVER(PARTITION BY strFutMarketName order by strFutMarketName, CONVERT(DATETIME,'01 '+strFutureMonth) Asc) AS intRowNumber 
		, *
		, (dblGrossPnL*(dblClosingPrice-dblPrice))-dblFutCommission as dblNetPnL
	FROM (
		SELECT strFutMarketName
			, strInternalTradeNo
			, strFutureMonth
			, (LEFT(REPLACE(CONVERT(VARCHAR(9), dtmTradeDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmTradeDate, 8),9)) COLLATE Latin1_General_CI_AS dtmTradeDate
			, dblLong
			, dblShort
			, isnull(dblLong,0) - isnull(dblShort,0) dblNet
			, dblPrice
			, IsNull(dbo.fnRKGetLatestClosingPrice (intFutureMarketId,intFutureMonthId ,dtmTradeDate), 0.0) dblClosingPrice
			, dblGrossPnL
			, dblFutCommission
		FROM @Unrealized
		WHERE strName = isnull(@strName, strName)
			AND strAccountNumber = isnull(@strAccountNumber, strAccountNumber)
	)t
)t1 ORDER BY strFutMarketName, intRowNumber