CREATE VIEW [dbo].[vyuRKGetM2MDifferentialBasis]

AS

SELECT be.intM2MDifferentialBasisId
    , be.intM2MHeaderId
    , be.intCommodityId
	, c.strCommodityCode
    , be.intItemId
	, i.strItemNo
	, be.strOriginDest
    , be.intFutureMarketId
	, strFutureMarket = fMar.strFutMarketName
    , be.intFutureMonthId
	, fMon.strFutureMonth
    , be.strPeriodTo
    , be.intLocationId
	, loc.strLocationName
    , be.intMarketZoneId
	, mz.strMarketZoneCode
    , be.intCurrencyId
	, cur.strCurrency
    , be.intPricingTypeId
	, pt.strPricingType
    , be.strContractInventory
    , be.intContractTypeId
	, ct.strContractType
    , be.dblCashOrFuture
    , be.dblBasisOrDiscount
	, be.dblRatio
    , be.intUnitMeasureId
	, uom.strUnitMeasure
    , be.intM2MBasisDetailId
	, be.intConcurrencyId
	, strOriginPort = originPort.strCity
	, intOriginPortId = originPort.intCityId
	, strDestinationPort = destinationPort.strCity
	, intDestinationPortId = destinationPort.intCityId
	, strCropYear = cropYear.strCropYear
	, intCropYearId = cropYear.intCropYearId
	, strStorageLocation = storageLocation.strSubLocationName
	, intStorageLocationId = storageLocation.intCompanyLocationSubLocationId
	, strStorageUnit = storageUnit.strName
	, intStorageUnitId = storageUnit.intStorageLocationId
	, strMTMPoint  = mtm.strMTMPoint
	, intMTMPointId = be.intMTMPointId
	, strProductType = PRODTYPE.strDescription
	, strGrade = GRADE.strDescription
	, strRegion = REGION.strDescription
	, strProductLine = PRODLINE.strDescription
	, strClass = CLASS.strDescription
	, strCertification = be.strCertification
FROM tblRKM2MDifferentialBasis be
LEFT JOIN tblICCommodity c ON c.intCommodityId = be.intCommodityId
LEFT JOIN tblICItem i ON i.intItemId = be.intItemId
LEFT JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = be.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = be.intFutureMonthId
LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = be.intLocationId
LEFT JOIN tblARMarketZone mz ON mz.intMarketZoneId = be.intMarketZoneId
LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = be.intCurrencyId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = be.intPricingTypeId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = be.intContractTypeId
LEFT JOIN tblICUnitMeasure uom ON uom.intUnitMeasureId = be.intUnitMeasureId
LEFT JOIN tblRKM2MBasisDetail bd ON bd.intM2MBasisDetailId = be.intM2MBasisDetailId
LEFT JOIN tblSMCity originPort
	ON originPort.intCityId = be.intOriginPortId
LEFT JOIN tblSMCity destinationPort
	ON destinationPort.intCityId = be.intDestinationPortId
LEFT JOIN tblCTCropYear cropYear
	ON cropYear.intCropYearId = be.intCropYearId
LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
	ON storageLocation.intCompanyLocationSubLocationId = be.intStorageLocationId
LEFT JOIN tblICStorageLocation storageUnit
	ON storageUnit.intStorageLocationId = be.intStorageUnitId
LEFT JOIN tblCTMTMPoint mtm
	ON mtm.intMTMPointId = be.intMTMPointId
LEFT JOIN tblICCommodityAttribute PRODTYPE 
	ON PRODTYPE.intCommodityAttributeId = i.intProductTypeId
LEFT JOIN tblICCommodityProductLine PRODLINE 
	ON PRODLINE.intCommodityProductLineId = i.intProductLineId
LEFT JOIN tblICCommodityAttribute GRADE 
	ON GRADE.intCommodityAttributeId = i.intGradeId
LEFT JOIN tblICCertification CERTI 
	ON CERTI.intCertificationId = i.intCertificationId
LEFT JOIN tblICCommodityAttribute CLASS
	ON CLASS.intCommodityAttributeId = i.intClassVarietyId
LEFT JOIN tblICCommodityAttribute REGION
	ON REGION.intCommodityAttributeId = i.intRegionId