CREATE VIEW [dbo].[vyuQMCatalogueOverview]
AS 
SELECT S.intSampleId 
	, strSaleYear = SaleYear.strSaleYear
	, S.strSaleNumber 
	, strProducer = Producer.strName
	, strBuyingCenter = CompanyLocation.strLocationName
	, strSupplierCode = E.strName
	, strGardenMark = GardenMark.strGardenMark
	, strGradeCode = Grade.strDescription
	, strGradeGeoOrigin = GMO.strDescription
	, dblNoOfPackages = S.dblRepresentingQty
	, dblNetWeight = S.dblSampleQty
	, dblFOBPrice = Batch.dblLandedPrice
	, S.dblB1Price
	, I.strItemNo
	, strMonth = DATENAME(MONTH, S.dtmSaleDate)
	, S.dtmSaleDate
	, strCustomerMixingUnit = B.strBookDescription 
	, strChannel = MZ.strMarketZoneCode
	, strLotNo = S.strRepresentLotNumber
	, S.strChopNumber
	, strPONo = Batch.strERPPONumber
	, strParentBatch = Batch.strBatchId
	, strBuyingOrderNo = S.strBuyingOrderNo
	, CTT.strCatalogueType
	, dblNetWeightPerPackage = CASE WHEN ISNULL(S.dblRepresentingQty, 0) = 0 THEN 0 ELSE ISNULL(S.dblSampleQty, 0) / ISNULL(S.dblRepresentingQty, 0) END
	, strSubCluster = SC.strDescription 
	, S.ysnOrganic
	, strSustainability = PL.strDescription 
	, ysnCompanyBought = CASE WHEN ISNULL(S.dblB1QtyBought, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END	
	, strGroupNo = B.strBook 
	, strCompanyCode = PG.strName
	, dblB1QtyBought = S.dblB1QtyBought
	, strBuyer1 = B1.strName
	, strManufacturingLeafType = MLT.strDescription
	, dblCompanyCompetitor1TotalWt = CASE WHEN ISNULL(S.dblRepresentingQty, 0) = 0 THEN 0 ELSE ISNULL(S.dblB1QtyBought, 0) * ISNULL((ISNULL(S.dblSampleQty, 0) / ISNULL(S.dblRepresentingQty, 0)), 0) END
	, dblValue = ISNULL(S.dblSampleQty, 0) * ISNULL(S.dblB1Price, 0)
	, strBuyer2 = B2.strName
	, strTealingoGroup = Size.strBrandCode + SC.strDescription + VG.strName
	, strLeafSize = Size.strBrandCode
	, strCluster = certification.strCertificationName
	, strStyle = VG.strName
	, strTasterRemark = S.strComment
	, S.dblSupplierValuationPrice
	, strLastPrice = '0.0'
	, S.intCompanyLocationId
	, strBroker = Broker.strName
FROM tblQMSample S
LEFT JOIN tblQMSaleYear SaleYear ON SaleYear.intSaleYearId = S.intSaleYearId 
LEFT JOIN tblAPVendor VAN ON VAN.intEntityId = S.intEntityId
LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN tblQMGardenMark GardenMark ON GardenMark.intGardenMarkId = S.intGardenMarkId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = GardenMark.intProducerId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = S.intGradeId
LEFT JOIN tblICCommodityAttribute GMO ON GardenMark.intOriginId = GMO.intCommodityAttributeId AND GMO.strType = 'Origin'
LEFT JOIN tblMFBatch Batch ON Batch.intSampleId = S.intSampleId AND Batch.intLocationId =S.intLocationId 
LEFT JOIN tblEMEntity Broker ON Broker.intEntityId = Batch.intBrokerId
LEFT JOIN dbo.vyuICSearchItem I ON I.intItemId = S.intItemId
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = S.intMarketZoneId
LEFT JOIN tblQMCatalogueType CTT ON CTT.intCatalogueTypeId = S.intCatalogueTypeId 
LEFT JOIN tblICItem ITEM ON S.intItemId = ITEM.intItemId
LEFT JOIN tblICCommodityAttribute SC ON SC.intCommodityAttributeId = ITEM.intRegionId AND SC.strType = 'Region'
LEFT JOIN tblICCommodityProductLine PL ON PL.intCommodityProductLineId = S.intProductLineId
LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = S.intPurchaseGroupId
LEFT JOIN tblEMEntity B1 ON B1.intEntityId = S.intBuyer1Id
LEFT JOIN tblEMEntity B2 ON B2.intEntityId = S.intBuyer2Id
LEFT JOIN tblICCommodityAttribute MLT ON MLT.intCommodityAttributeId = S.intManufacturingLeafTypeId
LEFT JOIN tblICBrand Size ON Size.intBrandId = S.intBrandId
LEFT JOIN tblCTValuationGroup VG ON VG.intValuationGroupId = S.intValuationGroupId
LEFT JOIN tblICCertification certification ON certification.intCertificationId = ITEM.intCertificationId
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON S.intCompanyLocationId = CompanyLocation.intCompanyLocationId