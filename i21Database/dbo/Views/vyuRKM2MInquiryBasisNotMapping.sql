CREATE VIEW  vyuRKM2MInquiryBasisNotMapping

AS 

SELECT  intM2MInquiryBasisDetailId
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
 FROM tblRKM2MInquiry bd
join tblRKM2MInquiryBasisDetail mb on mb.intM2MInquiryId=bd.intM2MInquiryId
join tblICCommodity c on c.intCommodityId=bd.intCommodityId
LEFT JOIN tblARMarketZone z on z.intMarketZoneId=bd.intMarketZoneId
LEFT JOIN tblCTContractType ct on ct.intContractTypeId=mb.intContractTypeId
LEFT JOIN tblICItem i on i.intItemId=mb.intItemId
LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=mb.intFutureMarketId
LEFT JOIN tblRKFuturesMonth mo on mo.intFutureMonthId=mb.intFutureMonthId
LEFT JOIN tblSMCompanyLocation l on l.intCompanyLocationId=mb.intCompanyLocationId
LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=mb.intCurrencyId
LEFT JOIN tblCTPricingType pt on pt.intPricingTypeId=mb.intPricingTypeId
LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=mb.intUnitMeasureId