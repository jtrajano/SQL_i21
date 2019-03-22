CREATE VIEW vyuRKM2MInquiryNotMapping
AS
SELECT intM2MInquiryId
	,strCommodityCode
	,cur.strCurrency
	,strMarketZoneCode
	,strLocationName
	,um.strUnitMeasure
	,dtmM2MBasisDate
	,dtmPriceDate dtmFutureSettlementDate
	,pum.strUnitMeasure strPriceUnitMeasure
FROM tblRKM2MInquiry bd
JOIN tblRKM2MBasis bas ON bas.intM2MBasisId = bd.intM2MBasisId
JOIN tblSMCurrency cur ON cur.intCurrencyID = bd.intCurrencyId
JOIN tblICUnitMeasure pum ON pum.intUnitMeasureId = bd.intPriceItemUOMId
JOIN tblRKFuturesSettlementPrice sc ON sc.intFutureSettlementPriceId = bd.intFutureSettlementPriceId
LEFT JOIN tblICCommodity c ON c.intCommodityId = bd.intCommodityId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = bd.intUnitMeasureId
LEFT JOIN tblARMarketZone z ON z.intMarketZoneId = bd.intMarketZoneId
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = bd.intCompanyLocationId
