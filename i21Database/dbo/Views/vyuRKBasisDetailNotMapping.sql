﻿CREATE VIEW  vyuRKBasisDetailNotMapping

AS 

SELECT 
		  bd.intM2MBasisDetailId
		, bd.intM2MBasisId
		, bd.intCommodityId
		, bd.intItemId
		, bd.strOriginDest
		, bd.intFutureMarketId
		, bd.intFutureMonthId
		, bd.strPeriodTo
		, bd.intCompanyLocationId
		, bd.intMarketZoneId
		, bd.intCurrencyId
		, bd.intPricingTypeId
		, bd.strContractInventory
		, bd.intContractTypeId
		, bd.dblCashOrFuture
		, bd.dblRatio
		, bd.dblBasisOrDiscount
		, bd.intUnitMeasureId
		, bd.strMarketValuation
		, strCommodityCode
		, strContractType
		, strCurrency
		, strMarketZoneCode
		, strFutMarketName
		, strFutureMonth
		, strItemNo
		, pt.strPricingType
		, strLocationName
		, strUnitMeasure
		, CAST(CASE WHEN IBD.intM2MBasisDetailId IS NULL THEN 0 ELSE 1 END AS bit) AS ysnUsed
		, M2M.strRecordName as strM2MBatch
		, M2M.dtmTransactionUpTo as dtmM2MDate
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
		, strProductType = ProductType.strDescription
		, i.intProductTypeId
		, strProductLine = ProductLine.strDescription
		, i.intProductLineId
		, strGrade  = Grade.strDescription
		, i.intGradeId
		, strCertification = bd.strCertification
		, i.intCertificationId
		, MTMPoint.strMTMPoint
		, bd.intMTMPointId
		, strClass = CLASS.strDescription
		, strRegion = REGION.strDescription
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
LEFT JOIN tblSMCity originPort
	ON originPort.intCityId = bd.intOriginPortId
LEFT JOIN tblSMCity destinationPort
	ON destinationPort.intCityId = bd.intDestinationPortId
LEFT JOIN tblCTCropYear cropYear
	ON cropYear.intCropYearId = bd.intCropYearId
LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
	ON storageLocation.intCompanyLocationSubLocationId = bd.intStorageLocationId
LEFT JOIN tblICStorageLocation storageUnit
	ON storageUnit.intStorageLocationId = bd.intStorageUnitId
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityId = c.intCommodityId AND ProductType.strType = 'ProductType' AND ProductType.intCommodityAttributeId = bd.intProductTypeId
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityId = c.intCommodityId AND ProductLine.intCommodityProductLineId = bd.intProductLineId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityId = c.intCommodityId AND Grade.strType = 'Grade' AND Grade.intCommodityAttributeId = bd.intGradeId
--LEFT JOIN tblICCertification Certification ON Certification.intCertificationId = bd.intCertificationId
LEFT JOIN tblCTMTMPoint MTMPoint ON MTMPoint.intMTMPointId = bd.intMTMPointId
LEFT JOIN tblICCommodityAttribute CLASS
	ON CLASS.intCommodityAttributeId = i.intClassVarietyId
LEFT JOIN tblICCommodityAttribute REGION
	ON REGION.intCommodityAttributeId = i.intRegionId