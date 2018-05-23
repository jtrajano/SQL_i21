CREATE VIEW  vyuRKBasisDetailNotMapping

AS 

SELECT 
		bd.intM2MBasisDetailId,
		bd.intM2MBasisId,
		bd.intCommodityId,
		bd.intItemId,
		bd.strOriginDest,
		bd.intFutureMarketId,
		bd.intFutureMonthId,
		bd.strPeriodTo,
		bd.intCompanyLocationId,
		bd.intMarketZoneId,
		bd.intCurrencyId,
		bd.intPricingTypeId,
		bd.strContractInventory,
		bd.intContractTypeId,
		bd.dblCashOrFuture,
		bd.dblRatio,
		bd.dblBasisOrDiscount,
		bd.intUnitMeasureId,
		bd.strMarketValuation
		,strCommodityCode
		,strContractType
		,strCurrency
		,strMarketZoneCode
		,strFutMarketName
		,strFutureMonth
		,strItemNo
		,pt.strPricingType
		,strLocationName
		,strUnitMeasure
		,CAST(CASE WHEN IBD.intM2MBasisDetailId IS NULL THEN 0 ELSE 1 END AS bit) AS ysnUsed
		,M2M.strRecordName as strM2MBatch
		,M2M.dtmTransactionUpTo as dtmM2MDate
FROM tblRKM2MBasisDetail bd
JOIN tblRKM2MBasis mb on mb.intM2MBasisId=bd.intM2MBasisId
JOIN tblICCommodity c on c.intCommodityId=bd.intCommodityId
LEFT JOIN tblARMarketZone z on z.intMarketZoneId=bd.intMarketZoneId
LEFT JOIN tblCTContractType ct on ct.intContractTypeId=bd.intContractTypeId
LEFT JOIN tblICItem i on i.intItemId=bd.intItemId
LEFT JOIN tblRKFutureMarket m on m.intFutureMarketId=bd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth mo on mo.intFutureMonthId=bd.intFutureMonthId
LEFT JOIN tblSMCompanyLocation l on l.intCompanyLocationId=bd.intCompanyLocationId
LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bd.intCurrencyId
LEFT JOIN tblCTPricingType pt on pt.intPricingTypeId=bd.intPricingTypeId
LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=bd.intUnitMeasureId
LEFT JOIN tblRKM2MInquiryBasisDetail IBD on bd.intM2MBasisDetailId = IBD.intM2MBasisDetailId
LEFT JOIN tblRKM2MInquiry M2M ON IBD.intM2MInquiryId = M2M.intM2MInquiryId