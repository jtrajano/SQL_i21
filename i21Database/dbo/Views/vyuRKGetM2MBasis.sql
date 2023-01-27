CREATE VIEW [dbo].[vyuRKGetM2MBasis]
AS

WITH
parameter_tbl
AS 
( 
	SELECT GETDATE() currentDate
)

SELECT DISTINCT strCommodityCode
	, im.strItemNo
	, strOriginDest = ca.strDescription
	, fm.strFutMarketName
	, fm1.strFutureMonth
	, strPeriodTo = RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
	, strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END)
	, strPricingType
	, strContractInventory = 'Contract' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END)
	, ch.intCommodityId
	, cd.intItemId
	, intOriginId = i.intOriginId
	, cd.intFutureMarketId
	, cd.intFutureMonthId
	, cd.intCompanyLocationId
	, mz.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END)
	, cd.intPricingTypeId
	, ct.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END)
	, intConcurrencyId = 0
	, i.strMarketValuation
	, ysnLicensed = ISNULL(cl.ysnLicensed, 0)
	, intBoardMonthId = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN cd.intFutureMonthId ELSE NULL END
	, strBoardMonth = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN fm1.strFutureMonth ELSE NULL END
	, strOriginPort =  CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.strOriginPort
							ELSE originPort.strCity
							END
	, intOriginPortId = CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.intOriginPortId
							ELSE originPort.intCityId
							END
	, strDestinationPort = CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.strDestinationPort
							ELSE destinationPort.strCity
							END
	, intDestinationPortId =  CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.intDestinationPortId
							ELSE destinationPort.intCityId
							END
	, strCropYear = cropYear.strCropYear
	, intCropYearId = cropYear.intCropYearId
	, strStorageLocation = CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.strStorageLocation
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.strStorageLocation
							ELSE 
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
								THEN loadShipmentWarehouse.strStorageLocation
								ELSE storageLocation.strSubLocationName
								END
							END 
	, intStorageLocationId = CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.intStorageLocationId
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.intStorageLocationId
							ELSE 
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
								THEN loadShipmentWarehouse.intStorageLocationId
								ELSE storageLocation.intCompanyLocationSubLocationId
								END
							END
	, strStorageUnit =  CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.strStorageUnit
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.strStorageUnit
							ELSE 
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
									THEN loadShipmentWarehouse.strStorageUnit
									ELSE storageUnit.strName
									END
							END
	, intStorageUnitId = CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.intStorageUnitId
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.intStorageUnitId
							ELSE
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
								THEN loadShipmentWarehouse.intStorageUnitId
								ELSE storageUnit.intStorageLocationId
								END
							END
	, strProductType = ProductType.strDescription
	, im.intProductTypeId
	, strProductLine = ProductLine.strDescription
	, im.intProductLineId
	, strGrade  = Grade.strDescription
	, im.intGradeId
	--, strCertification = Certification.strCertificationName
	, strCertification = CC.strContractCertifications
	, im.intCertificationId
	, MTMPoint.strMTMPoint
	, cd.intMTMPointId
	, strClass = CLASS.strDescription
	, strRegion = REGION.strDescription
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
LEFT JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
LEFT JOIN tblICItem im ON im.intItemId = cd.intItemId
LEFT JOIN tblICItem i ON i.intItemId = cd.intItemId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
INNER JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
	AND ISNULL(fm1.ysnExpired, 0) = 0 
	AND ISNULL(fm1.dtmLastTradingDate, (SELECT currentDate FROM parameter_tbl)) >=  (SELECT currentDate FROM parameter_tbl)
LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
CROSS APPLY (SELECT TOP 1 ysnUseBoardMonth = ISNULL(ysnUseBoardMonth, 0) FROM tblRKCompanyPreference) CP
LEFT JOIN tblSMCity originPort
	ON originPort.intCityId = cd.intLoadingPortId
LEFT JOIN tblSMCity destinationPort
	ON destinationPort.intCityId = cd.intDestinationPortId
LEFT JOIN tblCTCropYear cropYear
	ON cropYear.intCropYearId = ch.intCropYearId
LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
	ON storageLocation.intCompanyLocationSubLocationId = cd.intSubLocationId
LEFT JOIN tblICStorageLocation storageUnit
	ON storageUnit.intStorageLocationId = cd.intStorageLocationId
