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
	, intProductTypeId = ProductType.intCommodityAttributeId
	, strProductLine = ProductLine.strDescription
	, intProductLineId = ProductLine.intCommodityProductLineId
	, strGrade  = Grade.strDescription
	, intGradeId = Grade.intCommodityAttributeId
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
OUTER APPLY (
	SELECT TOP 1 
		intMarkExpiredMonthPositionId
	FROM tblRKCompanyPreference
) rkCP
INNER JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
	AND ((ISNULL(rkCP.intMarkExpiredMonthPositionId, 0) <> 1)
		  OR
		 (ISNULL(rkCP.intMarkExpiredMonthPositionId, 0) = 1
			AND ISNULL(fm1.ysnExpired, 0) = 0 
			AND ISNULL(fm1.dtmLastTradingDate, (SELECT currentDate FROM parameter_tbl)) >=  (SELECT currentDate FROM parameter_tbl))
		)
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
LEFT JOIN tblICCommodityAttribute ProductType 
	ON ProductType.intCommodityAttributeId = im.intProductTypeId
	AND ProductType.strType = 'ProductType' 
	AND ProductType.intCommodityId = im.intCommodityId 
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = im.intProductLineId
LEFT JOIN tblICCommodityAttribute Grade	
	ON Grade.intCommodityAttributeId = im.intGradeId
	AND Grade.strType = 'Grade' 
	AND Grade.intCommodityId = im.intCommodityId 
LEFT JOIN tblCTMTMPoint MTMPoint ON MTMPoint.intMTMPointId = cd.intMTMPointId
LEFT JOIN tblICCommodityAttribute CLASS
	ON CLASS.intCommodityAttributeId = im.intClassVarietyId
	AND CLASS.strType = 'Class'
	AND CLASS.intCommodityId = im.intCommodityId 
LEFT JOIN tblICCommodityAttribute REGION
	ON REGION.intCommodityAttributeId = im.intRegionId
	AND REGION.strType = 'Region'
	AND REGION.intCommodityId = im.intCommodityId 
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
	, intProductTypeId = ProductType.intCommodityAttributeId
	, strProductLine = ProductLine.strDescription
	, intProductLineId = ProductLine.intCommodityProductLineId
	, strGrade = Grade.strDescription
	, intGradeId = Grade.intCommodityAttributeId
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
LEFT JOIN tblICCommodityAttribute ProductType 
	ON ProductType.intCommodityAttributeId = im.intProductTypeId
	AND ProductType.strType = 'ProductType' 
	AND ProductType.intCommodityId = im.intCommodityId 
LEFT JOIN tblICCommodityProductLine ProductLine 
	ON ProductLine.intCommodityProductLineId = im.intProductLineId
LEFT JOIN tblICCommodityAttribute Grade 
	ON Grade.intCommodityAttributeId = im.intGradeId
	AND Grade.strType = 'Grade' 
	AND Grade.intCommodityId = im.intCommodityId 
LEFT JOIN tblCTMTMPoint MTMPoint ON MTMPoint.intMTMPointId = cd.intMTMPointId
LEFT JOIN tblICCommodityAttribute CLASS
	ON CLASS.intCommodityAttributeId = im.intClassVarietyId
	AND  CLASS.strType = 'Class'
	AND CLASS.intCommodityId = im.intCommodityId 
LEFT JOIN tblICCommodityAttribute REGION
	ON REGION.intCommodityAttributeId = im.intRegionId
	AND REGION.strType = 'Region'
	AND REGION.intCommodityId = im.intCommodityId 
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
	, strItemNo = iis.strItemNo
	, strDestination = NULL
	, strFutMarketName = NULL
	, strFutureMonth = NULL
	, strPeriodTo = NULL
	, strLocationName = iis.strLocationName
	, strMarketZoneCode = NULL
	, strCurrency = iis.strCurrency
	, strPricingType = NULL
	, strContractInventory = 'Inventory' COLLATE Latin1_General_CI_AS
	, strContractType = NULL
	, dblCashOrFuture = 0
	, dblBasisOrDiscount = 0
	, dblRatio = 0
	, strUnitMeasure = strStockUOM
	, intCommodityId = iis.intCommodityId
	, intItemId = iis.intItemId
	, intOriginId = iis.intOriginId
	, intFutureMarketId = NULL
	, intFutureMonthId = NULL
	, intLocationId = iis.intLocationId
	, intMarketZoneId = NULL
	, intCurrencyId = iis.intCurrencyId
	, intPricingTypeId = NULL
	, intContractTypeId = NULL
	, intUnitMeasureId = intStockUOMId
	, intConcurrencyId = 0
	, strMarketValuation = iis.strMarketValuation
	, ysnLicensed = ISNULL(iis.ysnLicensed, 0)
	, intBoardMonthId = NULL
	, strBoardMonth = NULL
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
	, strProductType = iis.strProductType
	, intProductTypeId = iis.intProductTypeId
	, strProductLine = iis.strProductLine
	, intProductLineId = iis.intProductLineId
	, strGrade = iis.strGrade
	, intGradeId = iis.intGradeId
	, strCertification = NULL
	, intCertificationId = NULL
	, strMTMPoint = NULL
	, intMTMPointId = NULL
	, strClass = iis.strClass
	, strRegion = iis.strRegion
