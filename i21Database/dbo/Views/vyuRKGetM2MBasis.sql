CREATE VIEW [dbo].[vyuRKGetM2MBasis]
AS

WITH
parameter_tbl
AS 
( 
	SELECT GETDATE() currentDate
)

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
	, ysnLicensed = ISNULL(cl.ysnLicensed, 0)
	, intBoardMonthId = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN cd.intFutureMonthId ELSE NULL END
	, strBoardMonth = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN fm1.strFutureMonth ELSE NULL END
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
INNER JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
	AND ISNULL(fm1.ysnExpired, 0) = 0 
	AND ISNULL(fm1.dtmLastTradingDate, (SELECT currentDate FROM parameter_tbl)) >=  (SELECT currentDate FROM parameter_tbl)
LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
CROSS APPLY (SELECT TOP 1 ysnUseBoardMonth = ISNULL(ysnUseBoardMonth, 0) FROM tblRKCompanyPreference) CP
WHERE dblBalance > 0 AND cd.intPricingTypeId NOT IN (5,6) AND cd.intContractStatusId <> 3	

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
	, ysnLicensed = ISNULL(cl.ysnLicensed, 0)
	, intBoardMonthId = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN cd.intFutureMonthId ELSE NULL END
	, strBoardMonth = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN fm1.strFutureMonth ELSE NULL END
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
CROSS APPLY (SELECT TOP 1 ysnUseBoardMonth = ISNULL(ysnUseBoardMonth, 0) FROM tblRKCompanyPreference) CP
WHERE cd.intPricingTypeId IN( 5,6) AND cd.intContractStatusId <> 3

UNION SELECT DISTINCT iis.strCommodityCode
	, iis.strItemNo
	, strDestination = NULL
	, strFutMarketName
	, strFutureMonth
	, strPeriodTo = NULL
	, iis.strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(strFMCurrency,'') = '' THEN iis.strCurrency ELSE strFMCurrency END)
	, strPricingType
	, strContractInventory = 'Inventory' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(strFMUOM,'') = '' THEN (CASE WHEN ISNULL(ct.strUOM, '') = '' THEN strStockUOM ELSE ct.strUOM END) ELSE strFMUOM END)
	, iis.intCommodityId
	, iis.intItemId
	, intOriginId = iis.intOriginId
	, ct.intFutureMarketId
	, ct.intFutureMonthId
	, iis.intLocationId
	, ct.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(intFMCurrencyId,'') = '' THEN iis.intCurrencyId ELSE intFMCurrencyId END)
	, ct.intPricingTypeId
	, ct.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(strFMUOM,'') = '' THEN (CASE WHEN ISNULL(intUOMId, '') = '' THEN intStockUOMId ELSE intUOMId END) ELSE intFMUOMId END)
	, intConcurrencyId = 0
	, iis.strMarketValuation
	, ysnLicensed = ISNULL(iis.ysnLicensed, 0)
	, intBoardMonthId = NULL
	, strBoardMonth = NULL
FROM (
	SELECT it.intItemId
		, it.strItemNo
		, it.strLocationName
		, it.intLocationId
		, it.strCurrency
		, it.intCurrencyId
		, it.strMarketValuation
		, it.intOriginId
		, it.ysnLicensed
		, c.intCommodityId
		, c.strCommodityCode
		, intStockUOMId = UOM.intUnitMeasureId
		, strStockUOM = UOM.strUnitMeasure
	FROM vyuRKGetInventoryTransaction it
	INNER JOIN tblICItem i ON it.intItemId = i.intItemId
	INNER JOIN tblICCommodity c on i.intCommodityId =  c.intCommodityId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = i.intItemId AND ItemUOM.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	WHERE dblQuantity > 0
		AND it.strLotTracking = (CASE WHEN (SELECT TOP 1 intRiskViewId FROM tblRKCompanyPreference) = 2 THEN it.strLotTracking ELSE 'No' END)) iis
OUTER APPLY (
	SELECT DISTINCT TOP 1 cd.intItemId
		, cd.intCompanyLocationId
		, fm.intFutureMarketId
		, fmon.intFutureMonthId
		, cd.intItemUOMId
		, ch.intCommodityId
		, c.strCommodityCode
		, cd.intMarketZoneId
		, ct.intContractTypeId
		, ct.strContractType
		, pt.intPricingTypeId
		, pt.strPricingType
		, cd.intCurrencyId
		, fm.strFutMarketName
		, strFutureMonth
		, strMarketZoneCode
		, strFMCurrency = muc.strCurrency
		, intFMCurrencyId = muc.intCurrencyID
		, intFMUOMId = mum.intUnitMeasureId
		, strFMUOM = mum.strUnitMeasure
		, intUOMId = um.intUnitMeasureId
		, strUOM = um.strUnitMeasure
	FROM tblCTContractDetail cd
	JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
	JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
	JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
	JOIN tblRKCommodityMarketMapping mm ON mm.intCommodityId = c.intCommodityId
	LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = mm.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth fmon ON fmon.intFutureMonthId = cd.intFutureMonthId
	LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
	LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
	LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
	LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
	WHERE cd.intItemId = iis.intItemId
) ct