OUTER APPLY (
		SELECT strShipmentStatus = ISNULL(NULLIF(ctShipStatus.strShipmentStatus, ''), 'Open')  
		FROM  dbo.fnCTGetShipmentStatus(cd.intContractDetailId) ctShipStatus 
	) ctShipmentStatus
OUTER APPLY (
	SELECT TOP 1 
		  LD.intLoadId
		, intStorageLocationId = loadStorageLoc.intCompanyLocationSubLocationId
		, strStorageLocation = loadStorageLoc.strSubLocationName
		, intStorageUnitId = loadStorageUnit.intStorageLocationId
		, strStorageUnit = loadStorageUnit.strName
		, intOriginPortId = LGLoadOrigin.intCityId
		, strOriginPort = LGLoadOrigin.strCity
		, intDestinationPortId = LGLoadDestination.intCityId
		, strDestinationPort = LGLoadDestination.strCity
		, LGLoad.intTransUsedBy
	FROM tblLGLoadDetail LD
	LEFT JOIN tblLGLoad LGLoad
		ON LGLoad.intLoadId = LD.intLoadId 
	LEFT JOIN tblLGLoadWarehouse warehouse
		ON warehouse.intLoadId = LD.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation loadStorageLoc
		ON loadStorageLoc.intCompanyLocationSubLocationId = warehouse.intSubLocationId
	LEFT JOIN tblICStorageLocation loadStorageUnit
		ON loadStorageUnit.intStorageLocationId = warehouse.intStorageLocationId
	LEFT JOIN tblSMCity LGLoadOrigin
		ON LGLoadOrigin.strCity = LGLoad.strOriginPort
	LEFT JOIN tblSMCity LGLoadDestination
		ON LGLoadDestination.strCity = LGLoad.strDestinationPort
	WHERE   ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered') -- LOAD SHIPMENT AFLOAT
	-- WILL ONLY USE LOAD SHIPMENT VALUES WHEN TRANSPORT MODE = OCEAN VESSEL (2)
	-- THIS IS DUE TO VESSEL TAB AND WAREHOUSE TAB IS ONLY DISPLAYED ON LOAD SHIPMENT WHEN TRANSPORT MODE = OCEAN VESSEL (2)
	AND		LGLoad.intTransportationMode = 2 
	AND		LGLoad.intShipmentType = 1 -- Shipment Only
	AND		ISNULL(LD.intSContractDetailId, LD.intPContractDetailId) = cd.intContractDetailId 
) loadShipmentWarehouse
OUTER APPLY (
	SELECT TOP 1 
		  receiptItem.intInventoryReceiptId
		, intStorageLocationId = receiptStorageLoc.intCompanyLocationSubLocationId
		, strStorageLocation = receiptStorageLoc.strSubLocationName
		, intStorageUnitId = receiptStorageUnit.intStorageLocationId
		, strStorageUnit = receiptStorageUnit.strName
	FROM tblICInventoryReceiptItem receiptItem
	LEFT JOIN tblICInventoryReceipt receipt
		ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocationSubLocation receiptStorageLoc
		ON receiptStorageLoc.intCompanyLocationSubLocationId = receiptItem.intSubLocationId
	LEFT JOIN tblICStorageLocation receiptStorageUnit
		ON receiptStorageUnit.intStorageLocationId = receiptItem.intStorageLocationId
	WHERE ch.intContractTypeId = 1 -- PURCHASE CONTRACTS ONLY
	AND receiptItem.intContractDetailId = cd.intContractDetailId
	AND receipt.ysnPosted = 1
) receiptWarehouse
OUTER APPLY (
	SELECT TOP 1
		  invShipment.intInventoryShipmentId
		, intStorageLocationId = invShipStorageLoc.intCompanyLocationSubLocationId
		, strStorageLocation = invShipStorageLoc.strSubLocationName
		, intStorageUnitId = invShipStorageUnit.intStorageLocationId
		, strStorageUnit = invShipStorageUnit.strName
	FROM tblICInventoryShipmentItem invShipment
	LEFT JOIN tblICInventoryShipment shipment
		ON shipment.intInventoryShipmentId = invShipment.intInventoryShipmentId
	LEFT JOIN tblSMCompanyLocationSubLocation invShipStorageLoc
		ON invShipStorageLoc.intCompanyLocationSubLocationId = invShipment.intSubLocationId
	LEFT JOIN tblICStorageLocation invShipStorageUnit
		ON invShipStorageUnit.intStorageLocationId = invShipment.intStorageLocationId
	WHERE ch.intContractTypeId = 2 -- SALE CONTRACTS ONLY
	AND invShipment.intLineNo = cd.intContractDetailId
	AND shipment.ysnPosted = 1
) invShipWarehouse
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = im.intProductTypeId
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = im.intProductLineId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = im.intGradeId
--LEFT JOIN tblICCertification Certification ON Certification.intCertificationId = im.intCertificationId
LEFT JOIN tblCTMTMPoint MTMPoint ON MTMPoint.intMTMPointId = cd.intMTMPointId
LEFT JOIN tblICCommodityAttribute CLASS
	ON CLASS.intCommodityAttributeId = im.intClassVarietyId