FROM (
	SELECT it.intItemId
		, it.strItemNo
		, it.strLocationName
		, it.intLocationId
		, strCurrency = currency.strCurrency
		, intCurrencyId = currency.intCurrencyId
		, it.strMarketValuation
		, it.intOriginId
		, cl.ysnLicensed
		, c.intCommodityId
		, c.strCommodityCode
		, intStockUOMId = UOM.intUnitMeasureId
		, strStockUOM = UOM.strUnitMeasure
		, strProductType = ProductType.strDescription
		, intProductTypeId = ProductType.intCommodityAttributeId
		, strProductLine = ProductLine.strDescription
		, intProductLineId = ProductLine.intCommodityProductLineId
		, strGrade = Grade.strDescription
		, intGradeId = Grade.intCommodityAttributeId
		, strClass = CLASS.strDescription
		, strRegion = REGION.strDescription
	FROM vyuRKGetInventoryTransaction it
	INNER JOIN tblICItem i ON it.intItemId = i.intItemId
	INNER JOIN tblICCommodity c on i.intCommodityId =  c.intCommodityId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = i.intItemId AND ItemUOM.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = it.intLocationId
	LEFT JOIN (
		SELECT TOP 1 
			  strCurrency = c.strCurrency
			, intCurrencyId = SMC.intDefaultCurrencyId -- FUNCTIONAL
		FROM tblSMCompanyPreference SMC
		LEFT JOIN tblSMCurrency c
			ON c.intCurrencyID = SMC.intDefaultCurrencyId
	) currency
		ON 1 = 1
	LEFT JOIN tblICCommodityAttribute ProductType 
		ON ProductType.intCommodityAttributeId = i.intProductTypeId
		AND ProductType.strType = 'ProductType' 
		AND ProductType.intCommodityId = i.intCommodityId 
	LEFT JOIN tblICCommodityProductLine ProductLine 
		ON ProductLine.intCommodityProductLineId = i.intProductLineId
	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = i.intGradeId
		AND Grade.strType = 'Grade' 
		AND Grade.intCommodityId = i.intCommodityId 
	LEFT JOIN tblICCommodityAttribute CLASS
		ON CLASS.intCommodityAttributeId = i.intClassVarietyId
		AND  CLASS.strType = 'Class'
		AND CLASS.intCommodityId = i.intCommodityId 
	LEFT JOIN tblICCommodityAttribute REGION
		ON REGION.intCommodityAttributeId = i.intRegionId
		AND REGION.strType = 'Region'
		AND REGION.intCommodityId = i.intCommodityId 
	LEFT JOIN (
		SELECT TOP 1 
			  intRiskViewId
			, ysnM2MAllowLotControlledItems
		FROM tblRKCompanyPreference
	) rkcp
		ON 1 = 1
	WHERE dblQuantity > 0
		AND it.strLotTracking = CASE WHEN ISNULL(rkcp.intRiskViewId, 0) = 2 
										OR ISNULL(rkcp.ysnM2MAllowLotControlledItems, 0) = 1 
									THEN it.strLotTracking ELSE 'No' END
	GROUP BY it.intItemId
		, it.strItemNo
		, it.strLocationName
		, it.intLocationId
		, currency.strCurrency
		, currency.intCurrencyId
		, it.strMarketValuation
		, it.intOriginId
		, cl.ysnLicensed
		, c.intCommodityId
		, c.strCommodityCode
		, UOM.intUnitMeasureId
		, UOM.strUnitMeasure
		, ProductType.strDescription
		, ProductType.intCommodityAttributeId
		, ProductLine.strDescription
		, ProductLine.intCommodityProductLineId
		, Grade.strDescription
		, Grade.intCommodityAttributeId
		, CLASS.strDescription
		, REGION.strDescription
) iis