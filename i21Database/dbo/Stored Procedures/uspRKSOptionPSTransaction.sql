CREATE PROC [dbo].[uspRKSOptionPSTransaction]
	@intTypeId int
	, @intEntityId int
	, @intFutureMarketId int
	, @intCommodityId int
	, @intOptionMonthId int
	, @dblStrike int
	, @dtmPositionAsOf datetime

AS

SET @dtmPositionAsOf = convert(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)

SELECT strInternalTradeNo
	, dtmTransactionDate
	, dtmFilledDate
	, strFutMarketName
	, strOptionMonth
	, strName
	, strAccountNumber
	, isnull(dblTotalLot,0) dblTotalLot
	, isnull(dblOpenLots,0) dblOpenLots
	, strOptionType
	, dblStrike
	, dblPremium
	, dblPremiumValue as dblPremiumValue
	, dblCommission
	, intFutOptTransactionId
	, (dblPremiumValue + dblCommission) as dblNetPremium
	, dblMarketPremium as dblMarketPremium
	, -abs(dblMarketValue) as dblMarketValue
	, case when strBuySell='B' then dblMarketValue-dblPremiumValue else dblPremiumValue-dblMarketValue end as dblMTM
	, strStatus
	, strCommodityCode
	, strLocationName
	, strBook
	, strSubBook
	, dblDelta
	, -(dblOpenLots * dblDelta * dblContractSize) AS dblDeltaHedge
	, strHedgeUOM
	, strBuySell
	, dblContractSize
	, intFutOptTransactionHeaderId
	, intCurrencyId
	, intCent
	, ysnSubCurrency
	, dtmExpirationDate
	, ysnExpired
	, intTypeId
	, intEntityId
	, intFutureMarketId
	, intCommodityId
	, intOptionMonthId
FROM (
	SELECT (dblTotalLot-dblSelectedLot1-dblExpiredLots-dblAssignedLots) AS dblOpenLots
		, '' as dblSelectedLot
		, ((dblTotalLot-dblSelectedLot1)*dblContractSize*dblPremium)/ case when ysnSubCurrency = 1 then intCent else 1 end  as dblPremiumValue
		, ((dblTotalLot-dblSelectedLot1)*dblContractSize*dblMarketPremium)/ case when ysnSubCurrency = 1 then intCent else 1 end  as dblMarketValue
		, (-dblOptCommission*(dblTotalLot-dblSelectedLot1))/ case when ysnSubCurrency = 1 then intCent else 1 end AS dblCommission
		, *
	FROM (
		SELECT DISTINCT strInternalTradeNo AS strInternalTradeNo
			, dtmTransactionDate as dtmTransactionDate
			, ot.dtmFilledDate as dtmFilledDate
			, fm.strFutMarketName as strFutMarketName
			, om.strOptionMonth as strOptionMonth
			, e.strName as strName
			, ba.strAccountNumber
			, ot.dblNoOfContract as dblTotalLot
			, IsNull((SELECT SUM (AD.intMatchQty) from tblRKOptionsMatchPnS AD where  dtmMatchDate<=@dtmPositionAsOf Group By AD.intSFutOptTransactionId
					Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0) As dblSelectedLot1
			, ot.strOptionType
			, ot.dblStrike
			, ot.dblPrice as dblPremium
			, fm.dblContractSize as dblContractSize
			, isnull(dblOptCommission,0) as dblOptCommission
			, om.dtmExpirationDate
			, ot.strStatus
			, ic.strCommodityCode
			, cl.strLocationName
			, strBook
			, strSubBook
			, isnull((SELECT TOP 1 dblSettle  FROM tblRKFuturesSettlementPrice sp
					JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId=spm.intFutureSettlementPriceId
						AND sp.intFutureMarketId=ot.intFutureMarketId AND spm.intOptionMonthId= ot.intOptionMonthId
						and ot.dblStrike=spm.dblStrike and spm.intTypeId= (case when ot.strOptionType='Put' then 1 else 2 end)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmPriceDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)
					ORDER BY sp.dtmPriceDate desc),0) as dblMarketPremium
			, '' as MarketValue
			, ''as MTM
			, ot.intOptionMonthId
			, ot.intFutureMarketId
			, isnull((SELECT TOP 1 dblDelta  FROM tblRKFuturesSettlementPrice sp
					JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId=spm.intFutureSettlementPriceId
						AND sp.intFutureMarketId=ot.intFutureMarketId AND spm.intOptionMonthId= ot.intOptionMonthId
						and ot.dblStrike=spm.dblStrike and spm.intTypeId= (case when ot.strOptionType='Put' then 1 else 2 end)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmPriceDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)
					ORDER BY 1 desc),0) as dblDelta
			, '' as DeltaHedge
			, um.strUnitMeasure as strHedgeUOM
			, CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
			, intFutOptTransactionId
			, isnull((Select SUM(intLots) From tblRKOptionsPnSExpired ope
					where ope.intFutOptTransactionId= ot.intFutOptTransactionId
					and dtmExpiredDate<=@dtmPositionAsOf),0) dblExpiredLots
			, isnull((Select SUM(intLots) FROM tblRKOptionsPnSExercisedAssigned opa
					where opa.intFutOptTransactionId= ot.intFutOptTransactionId
					and dtmTranDate<=@dtmPositionAsOf),0) dblAssignedLots
			, c.intCurrencyID as intCurrencyId
			, c.intCent
			, ysnSubCurrency
			, ot.intFutOptTransactionHeaderId
			, CASE WHEN CONVERT(VARCHAR(10),dtmExpirationDate,111) < CONVERT(VARCHAR(10),GETDATE(),111) then 1 else 0 end ysnExpired
			, case when ot.strOptionType='Put' then 1 else 2 end intTypeId
			, ot.intEntityId
			, ot.intCommodityId
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.strStatus='Filled'
		join tblICUnitMeasure um on fm.intUnitMeasureId=um.intUnitMeasureId
		JOIN tblICCommodity ic on ic.intCommodityId=ot.intCommodityId
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=ot.intLocationId
		JOIN tblRKOptionsMonth om on ot.intOptionMonthId=om.intOptionMonthId
		JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId
		JOIN tblEMEntity e on e.intEntityId=ot.intEntityId
		LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId  AND ba.intBrokerageAccountId=bc.intBrokerageAccountId
		LEFT JOIN tblSMCurrency c on c.intCurrencyID=bc.intFutCurrencyId
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId where ot.intInstrumentTypeId=2 and strBuySell='Sell'
	)t
)t1 where dblOpenLots > 0
	AND isnull(intTypeId,0)=case when isnull(@intTypeId,0) =0 then isnull(intTypeId,0) else @intTypeId end
	AND isnull(intEntityId,0)=case when isnull(@intEntityId,0) =0 then isnull(intEntityId,0) else @intEntityId end
	AND isnull(intFutureMarketId,0)=case when isnull(@intFutureMarketId,0) =0 then isnull(intFutureMarketId,0) else @intFutureMarketId end
	AND isnull(intCommodityId,0)=case when isnull(@intCommodityId,0) =0 then isnull(intCommodityId,0) else @intCommodityId end
	AND isnull(intOptionMonthId,0)=case when isnull(@intOptionMonthId,0) =0 then isnull(intOptionMonthId,0) else @intOptionMonthId end
	AND isnull(dblStrike,0)=case when isnull(@dblStrike,0) =0 then isnull(dblStrike,0) else @dblStrike end
	and convert(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110)<=@dtmPositionAsOf