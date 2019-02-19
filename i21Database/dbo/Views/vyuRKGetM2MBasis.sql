CREATE VIEW [dbo].[vyuRKGetM2MBasis]

AS

SELECT DISTINCT strCommodityCode
	, im.strItemNo
	, strOriginDest = ca.strDescription
	, fm.strFutMarketName
	, fm1.strFutureMonth
	, strPeriodTo = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
	, strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END)
	, strPricingType
	, strContractInventory = 'Contract' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END)
	, ch.intCommodityId
	, cd.intItemId
	, intOriginId = i.intOriginId
	, cd.intFutureMarketId
	, cd.intFutureMonthId
	, cd.intCompanyLocationId
	, mz.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END)
	, cd.intPricingTypeId
	, ct.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END)
	, intConcurrencyId = 0
	, i.strMarketValuation
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
LEFT JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
LEFT JOIN tblICItem im ON im.intItemId = cd.intItemId
LEFT JOIN tblICItem i ON i.intItemId = cd.intItemId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
WHERE dblBalance > 0 AND cd.intPricingTypeId <> 5 AND cd.intContractStatusId <> 3

UNION SELECT DISTINCT strCommodityCode
	, im.strItemNo
	, strOriginDest = ca.strDescription
	, fm.strFutMarketName
	, fm1.strFutureMonth
	, strPeriodTo = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
	, strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END)
	, strPricingType
	, strContractInventory = 'Contract' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END)
	, ch.intCommodityId
	, cd.intItemId
	, intOriginId = i.intOriginId
	, fmm.intFutureMarketId
	, cd.intFutureMonthId
	, cd.intCompanyLocationId
	, mz.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END)
	, cd.intPricingTypeId
	, ct.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END)
	, intConcurrencyId = 0
	, i.strMarketValuation
FROM tblCTContractHeader ch
JOIN tblCTContractDetail  cd ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
LEFT JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
LEFT JOIN tblICItem im ON im.intItemId = cd.intItemId
LEFT JOIN tblICItem i ON i.intItemId = cd.intItemId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
LEFT JOIN tblRKCommodityMarketMapping fmm ON fmm.intCommodityId = ch.intCommodityId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = fmm.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
WHERE cd.intPricingTypeId = 5 AND cd.intContractStatusId <> 3

UNION SELECT DISTINCT strCommodityCode
	, i.strItemNo
	, strOriginDest = ca.strDescription
	, fm.strFutMarketName
	, strFutureMonth
	, strPeriodTo = NULL
	, strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END)
	, strPricingType
	, strContractInventory = 'Inventory' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END)
	, ch.intCommodityId
	, cd.intItemId
	, intOriginId = i.intOriginId
	, cd.intFutureMarketId
	, cd.intFutureMonthId
	, cd.intCompanyLocationId
	, cd.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END)
	, cd.intPricingTypeId
	, ch.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END)
	, intConcurrencyId = 0
	, i.strMarketValuation
FROM tblICItemStock iis
JOIN tblICItem i ON i.intItemId = iis.intItemId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
LEFT JOIN tblCTContractDetail cd ON iis.intItemId = cd.intItemId
LEFT JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fmon ON fmon.intFutureMonthId = cd.intFutureMonthId
LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
LEFT JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
LEFT JOIN tblICItemLocation itm on itm.intItemId = i.intItemId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = itm.intLocationId
LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
WHERE (iis.dblUnitOnHand > 0 OR iis.dblUnitStorage > 0)
	AND i.strLotTracking = (CASE WHEN (SELECT TOP 1 strRiskView FROM tblRKCompanyPreference) = 'Processor' THEN i.strLotTracking ELSE 'No' END)