LEFT JOIN tblICCommodityAttribute REGION
	ON REGION.intCommodityAttributeId = im.intRegionId
OUTER APPLY (
		SELECT strContractCertifications = (LTRIM(STUFF((
			SELECT ', ' + ICC.strCertificationName
			FROM tblCTContractCertification CTC
			JOIN tblICCertification ICC
				ON ICC.intCertificationId = CTC.intCertificationId
			WHERE CTC.intContractDetailId = cd.intContractDetailId
			ORDER BY ICC.strCertificationName
			FOR XML PATH('')), 1, 1, ''))
		) COLLATE Latin1_General_CI_AS
) CC
WHERE dblBalance > 0 AND cd.intPricingTypeId NOT IN (5,6) AND cd.intContractStatusId <> 3	

UNION SELECT DISTINCT strCommodityCode
	, im.strItemNo
	, strOriginDest = ca.strDescription
	, fm.strFutMarketName
	, fm1.strFutureMonth
	, strPeriodTo = RIGHT(CONVERT(VARCHAR(11),cd.dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
	, strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END)
	, strPricingType
	, strContractInventory = 'Contract' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END)
	, ch.intCommodityId
	, cd.intItemId
	, intOriginId = i.intOriginId
	, fmm.intFutureMarketId
	, cd.intFutureMonthId
	, cd.intCompanyLocationId
	, mz.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END)
	, cd.intPricingTypeId
	, ct.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END)
	, intConcurrencyId = 0
	, i.strMarketValuation
	, ysnLicensed = ISNULL(cl.ysnLicensed, 0)
	, intBoardMonthId = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN cd.intFutureMonthId ELSE NULL END
	, strBoardMonth = CASE WHEN CP.ysnUseBoardMonth <> 0 THEN fm1.strFutureMonth ELSE NULL END	
	, strOriginPort =  CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.strOriginPort
							ELSE originPort.strCity
							END
	, intOriginPortId = CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.intOriginPortId
							ELSE originPort.intCityId
							END
	, strDestinationPort = CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.strDestinationPort
							ELSE destinationPort.strCity
							END
	, intDestinationPortId =  CASE WHEN ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
							THEN loadShipmentWarehouse.intDestinationPortId
							ELSE destinationPort.intCityId
							END
	, strCropYear = cropYear.strCropYear
	, intCropYearId = cropYear.intCropYearId
	, strStorageLocation = CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.strStorageLocation
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.strStorageLocation
							ELSE 
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
								THEN loadShipmentWarehouse.strStorageLocation
								ELSE storageLocation.strSubLocationName
								END
							END 
	, intStorageLocationId = CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.intStorageLocationId
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.intStorageLocationId
							ELSE 
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
								THEN loadShipmentWarehouse.intStorageLocationId
								ELSE storageLocation.intCompanyLocationSubLocationId
								END
							END
	, strStorageUnit =  CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.strStorageUnit
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.strStorageUnit
							ELSE 
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
									THEN loadShipmentWarehouse.strStorageUnit
									ELSE storageUnit.strName
									END
							END
	, intStorageUnitId = CASE WHEN ISNULL(receiptWarehouse.intInventoryReceiptId, 0) <> 0 THEN receiptWarehouse.intStorageUnitId
							WHEN ISNULL(invShipWarehouse.intInventoryShipmentId, 0) <> 0 THEN invShipWarehouse.intStorageUnitId
							ELSE
								CASE WHEN loadShipmentWarehouse.intTransUsedBy = 1 AND ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered')
								THEN loadShipmentWarehouse.intStorageUnitId
								ELSE storageUnit.intStorageLocationId
								END
							END
	, strProductType = ProductType.strDescription
	, im.intProductTypeId
	, strProductLine = ProductLine.strDescription
	, im.intProductLineId
	, strGrade  = Grade.strDescription
	, im.intGradeId
	--, strCertification = Certification.strCertificationName
	, strCertification = CC.strContractCertifications
	, im.intCertificationId
	, MTMPoint.strMTMPoint
	, cd.intMTMPointId
	, strClass = CLASS.strDescription
	, strRegion = REGION.strDescription
