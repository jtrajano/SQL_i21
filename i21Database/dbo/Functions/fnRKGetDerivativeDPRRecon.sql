CREATE FUNCTION dbo.fnRKGetDerivativeDPRRecon(
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME
	, @intCommodityId INT = NULL
)
RETURNS @Records TABLE (
	intRowId INT IDENTITY
	, strBucket NVARCHAR(100)
	, strCommodityCode NVARCHAR(50)
	, strInternalTradeNo NVARCHAR(100)
	, dblTotal NUMERIC(18, 6)
	, intCommodityId INT
	, intFutOptTransactionId INT
	, intFutOptTransactionHeaderId INT
	, dtmCreateDateTime DATETIME

)

AS

BEGIN

DECLARE @strCommodityCode NVARCHAR(100)

SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId

INSERT INTO @Records(
	 strBucket
	,strCommodityCode
	,strInternalTradeNo
	,dblTotal 
	,intCommodityId
	,intFutOptTransactionId
	,intFutOptTransactionHeaderId
	,dtmCreateDateTime
)
SELECT 
	strBucketName  = 'Futures'
	,strCommodityCode  = @strCommodityCode
	,D.strInternalTradeNo
	,dblTotal = (D.dblNoOfContract * FM.dblContractSize) * (CASE WHEN D.strBuySell = 'Sell' THEN -1 ELSE 1 END)
	,intCommodityId = @intCommodityId
	,D.intFutOptTransactionId
	,D.intFutOptTransactionHeaderId
	,D.dtmCreateDateTime
FROM tblRKFutOptTransaction D
INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = D.intFutureMarketId
WHERE D.dtmCreateDateTime between @dtmFromDate and @dtmToDate
	AND D.intCommodityId = @intCommodityId
	AND isnull(D.ysnPreCrush,0) = 0
	AND D.intInstrumentTypeId = 1 --'Futures'


UNION ALL
SELECT 
	strBucketName  = 'Crush'
	,strCommodityCode  = @strCommodityCode
	,D.strInternalTradeNo
	,dblTotal = (D.dblNoOfContract * FM.dblContractSize) * (CASE WHEN D.strBuySell = 'Sell' THEN -1 ELSE 1 END)
	,intCommodityId = @intCommodityId
	,D.intFutOptTransactionId
	,D.intFutOptTransactionHeaderId
	,D.dtmCreateDateTime
FROM tblRKFutOptTransaction D
INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = D.intFutureMarketId
WHERE D.dtmCreateDateTime between @dtmFromDate and @dtmToDate
	AND D.intCommodityId = @intCommodityId
	AND isnull(D.ysnPreCrush,0) = 1
	AND D.intInstrumentTypeId = 1 --'Futures'

RETURN

END