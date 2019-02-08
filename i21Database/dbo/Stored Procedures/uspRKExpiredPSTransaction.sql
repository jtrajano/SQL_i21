CREATE PROCEDURE uspRKExpiredPSTransaction
	@intTypeId INT
	, @intEntityId INT
	, @intFutureMarketId INT
	, @intCommodityId INT
	, @intOptionMonthId INT
	, @dblStrike INT
	, @dtmPositionAsOf DATETIME

AS

SET @dtmPositionAsOf = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)

SELECT * FROM (
	SELECT m.intOptionsPnSExpiredId
		, CONVERT(INT, strTranNo) strTranNo
		, dtmExpiredDate
		, t.strInternalTradeNo
		, intLots
		, m.intFutOptTransactionId
		, (case when t.strBuySell='Buy' THEN -ISNULL(t.dblPrice,0)* m.intLots * fm.dblContractSize else ISNULL(t.dblPrice,0)* m.intLots * fm.dblContractSize end)/ case when ysnSubCurrency = 1 then intCent else 1 end as dblImpact
		, fm.strFutMarketName
		, om.strOptionMonth
		, t.dblStrike
		, t.strOptionType
		, t.dblPrice AS dblPremiumRate
		, (Case WHEN t.strBuySell='Buy' THEN -ISNULL(t.dblPrice*dblContractSize*intLots,0) else ISNULL(t.dblPrice*dblContractSize*intLots,0) end)/ case when ysnSubCurrency = 1 then intCent else 1 end AS dblPremiumTotal
		, e.strName
		, b.strAccountNumber
		, strCommodityCode
		, scl.strLocationName
		, cb.strBook
		, csb.strSubBook,t.intFutOptTransactionHeaderId
		, intTypeId= (case when t.strOptionType='Put' then 1 else 2 end)
		, t.intEntityId
		, t.intFutureMarketId
		, t.intCommodityId
		, t.intOptionMonthId
	FROM tblRKOptionsPnSExpired m
	Join tblRKFutOptTransaction t on t.intFutOptTransactionId= m.intFutOptTransactionId
	Join tblRKFutureMarket fm on fm.intFutureMarketId = t.intFutureMarketId
	JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId  
	JOIN tblRKOptionsMonth om on om.intOptionMonthId=t.intOptionMonthId
	Join tblEMEntity e on e.intEntityId=t.intEntityId
	Join tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
	join tblICCommodity ic on ic.intCommodityId=t.intCommodityId
	JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=t.intLocationId
	LEFT JOIN tblCTBook cb on cb.intBookId= t.intBookId
	LEFT JOIN tblCTSubBook csb on csb.intSubBookId=t.intSubBookId
) t
WHERE ISNULL(intTypeId,0) = ISNULL(@intTypeId, ISNULL(intTypeId,0))
AND ISNULL(intEntityId,0) = ISNULL(@intEntityId, ISNULL(intEntityId,0))
AND ISNULL(intFutureMarketId,0) = ISNULL(@intFutureMarketId, ISNULL(intFutureMarketId,0))
AND ISNULL(intCommodityId,0) = ISNULL(@intCommodityId, ISNULL(intCommodityId,0))
AND ISNULL(intOptionMonthId,0) = ISNULL(@intOptionMonthId, ISNULL(intOptionMonthId,0))
AND ISNULL(dblStrike,0) = ISNULL(@dblStrike, ISNULL(dblStrike,0))
AND dtmExpiredDate <= @dtmPositionAsOf