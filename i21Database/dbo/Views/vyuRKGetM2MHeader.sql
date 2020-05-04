CREATE VIEW [dbo].[vyuRKGetM2MHeader]

AS

SELECT H.intM2MHeaderId
    , H.strRecordName
    , H.intCommodityId
	, c.strCommodityCode
    , H.intM2MTypeId
	, t.strType
    , H.intM2MBasisId
	, b.dtmM2MBasisDate
    , H.intFutureSettlementPriceId
	, sp.dtmPriceDate
    , H.intPriceUOMId
	, strPriceUOM = pUOM.strUnitMeasure
    , H.intQtyUOMId
	, strQtyUOM = qUOM.strUnitMeasure
    , H.intCurrencyId
	, cur.strCurrency
    , H.dtmEndDate
    , H.strRateType
    , H.intLocationId
	, loc.strLocationName
    , H.intMarketZoneId
	, mz.strMarketZoneCode
    , H.ysnByProducer
    , H.dtmPostDate
    , H.dtmReverseDate
    , H.dtmLastReversalDate
    , H.ysnPosted
    , H.dtmCreatedDate
    , H.dtmUnpostDate
    , H.strBatchId
    , H.intCompanyId
    , H.intConcurrencyId
FROM tblRKM2MHeader H
LEFT JOIN tblICCommodity c ON c.intCommodityId = H.intCommodityId
LEFT JOIN tblRKM2MType t ON t.intM2MTypeId = H.intM2MTypeId
LEFT JOIN tblRKM2MBasis b ON b.intM2MBasisId = H.intM2MBasisId
LEFT JOIN tblRKFuturesSettlementPrice sp ON sp.intFutureSettlementPriceId = H.intFutureSettlementPriceId
LEFT JOIN tblICUnitMeasure pUOM ON pUOM.intUnitMeasureId = H.intPriceUOMId
LEFT JOIN tblICUnitMeasure qUOM ON qUOM.intUnitMeasureId = H.intQtyUOMId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = H.intCurrencyId
LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = H.intLocationId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = H.intMarketZoneId