FROM tblCTContractHeader ch
JOIN tblCTContractDetail  cd ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
LEFT JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
LEFT JOIN tblICItem im ON im.intItemId = cd.intItemId
LEFT JOIN tblICItem i ON i.intItemId = cd.intItemId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = i.intOriginId
LEFT JOIN tblRKCommodityMarketMapping fmm ON fmm.intCommodityId = ch.intCommodityId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = fmm.intFutureMarketId
LEFT JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
CROSS APPLY (SELECT TOP 1 ysnUseBoardMonth = ISNULL(ysnUseBoardMonth, 0) FROM tblRKCompanyPreference) CP
LEFT JOIN tblSMCity originPort
	ON originPort.intCityId = cd.intLoadingPortId
LEFT JOIN tblSMCity destinationPort
	ON destinationPort.intCityId = cd.intDestinationPortId
LEFT JOIN tblCTCropYear cropYear
	ON cropYear.intCropYearId = ch.intCropYearId
LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
	ON storageLocation.intCompanyLocationSubLocationId = cd.intSubLocationId
LEFT JOIN tblICStorageLocation storageUnit
	ON storageUnit.intStorageLocationId = cd.intStorageLocationId
OUTER APPLY (
		SELECT strShipmentStatus = ISNULL(NULLIF(ctShipStatus.strShipmentStatus, ''), 'Open')  
		FROM  dbo.fnCTGetShipmentStatus(cd.intContractDetailId) ctShipStatus 
	) ctShipmentStatus
OUTER APPLY (
	SELECT TOP 1 
		  LD.intLoadId
		, intStorageLocationId = loadStorageLoc.intCompanyLocationSubLocationId
		, strStorageLocation = loadStorageLoc.strSubLocationName
		, intStorageUnitId = loadStorageUnit.intStorageLocationId
		, strStorageUnit = loadStorageUnit.strName
		, intOriginPortId = LGLoadOrigin.intCityId
		, strOriginPort = LGLoadOrigin.strCity
		, intDestinationPortId = LGLoadDestination.intCityId
		, strDestinationPort = LGLoadDestination.strCity
		, LGLoad.intTransUsedBy
	FROM tblLGLoadDetail LD
	LEFT JOIN tblLGLoad LGLoad
		ON LGLoad.intLoadId = LD.intLoadId 
	LEFT JOIN tblLGLoadWarehouse warehouse
		ON warehouse.intLoadId = LD.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation loadStorageLoc
		ON loadStorageLoc.intCompanyLocationSubLocationId = warehouse.intSubLocationId
	LEFT JOIN tblICStorageLocation loadStorageUnit
		ON loadStorageUnit.intStorageLocationId = warehouse.intStorageLocationId
	LEFT JOIN tblSMCity LGLoadOrigin
		ON LGLoadOrigin.strCity = LGLoad.strOriginPort
	LEFT JOIN tblSMCity LGLoadDestination
		ON LGLoadOrigin.strCity = LGLoad.strDestinationPort
	WHERE   ctShipmentStatus.strShipmentStatus IN ('Inbound Transit', 'Outbound Transit', 'Dispatched', 'Delivered') -- LOAD SHIPMENT AFLOAT
	-- WILL ONLY USE LOAD SHIPMENT VALUES WHEN TRANSPORT MODE = OCEAN VESSEL (2)
	-- THIS IS DUE TO VESSEL TAB AND WAREHOUSE TAB IS ONLY DISPLAYED ON LOAD SHIPMENT WHEN TRANSPORT MODE = OCEAN VESSEL (2)
	AND		LGLoad.intTransportationMode = 2 
	AND		LGLoad.intShipmentType = 1 -- Shipment Only
	AND		ISNULL(LD.intSContractDetailId, LD.intPContractDetailId) = cd.intContractDetailId 
) loadShipmentWarehouse
OUTER APPLY (
	SELECT TOP 1 
		  receiptItem.intInventoryReceiptId
		, intStorageLocationId = receiptStorageLoc.intCompanyLocationSubLocationId
		, strStorageLocation = receiptStorageLoc.strSubLocationName
		, intStorageUnitId = receiptStorageUnit.intStorageLocationId
		, strStorageUnit = receiptStorageUnit.strName
	FROM tblICInventoryReceiptItem receiptItem
	LEFT JOIN tblICInventoryReceipt receipt
		ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocationSubLocation receiptStorageLoc
		ON receiptStorageLoc.intCompanyLocationSubLocationId = receiptItem.intSubLocationId
	LEFT JOIN tblICStorageLocation receiptStorageUnit
		ON receiptStorageUnit.intStorageLocationId = receiptItem.intStorageLocationId
	WHERE ch.intContractTypeId = 1 -- PURCHASE CONTRACTS ONLY
	AND receiptItem.intContractDetailId = cd.intContractDetailId
	AND receipt.ysnPosted = 1
) receiptWarehouse
OUTER APPLY (
	SELECT TOP 1
		  invShipment.intInventoryShipmentId
		, intStorageLocationId = invShipStorageLoc.intCompanyLocationSubLocationId
		, strStorageLocation = invShipStorageLoc.strSubLocationName
		, intStorageUnitId = invShipStorageUnit.intStorageLocationId
		, strStorageUnit = invShipStorageUnit.strName
	FROM tblICInventoryShipmentItem invShipment
	LEFT JOIN tblICInventoryShipment shipment
		ON shipment.intInventoryShipmentId = invShipment.intInventoryShipmentId
	LEFT JOIN tblSMCompanyLocationSubLocation invShipStorageLoc
		ON invShipStorageLoc.intCompanyLocationSubLocationId = invShipment.intSubLocationId
	LEFT JOIN tblICStorageLocation invShipStorageUnit
		ON invShipStorageUnit.intStorageLocationId = invShipment.intStorageLocationId
	WHERE ch.intContractTypeId = 2 -- SALE CONTRACTS ONLY
	AND invShipment.intLineNo = cd.intContractDetailId
	AND shipment.ysnPosted = 1
) invShipWarehouse
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = im.intProductTypeId
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = im.intProductLineId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = im.intGradeId
--LEFT JOIN tblICCertification Certification ON Certification.intCertificationId = im.intCertificationId
LEFT JOIN tblCTMTMPoint MTMPoint ON MTMPoint.intMTMPointId = cd.intMTMPointId
LEFT JOIN tblICCommodityAttribute CLASS
	ON CLASS.intCommodityAttributeId = im.intClassVarietyId
