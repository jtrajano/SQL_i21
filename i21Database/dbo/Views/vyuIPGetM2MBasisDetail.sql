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
FROM tblRKM2MBasis M WITH (NOLOCK)
JOIN tblRKM2MBasisDetail MD WITH (NOLOCK) ON MD.intM2MBasisId = M.intM2MBasisId
LEFT JOIN tblICCommodity C WITH (NOLOCK) ON C.intCommodityId = MD.intCommodityId
LEFT JOIN tblICItem I WITH (NOLOCK) ON I.intItemId = MD.intItemId
LEFT JOIN tblRKFutureMarket FM WITH (NOLOCK) ON FM.intFutureMarketId = MD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth FMON WITH (NOLOCK) ON FMON.intFutureMonthId = MD.intFutureMonthId
LEFT JOIN tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = MD.intCompanyLocationId
LEFT JOIN tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = MD.intMarketZoneId
LEFT JOIN tblSMCurrency CUR WITH (NOLOCK) ON CUR.intCurrencyID = MD.intCurrencyId
LEFT JOIN tblCTPricingType PT WITH (NOLOCK) ON PT.intPricingTypeId = MD.intPricingTypeId
LEFT JOIN tblCTContractType CT WITH (NOLOCK) ON CT.intContractTypeId = MD.intContractTypeId
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = MD.intUnitMeasureId
