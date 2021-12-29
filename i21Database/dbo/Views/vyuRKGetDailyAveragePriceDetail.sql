CREATE VIEW [dbo].[vyuRKGetDailyAveragePriceDetail]

AS

SELECT Detail.intDailyAveragePriceDetailId
	, Detail.intDailyAveragePriceId
	, Header.strAverageNo
	, Header.dtmDate
	, Header.intBookId
	, Header.strBook
	, Header.intSubBookId
	, Header.strSubBook
	, Header.ysnPosted
	, Detail.intFutureMarketId
	, strFutureMarket = Market.strFutMarketName
	, Detail.intCommodityId
	, strCommodity = Commodity.strCommodityCode
	, Detail.intFutureMonthId
	, Month.strFutureMonth
	, Detail.dblNoOfLots
	, Detail.dblAverageLongPrice
	, Detail.dblSwitchPL
	, Detail.dblOptionsPL
	, Detail.dblNetLongAvg
	, Detail.intBrokerId
	, Detail.dblSettlementPrice
	, dblM2M = ((Detail.dblSettlementPrice - Detail.dblNetLongAvg) * Detail.dblNoOfLots * Market.dblContractSize) / CASE WHEN ISNULL(Cur.ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END
	, strBrokerName = Broker.strName
	, Detail.intConcurrencyId
	, Month.ysnExpired
	, dblTonnage = dbo.fnCTConvertQuantityToTargetCommodityUOM(fUOM.intCommodityUnitMeasureId, tUOM.intCommodityUnitMeasureId, Detail.dblNoOfLots * Market.dblContractSize)
	, ysnRemoveInDetail = CAST(ISNULL(dapTrans.ysnRemoveInDetail, 0) AS bit) 
FROM tblRKDailyAveragePriceDetail Detail
LEFT JOIN vyuRKGetDailyAveragePrice Header ON Header.intDailyAveragePriceId = Detail.intDailyAveragePriceId
LEFT JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = Detail.intFutureMarketId
LEFT JOIN tblSMCurrency Cur ON Cur.intCurrencyID = Market.intCurrencyId
LEFT JOIN tblRKFuturesMonth Month ON Month.intFutureMonthId = Detail.intFutureMonthId
LEFT JOIN tblICCommodity Commodity ON Commodity.intCommodityId = Detail.intCommodityId
LEFT JOIN tblEMEntity Broker ON Broker.intEntityId = Detail.intBrokerId
CROSS JOIN (SELECT TOP 1 * FROM tblRKCompanyPreference) CP
LEFT JOIN tblICCommodityUnitMeasure fUOM ON fUOM.intCommodityId = Detail.intCommodityId AND fUOM.intUnitMeasureId = Market.intUnitMeasureId
LEFT JOIN tblICCommodityUnitMeasure tUOM ON tUOM.intCommodityId = Detail.intCommodityId AND tUOM.intUnitMeasureId = CP.intTonnageUOMId 
OUTER APPLY ( 
		SELECT TOP 1 ysnRemoveInDetail = 1  FROM  tblRKDailyAveragePriceDetailTransaction trans
		WHERE trans.intDailyAveragePriceDetailId = Detail.intDailyAveragePriceDetailId 
		AND Detail.dblNoOfLots = 0
		AND trans.strInstrumentType = 'Options'
		AND NOT EXISTS (
				SELECT TOP 1 '' FROM  tblRKDailyAveragePriceDetailTransaction trans
				WHERE trans.intDailyAveragePriceDetailId = Detail.intDailyAveragePriceDetailId 
				AND Detail.dblNoOfLots = 0
				AND trans.strInstrumentType = 'Futures'
			)
	) dapTrans