LEFT JOIN tblICCommodityAttribute REGION
	ON REGION.intCommodityAttributeId = im.intRegionId
OUTER APPLY (
	SELECT strContractCertifications = (LTRIM(STUFF((
		SELECT ', ' + ICC.strCertificationName
		FROM tblCTContractCertification CTC
		JOIN tblICCertification ICC
			ON ICC.intCertificationId = CTC.intCertificationId
		WHERE CTC.intContractDetailId = cd.intContractDetailId
		ORDER BY ICC.strCertificationName
		FOR XML PATH('')), 1, 1, ''))
	) COLLATE Latin1_General_CI_AS
) CC
WHERE cd.intPricingTypeId IN (5,6) AND cd.intContractStatusId <> 3

UNION SELECT DISTINCT iis.strCommodityCode
	, iis.strItemNo
	, strDestination = NULL
	, strFutMarketName
	, strFutureMonth
	, strPeriodTo = NULL
	, iis.strLocationName
	, strMarketZoneCode
	, strCurrency = (CASE WHEN ISNULL(strFMCurrency,'') = '' THEN iis.strCurrency ELSE strFMCurrency END)
	, strPricingType
	, strContractInventory = 'Inventory' COLLATE Latin1_General_CI_AS
	, strContractType
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = (CASE WHEN ISNULL(strFMUOM,'') = '' THEN (CASE WHEN ISNULL(ct.strUOM, '') = '' THEN strStockUOM ELSE ct.strUOM END) ELSE strFMUOM END)
	, iis.intCommodityId
	, iis.intItemId
	, intOriginId = iis.intOriginId
	, ct.intFutureMarketId
	, ct.intFutureMonthId
	, iis.intLocationId
	, ct.intMarketZoneId
	, intCurrencyId = (CASE WHEN ISNULL(intFMCurrencyId,'') = '' THEN iis.intCurrencyId ELSE intFMCurrencyId END)
	, ct.intPricingTypeId
	, ct.intContractTypeId
	, intUnitMeasureId = (CASE WHEN ISNULL(strFMUOM,'') = '' THEN (CASE WHEN ISNULL(intUOMId, '') = '' THEN intStockUOMId ELSE intUOMId END) ELSE intFMUOMId END)
	, intConcurrencyId = 0
	, iis.strMarketValuation
	, ysnLicensed = ISNULL(iis.ysnLicensed, 0)
	, intBoardMonthId = NULL
	, strBoardMonth = NULL
	, strOriginPort
	, intOriginPortId
	, strDestinationPort 
	, intDestinationPortId
	, strCropYear 
	, intCropYearId
	, strStorageLocation 
	, intStorageLocationId
	, strStorageUnit 
	, intStorageUnitId
	, strProductType 
	, intProductTypeId 
	, strProductLine 
	, intProductLineId
	, strGrade 
	, intGradeId
	, strCertification
	, intCertificationId
	, strMTMPoint
	, intMTMPointId
	, strClass
	, strRegion
