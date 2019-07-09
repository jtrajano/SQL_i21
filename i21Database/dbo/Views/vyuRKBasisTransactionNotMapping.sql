CREATE VIEW vyuRKBasisTransactionNotMapping

AS 

SELECT intM2MBasisTransactionId
	, mb.dtmM2MBasisDate
	, bd.intM2MBasisId
	, bd.intFutureMarketId
	, bd.intCommodityId
	, bd.intItemId
	, bd.intCurrencyId
	, bd.dblBasis
	, bd.intUnitMeasureId
	, strCommodityCode
	, strFutMarketName
	, strCurrency
	, strItemNo
	, strUnitMeasure
	, bd.intCompanyLocationId
	, cl.strLocationName
	, bd.intMarketZoneId
	, strMarketZone = mz.strMarketZoneCode
FROM tblRKM2MBasisTransaction bd
JOIN tblRKM2MBasis mb ON mb.intM2MBasisId=bd.intM2MBasisId
JOIN tblICCommodity c ON c.intCommodityId=bd.intCommodityId
JOIN tblICItem i ON i.intItemId=bd.intItemId
JOIN tblRKFutureMarket m ON m.intFutureMarketId=bd.intFutureMarketId
JOIN tblSMCurrency cur ON cur.intCurrencyID=bd.intCurrencyId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId=bd.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = bd.intCompanyLocationId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = bd.intMarketZoneId