CREATE VIEW  vyuRKM2MInquiryBasisNotMapping

AS 

SELECT intM2MBasisDetailId
		,strCommodityCode
		,strContractType
		,strCurrency
		,strMarketZoneCode
		,strFutMarketName
		,strFutureMonth
		,strItemNo
		,strPricingType
		,strLocationName
		,strUnitMeasure
 FROM tblRKM2MBasisDetail bd
join tblRKM2MBasis mb on mb.intM2MBasisId=bd.intM2MBasisId
join tblICCommodity c on c.intCommodityId=bd.intCommodityId
LEFT JOIN tblARMarketZone z on z.intMarketZoneId=bd.intMarketZoneId
LEFT JOIN tblCTContractType ct on ct.intContractTypeId=bd.intContractTypeId
LEFT JOIN tblICItem i on i.intItemId=bd.intItemId
LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=bd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth mo on mo.intFutureMonthId=bd.intFutureMonthId
LEFT JOIN tblSMCompanyLocation l on l.intCompanyLocationId=bd.intCompanyLocationId
LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bd.intCurrencyId
LEFT JOIN tblCTPricingType pt on pt.intPricingTypeId=bd.intPricingTypeId
LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=bd.intUnitMeasureId


