CREATE VIEW [dbo].[vyuRKGetM2MDifferentialBasis]

AS

SELECT be.intM2MDifferentialBasisId
    , be.intM2MHeaderId
    , be.intCommodityId
	, c.strCommodityCode
    , be.intItemId
	, i.strItemNo
	, be.strOriginDest
    , be.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
    , be.intFutureMonthId
	, fMon.strFutureMonth
    , be.strPeriodTo
    , be.intLocationId
	, loc.strLocationName
    , be.intMarketZoneId
	, mz.strMarketZoneCode
    , be.intCurrencyId
	, cur.strCurrency
    , be.intPricingTypeId
	, pt.strPricingType
    , be.strContractInventory
    , be.intContractTypeId
	, ct.strContractType
    , be.dblCashOrFuture
    , be.dblBasisOrDiscount
	, be.dblRatio
    , be.intUnitMeasureId
	, uom.strUnitMeasure
    , be.intM2MBasisDetailId
	, be.intConcurrencyId
FROM tblRKM2MDifferentialBasis be
LEFT JOIN tblICCommodity c ON c.intCommodityId = be.intCommodityId
LEFT JOIN tblICItem i ON i.intItemId = be.intItemId
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = be.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = be.intFutureMonthId
LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = be.intLocationId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = be.intMarketZoneId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = be.intCurrencyId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = be.intPricingTypeId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = be.intContractTypeId
LEFT JOIN tblICUnitMeasure uom ON uom.intUnitMeasureId = be.intUnitMeasureId
LEFT JOIN tblRKM2MBasisDetail bd ON bd.intM2MBasisDetailId = be.intM2MBasisDetailId