FROM (
	SELECT it.intItemId
		, it.strItemNo
		, it.strLocationName
		, it.intLocationId
		, it.strCurrency
		, it.intCurrencyId
		, it.strMarketValuation
		, it.intOriginId
		, cl.ysnLicensed
		, c.intCommodityId
		, c.strCommodityCode
		, intStockUOMId = UOM.intUnitMeasureId
		, strStockUOM = UOM.strUnitMeasure
		, strClass = CLASS.strDescription
		, strRegion = REGION.strDescription
	FROM vyuRKGetInventoryTransaction it
	INNER JOIN tblICItem i ON it.intItemId = i.intItemId
	INNER JOIN tblICCommodity c on i.intCommodityId =  c.intCommodityId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = i.intItemId AND ItemUOM.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = it.intLocationId
	LEFT JOIN tblICCommodityAttribute CLASS
		ON CLASS.intCommodityAttributeId = i.intClassVarietyId
	LEFT JOIN tblICCommodityAttribute REGION
		ON REGION.intCommodityAttributeId = i.intRegionId
	WHERE dblQuantity > 0
		AND it.strLotTracking = (CASE WHEN (SELECT TOP 1 intRiskViewId FROM tblRKCompanyPreference) = 2 THEN it.strLotTracking ELSE 'No' END)) iis
OUTER APPLY (
	SELECT DISTINCT TOP 1 cd.intItemId
		, cd.intCompanyLocationId
		, fm.intFutureMarketId
		, fmon.intFutureMonthId
		, cd.intItemUOMId
		, ch.intCommodityId
		, c.strCommodityCode
		, intMarketZoneId = NULL
		, intContractTypeId = NULL
		, strContractType = NULL 
		, pt.intPricingTypeId
		, pt.strPricingType
		, cd.intCurrencyId
		, fm.strFutMarketName
		, strFutureMonth
		, strMarketZoneCode
		, strFMCurrency = muc.strCurrency
		, intFMCurrencyId = muc.intCurrencyID
		, intFMUOMId = mum.intUnitMeasureId
		, strFMUOM = mum.strUnitMeasure
		, intUOMId = um.intUnitMeasureId
		, strUOM = um.strUnitMeasure
		, strOriginPort = NULL
		, intOriginPortId = NULL
		, strDestinationPort = NULL
		, intDestinationPortId = NULL
		, strCropYear = NULL
		, intCropYearId = NULL
		, strStorageLocation = NULL
		, intStorageLocationId = NULL
		, strStorageUnit = NULL
		, intStorageUnitId = NULL
		, strProductType = NULL
		, intProductTypeId = NULL
		, strProductLine = NULL
		, intProductLineId = NULL
		, strGrade  = NULL
		, intGradeId = NULL
		, strCertification = NULL
		, intCertificationId = NULL
		, strMTMPoint = NULL
		, intMTMPointId = NULL
	FROM tblCTContractDetail cd
	JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
	JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
	JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
	JOIN tblRKCommodityMarketMapping mm ON mm.intCommodityId = c.intCommodityId
	LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = mm.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth fmon ON fmon.intFutureMonthId = cd.intFutureMonthId
	LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
	LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
	LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
	LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
	LEFT JOIN tblARMarketZone mz ON	mz.intMarketZoneId = cd.intMarketZoneId
	WHERE cd.intItemId = iis.intItemId
) ct