CREATE PROCEDURE uspRKSOptionExerciseAssignTransaction
	@intTypeId int
	, @intEntityId int
	, @intFutureMarketId int
	, @intCommodityId int
	, @intOptionMonthId int
	, @dblStrike int
	, @dtmPositionAsOf datetime

AS

SET @dtmPositionAsOf = convert(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)

SELECT * FROM (
	SELECT m.intOptionsPnSExercisedAssignedId
		, convert(int,strTranNo) strTranNo
		, dtmTranDate
		, t.strInternalTradeNo
		, t.dtmFilledDate as dtmTransactionDate
		, case when t.strBuySell = 'Buy' Then 'B' else 'S' End strBuySell
		, m.dblLots
		, om.strOptionMonth
		, fm.strFutMarketName
		, t.dblStrike
		, t.strOptionType
		, t.dblPrice AS dblPremiumRate
		, (t.dblPrice * dblContractSize * dblLots) / case when ysnSubCurrency = 1 then intCent else 1 end AS dblPremiumTotal
		, e.strName
		, b.strAccountNumber
		, strCommodityCode
		, scl.strLocationName
		, cb.strBook
		, csb.strSubBook
		, t.intFutOptTransactionHeaderId
		, intTypeId = (case when t.strOptionType='Put' then 1 else 2 end)
		, t.intEntityId
		, t.intFutureMarketId
		, t.intCommodityId
		, t.intOptionMonthId
		, t.intFutOptTransactionId
	FROM tblRKOptionsPnSExercisedAssigned m
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
WHERE isnull(intTypeId,0)=case when isnull(@intTypeId,0) =0 then isnull(intTypeId,0) else @intTypeId end
	AND isnull(intEntityId,0)=case when isnull(@intEntityId,0) =0 then isnull(intEntityId,0) else @intEntityId end
	AND isnull(intFutureMarketId,0)=case when isnull(@intFutureMarketId,0) =0 then isnull(intFutureMarketId,0) else @intFutureMarketId end
	AND isnull(intCommodityId,0)=case when isnull(@intCommodityId,0) =0 then isnull(intCommodityId,0) else @intCommodityId end
	AND isnull(intOptionMonthId,0)=case when isnull(@intOptionMonthId,0) =0 then isnull(intOptionMonthId,0) else @intOptionMonthId end
	AND isnull(dblStrike,0)=case when isnull(@dblStrike,0) =0 then isnull(dblStrike,0) else @dblStrike end
	and dtmTranDate<=@dtmPositionAsOf