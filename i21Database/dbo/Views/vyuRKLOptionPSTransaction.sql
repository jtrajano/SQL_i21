﻿CREATE VIEW vyuRKLOptionPSTransaction  

AS  

SELECT strInternalTradeNo
	, dtmTransactionDate
	, dtmFilledDate
	, strFutMarketName
	, strOptionMonth
	, strName
	, strAccountNumber
	, intTotalLot = ISNULL(intTotalLot, 0)
	, dblOpenLots = ISNULL(dblOpenLots, 0)
	, strOptionType
	, dblStrike
	, dblPremium = - dblPremium
	, dblPremiumValue = - dblPremiumValue
	, dblCommission
	, intFutOptTransactionId
	, dblNetPremium = ((-dblPremiumValue) + (dblCommission))
	, dblMarketPremium
	, dblMarketValue
	, dblMTM = CASE WHEN strBuySell = 'B' THEN dblMarketValue - dblPremiumValue ELSE dblPremiumValue - dblMarketValue END
	, strStatus
	, strCommodityCode
	, strLocationName
	, strBook
	, strSubBook
	, dblDelta
	, dblDeltaHedge = - (dblOpenLots * dblDelta * dblContractSize)
	, strHedgeUOM
	, strBuySell
	, dblContractSize
	, intFutOptTransactionHeaderId
	, intCurrencyId
	, strCurrency
	, intMainCurrencyId
	, strMainCurrency
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
	SELECT dblOpenLots = (intTotalLot - dblSelectedLot - intExpiredLots - intAssignedLots)
		, dblPremiumValue = ((intTotalLot - dblSelectedLot) * dblContractSize * dblPremium) / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
		, dblMarketValue = ((intTotalLot - dblSelectedLot) * dblContractSize * dblMarketPremium) / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
		, dblCommission = (- dblOptCommission * (intTotalLot - dblSelectedLot)) / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
		, *
	FROM (
		SELECT DISTINCT strInternalTradeNo
			, dtmTransactionDate
			, ot.dtmFilledDate
			, fm.strFutMarketName
			, om.strOptionMonth
			, e.strName
			, ba.strAccountNumber
			, intTotalLot = ot.intNoOfContract
			, dblSelectedLot = ISNULL((SELECT SUM (AD.intMatchQty) FROM tblRKOptionsMatchPnS AD Group By AD.intLFutOptTransactionId
									Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)
			, ot.strOptionType
			, ot.dblStrike
			, dblPremium = ot.dblPrice
			, fm.dblContractSize 
			, dblOptCommission = ISNULL(dblOptCommission, 0)
			, om.dtmExpirationDate
			, ot.strStatus
			, ic.strCommodityCode
			, cl.strLocationName
			, strBook
			, strSubBook
			, dblMarketPremium = ISNULL((SELECT TOP 1 dblSettle FROM tblRKFuturesSettlementPrice sp
										JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId=spm.intFutureSettlementPriceId
											AND sp.intFutureMarketId=ot.intFutureMarketId AND spm.intOptionMonthId= ot.intOptionMonthId
											and ot.dblStrike=spm.dblStrike and spm.intTypeId= (CASE WHEN ot.strOptionType='Put' THEN 1 ELSE 2 END)
										ORDER BY sp.dtmPriceDate desc),0)
			, ot.intOptionMonthId
			, ot.intFutureMarketId
			, dblDelta = ISNULL((SELECT TOP 1 dblDelta FROM tblRKFuturesSettlementPrice sp
								JOIN tblRKOptSettlementPriceMarketMap spm ON sp.intFutureSettlementPriceId=spm.intFutureSettlementPriceId
									AND sp.intFutureMarketId=ot.intFutureMarketId AND spm.intOptionMonthId= ot.intOptionMonthId
									and ot.dblStrike=spm.dblStrike and spm.intTypeId= (CASE WHEN ot.strOptionType='Put' THEN 1 ELSE 2 END)
								ORDER BY 1 desc),0)
			, strHedgeUOM = um.strUnitMeasure
			, strBuySell = CASE WHEN strBuySell = 'Buy' THEN 'B' ELSE 'S' END COLLATE Latin1_General_CI_AS
			, intFutOptTransactionId
			, intExpiredLots = ISNULL((SELECT SUM(intLots) FROM tblRKOptionsPnSExpired ope WHERE ope.intFutOptTransactionId = ot.intFutOptTransactionId),0)
			, intAssignedLots = ISNULL((SELECT SUM(intLots) FROM tblRKOptionsPnSExercisedAssigned opa WHERE opa.intFutOptTransactionId = ot.intFutOptTransactionId),0)
			, intCurrencyId = c.intCurrencyID
			, c.strCurrency
			, intMainCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE c.intCurrencyID END
			, strMainCurrency = CASE WHEN c.ysnSubCurrency = 0 THEN c.strCurrency ELSE MainCurrency.strCurrency END
			, c.intCent
			, c.ysnSubCurrency
			, intFutOptTransactionHeaderId
			, ysnExpired = CASE WHEN CONVERT(VARCHAR(10),dtmExpirationDate,111) < CONVERT(VARCHAR(10),GETDATE(),111) THEN 1 ELSE 0 END
			, intTypeId = CASE WHEN ot.strOptionType = 'Put' THEN 1 ELSE 2 END
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
		LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
		LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
		LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId where ot.intInstrumentTypeId=2 and strBuySell='Buy'
	) t
) t1  where dblOpenLots > 0