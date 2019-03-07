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
		, dblLots
		, m.intFutOptTransactionId
		, (case when t.strBuySell='Buy' THEN -ISNULL(t.dblPrice,0)* m.dblLots * fm.dblContractSize else ISNULL(t.dblPrice,0)* m.dblLots * fm.dblContractSize end)/ case when ysnSubCurrency = 1 then intCent else 1 end as dblImpact
		, fm.strFutMarketName
		, om.strOptionMonth
		, t.dblStrike
		, t.strOptionType
		, t.dblPrice AS dblPremiumRate
		, (Case WHEN t.strBuySell='Buy' THEN -ISNULL(t.dblPrice*dblContractSize*dblLots,0) else ISNULL(t.dblPrice*dblContractSize*dblLots,0) end)/ case when ysnSubCurrency = 1 then intCent else 1 end AS dblPremiumTotal
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
WHERE ISNULL(intTypeId,0) = case when ISNULL(@intTypeId,0)=0 then ISNULL(intTypeId,0) else @intTypeId end
AND ISNULL(intEntityId,0) = case when ISNULL(@intEntityId,0)=0 then ISNULL(intEntityId,0) else @intEntityId end 
AND ISNULL(intFutureMarketId,0) =case when ISNULL(@intFutureMarketId,0)=0 then ISNULL(intFutureMarketId,0) else @intFutureMarketId end 
AND ISNULL(intCommodityId,0) =case when ISNULL(@intCommodityId,0)=0 then ISNULL(intCommodityId,0) else @intCommodityId end  
AND ISNULL(intOptionMonthId,0) =case when ISNULL(@intOptionMonthId,0)=0 then ISNULL(intOptionMonthId,0) else @intOptionMonthId end  
AND ISNULL(dblStrike,0) =case when ISNULL(@dblStrike,0)=0 then ISNULL(dblStrike,0) else @dblStrike end
AND dtmExpiredDate <= @dtmPositionAsOf