CREATE VIEW vyuIPGetM2MBasisDetail
AS
SELECT MD.intM2MBasisDetailId
	,MD.intM2MBasisId
	,MD.intConcurrencyId
	,MD.intCommodityId
	,MD.intItemId
	,MD.strOriginDest
	,MD.intFutureMarketId
	,MD.intFutureMonthId
	,MD.strPeriodTo
	,MD.intCompanyLocationId
	,MD.intMarketZoneId
	,MD.intCurrencyId
	,MD.intPricingTypeId
	,MD.strContractInventory
	,MD.intContractTypeId
	,MD.dblCashOrFuture
	,MD.dblRatio
	,MD.dblBasisOrDiscount
	,MD.intUnitMeasureId
	,MD.strMarketValuation
	,MD.intM2MBasisDetailRefId
	,C.strCommodityCode
	,I.strItemNo
	,FM.strFutMarketName
	,FMON.strFutureMonth
	,CL.strLocationName
	,MZ.strMarketZoneCode
	,CUR.strCurrency
	,PT.strPricingType
	,CT.strContractType
	,UOM.strUnitMeasure
FROM tblRKM2MBasis M
JOIN tblRKM2MBasisDetail MD ON MD.intM2MBasisId = M.intM2MBasisId
LEFT JOIN tblICCommodity C ON C.intCommodityId = MD.intCommodityId
LEFT JOIN tblICItem I ON I.intItemId = MD.intItemId
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = MD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMON ON FMON.intFutureMonthId = MD.intFutureMonthId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = MD.intCompanyLocationId
LEFT JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = MD.intMarketZoneId
LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = MD.intCurrencyId
LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = MD.intPricingTypeId
LEFT JOIN tblCTContractType CT ON CT.intContractTypeId = MD.intContractTypeId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = MD.intUnitMeasureId
