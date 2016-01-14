CREATE PROC uspRKGetM2MBasisOnDate
	 @intM2MBasisId int,
	 @intCommodityId int

AS
SELECT bd.intM2MBasisDetailId, c.strCommodityCode,	i.strItemNo,		ca.strDescription as strOriginDest,		fm.strFutMarketName, '' as strFutureMonth,
		bd.strPeriodTo,		strLocationName,		strMarketZoneCode,		strCurrency,		strPricingType,
		strContractInventory,		strContractType,strUnitMeasure,
		bd.intCommodityId,		bd.intItemId, bd.strOriginDest,		bd.intFutureMarketId,		bd.intFutureMonthId,
		bd.intCompanyLocationId,		bd.intMarketZoneId,		bd.intCurrencyId,	bd.intPricingTypeId,		bd.strContractInventory,
		bd.intContractTypeId,		bd.dblCashOrFuture,		bd.dblBasisOrDiscount,		bd.intUnitMeasureId	,i.strMarketValuation ,0 as intConcurrencyId	
FROM
 tblRKM2MBasis b
JOIN tblRKM2MBasisDetail bd on b.intM2MBasisId=bd.intM2MBasisId
LEFT JOIN tblICCommodity c on c.intCommodityId=bd.intCommodityId
LEFT JOIN tblICItem i on i.intItemId=bd.intItemId	
LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = bd.intFutureMarketId
LEFT JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = bd.intCompanyLocationId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = bd.intCurrencyId
LEFT JOIN tblCTPricingType pt on pt.intPricingTypeId=bd.intPricingTypeId
LEFT JOIN tblCTContractType ct on ct.intContractTypeId=bd.intContractTypeId
LEFT JOIN tblARMarketZone mz on mz.intMarketZoneId=bd.intMarketZoneId
LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId=bd.intUnitMeasureId
WHERE b.intM2MBasisId= @intM2MBasisId and bd.intFutureMarketId is not null AND  c.intCommodityId=
case when @intCommodityId = 0 then c.intCommodityId else @intCommodityId end 
order by strMarketValuation,strFutMarketName,strCommodityCode,strItemNo,strLocationName, convert(datetime,'01 '+strPeriodTo)