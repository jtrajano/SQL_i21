CREATE PROC uspRKGetM2MBasis
AS
SELECT DISTINCT strCommodityCode,strItemNo,c.strCountry strOriginDest,strFutMarketName,strFutureMonth,dtmEndDate as dtmPeriodTo,strLocationName,
strMarketZoneCode,strCurrency,strPricingType,'Contract' as strContractInventory,strContractType,NULL dblCashOrFuture,NULL dblBasisOrDiscount,
um.strUnitMeasure,intCommodityId,cd.intItemId,intOriginId,intFutureMarketId,intFutureMonthId,intCompanyLocationId,intMarketZoneId,intCurrencyId,
intPricingTypeId,intContractTypeId,u.intUnitMeasureId, '' as strRowState, 0 as intConcurrencyId into #temp
FROM vyuCTContractDetailView cd
JOIN tblICItemUOM u on cd.intItemUOMId=u.intItemUOMId and cd.strContractType not in('DP')
JOIN tblICUnitMeasure um on um.intUnitMeasureId=u.intUnitMeasureId
LEFT JOIN tblSMCountry c on cd.intOriginId=c.intCountryID 

SELECT convert(int,ROW_NUMBER() over (ORDER BY strItemNo)) AS intRowNumber,* from #temp

