CREATE VIEW [dbo].[vyuRKGetM2MTransaction]

AS

SELECT t.intM2MTransactionId
    , t.intM2MHeaderId
	, t.strContractOrInventoryType
    , t.strContractSeq
    , t.intEntityId
    , t.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
    , t.intFutureMonthId
	, fMon.strFutureMonth
    , t.dblOpenQty
    , t.intCommodityId
	, c.strCommodityCode
    , t.intItemId
	, i.strItemNo
    , t.strOriginDest
    , t.strPosition
    , t.strPeriod
    , t.strPriOrNotPriOrParPriced
    , t.strPricingType
    , t.dblContractBasis
	, t.dblContractRatio
    , t.dblFutures
    , t.dblCash
    , t.dblContractPrice
    , t.dblCosts
    , t.dblAdjustedContractPrice
    , t.dblMarketBasis
	, t.dblMarketRatio
    , t.dblFuturePrice
    , t.dblContractCash
    , t.dblMarketPrice
    , t.dblResult
    , t.dblResultBasis
	, t.dblResultRatio
    , t.dblMarketFuturesResult
    , t.dblResultCash
	, t.intContractHeaderId
    , t.dtmPlannedAvailabilityDate
	, t.intContractDetailId
	, t.dblPricedQty
	, t.dblUnPricedQty
	, t.dblPricedAmount
	, t.intSpreadMonthId
	, strSpreadMonth = sMon.strFutureMonth
	, t.dblSpreadMonthPrice
	, t.dblSpread
	, t.intLocationId
	, loc.strLocationName
	, t.intMarketZoneId
	, mz.strMarketZoneCode
    , t.intConcurrencyId
FROM tblRKM2MTransaction t
LEFT JOIN tblICCommodity c ON c.intCommodityId = t.intCommodityId
LEFT JOIN tblICItem i ON i.intItemId = t.intItemId
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = t.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = t.intFutureMonthId
LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = t.intLocationId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = t.intMarketZoneId
LEFT JOIN tblRKFuturesMonth sMon ON sMon.intFutureMonthId = t.intSpreadMonthId
--LEFT JOIN tblCTContractHeader ch ON ch.intContractHeaderId = t.intContractHeaderId
--LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = t.intContractDetailId