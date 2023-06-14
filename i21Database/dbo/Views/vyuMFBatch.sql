CREATE VIEW dbo.vyuMFBatch   
AS  
SELECT
    A.intBatchId,--unique
    A.strBatchId,--unique
    A.intSales,--unique
    A.intSalesYear,--unique
    A.dtmSalesDate,--unique
    A.strTeaType,--unique
    A.intBrokerId,--unique
    strBroker = Broker.strName,
    A.strVendorLotNumber,--unique
    A.intBuyingCenterLocationId, -- company id--unique
    strCompanyLocation = CL.strLocationName, -- company 
    BC.strLocationName strBuyingCenterLocation,
    MU.strLocationName strMixingUnitLocation,
    A.intStorageLocationId, --- sub location id
    strStorageLocation = D.strSubLocationName, -- sub location
    A.intStorageUnitId, --- ic location
    strStorageUnit = E.strName, -- ic location
    A.intParentBatchId, -- parent batch
    strParentBatchId = B.strBatchId, -- parent batch
    A.intBrokerWarehouseId,
    strBrokerWarehouse = BR.strSubLocationName,
    TIN.strTINNumber, -- tin clearance
    TIN.intTINClearanceId, -- tin clearance
    A.intInventoryReceiptId,
    A.intSampleId,
    A.intContractDetailId,
    A.str3PLStatus,
    A.strSupplierReference,
    A.strAirwayBillCode,
    A.strAWBSampleReceived,
    A.strAWBSampleReference,
    A.dblBasePrice,
    A.ysnBoughtAsReserved,
    A.dblBoughtPrice,
    A.dblBulkDensity,
    A.strBuyingOrderNumber,
    A.intSubBookId,
    A.strContainerNumber,
    A.intCurrencyId,
    A.dtmProductionBatch,
    A.dtmTeaAvailableFrom,
    A.strDustContent,
    A.ysnEUCompliant,
    A.strTBOEvaluatorCode,
    A.strEvaluatorRemarks,
    Item.dtmExpiration,
    A.intFromPortId,
    A.dblGrossWeight, -- = dblTotalQuantity + dblTareWeight,
    A.dtmInitialBuy,
    A.dblWeightPerUnit,
    A.dblLandedPrice,
    A.strLeafCategory,
    A.strLeafManufacturingType,
    A.strLeafSize,
    A.strLeafStyle,
    A.intMixingUnitLocationId,
    A.dblPackagesBought,
    A.intItemUOMId,
	A.intWeightUOMId,
    A.strTeaOrigin,
    A.intOriginalItemId,
    A.dblPackagesPerPallet,
    A.strPlant,
    A.dblTotalQuantity,
    A.strSampleBoxNumber,
    A.dblSellingPrice,
    A.dtmStock,
    A.strSubChannel,
    A.ysnStrategic,
    A.strTeaLingoSubCluster,
    A.dtmSupplierPreInvoiceDate,
    A.strSustainability,
    A.strTasterComments,
    A.dblTeaAppearance,
    A.strTeaBuyingOffice,
    A.strTeaColour,
    A.strTeaGardenChopInvoiceNumber,
    A.intGardenMarkId,
    A.strTeaGroup,
    A.dblTeaHue,
    A.dblTeaIntensity,
    A.strLeafGrade,
    A.dblTeaMoisture,
    A.dblTeaMouthFeel,
    A.ysnTeaOrganic,
    A.dblTeaTaste,
    A.dblTeaVolume,
    A.intTealingoItemId,
    Item.strItemNo,
    strItemDescription = Item.strDescription,
    A.dtmWarehouseArrival,
    A.intYearManufacture,
    A.strPackageSize,
    A.intPackageUOMId,
    A.dblTareWeight,
    A.strTaster,
    strFeedStock = OriginalItem.strShortName,
    A.strFlourideLimit,
    A.strLocalAuctionNumber,
    A.strPOStatus,
    A.strProductionSite,
    A.strReserveMU,
    A.strQualityComments,
    A.strRareEarth,
    A.strERPPONumber,
    A.strFreightAgent,
	A.strSealNumber,
	A.strContainerType,
	A.strVoyage,
	A.strVessel,
    A.intReasonCodeId,
    A.strNotes,
    A.dtmSplit,
    A.intConcurrencyId,
	strItemUOM = UOM.strUnitMeasure,
	strWeightUOM = WUOM.strUnitMeasure,
	strPackageUOM = PUOM.strUnitMeasure,
    Reason.strReasonCode,
    LOT.strLotNumber,
    LOT.intLotId,
    A.intLocationId,
    Garden.strGardenMark
    ,A.dblOriginalTeaTaste  
	,A.dblOriginalTeaHue 
	,A.dblOriginalTeaIntensity
	,A.dblOriginalTeaMouthfeel
	,A.dblOriginalTeaAppearance
	,A.dblOriginalTeaVolume
	,A.dblOriginalTeaMoisture
    ,Channel.strMarketZoneCode
    ,OriginalItem.strItemNo strOriginalItem
    ,SM.strCurrency
	,A.strERPPOLineNo
    ,C.intBatchId intChildBatchId
	,C.strBatchId strChildBatchId
    ,A.strBOLNo
	,strContractNumber=CH.strContractNumber
	,intContractSeq=CD.intContractSeq
	,strSampleTypeName=ST.strSampleTypeName
    ,strSampleNumber = S.strSampleNumber
	,strOriginalFeedStock = OriginalItem.strShortName
	,dtmShippingDate=B.dtmShippingDate
	,strERPPONumber2= A.strERPPONumber2
	,strVendor=E1.strName
	,strFines=A.strFines
	,dtmPOCreated=A.dtmPOCreated
	,strIBDNo=A.strIBDNo
	,dtmEtaPol=CD.dtmEtaPol
FROM tblMFBatch A
LEFT JOIN tblMFBatch B ON A.intParentBatchId = B.intBatchId
LEFT JOIN tblQMGardenMark Garden ON Garden.intGardenMarkId = A.intGardenMarkId
LEFT JOIN tblARMarketZone Channel ON Channel.intMarketZoneId = A.intMarketZoneId
LEFT JOIN tblICItem OriginalItem ON OriginalItem.intItemId = A.intOriginalItemId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intLocationId
LEFT JOIN tblSMCompanyLocation BC ON BC.intCompanyLocationId = A.intBuyingCenterLocationId
LEFT JOIN tblSMCompanyLocation MU ON MU.intCompanyLocationId = A.intMixingUnitLocationId
LEFT JOIN tblSMCompanyLocationSubLocation BR ON BR.intCompanyLocationSubLocationId = A.intBrokerWarehouseId
LEFT JOIN tblSMCompanyLocationSubLocation D ON D.intCompanyLocationSubLocationId = A.intStorageLocationId
LEFT JOIN tblICStorageLocation E ON A.intStorageUnitId = E.intStorageLocationId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId= A.intItemUOMId
LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId= A.intWeightUOMId
LEFT JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId= A.intPackageUOMId
LEFT JOIN tblEMEntity Broker ON Broker.intEntityId = A.intBrokerId
LEFT JOIN tblMFReasonCode Reason ON Reason.intReasonCodeId = A.intReasonCodeId
LEFT JOIN tblSMCurrency SM ON SM.intCurrencyID= A.intCurrencyId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = A.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblQMSample S ON S.intSampleId = A.intSampleId
LEFT JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = A.intSupplierId
OUTER APPLY(
    SELECT TOP 1 intTINClearanceId, strTINNumber 
    FROM  tblQMTINClearance  
    WHERE intBatchId = A.intBatchId 
)TIN
OUTER APPLY(
    SELECT TOP 1 strItemNo,strDescription, strShortName,
    CASE WHEN ISNULL(intLifeTime,0) > 0 AND A.dtmProductionBatch IS NOT NULL
    THEN
    CASE 
        WHEN  strLifeTimeType = 'Years' THEN DATEADD( YEAR, intLifeTime, A.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Months' THEN DATEADD( MONTH, intLifeTime, A.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Days' THEN DATEADD( DAY, intLifeTime, A.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Hours' THEN DATEADD( HOUR, intLifeTime, A.dtmProductionBatch)
        WHEN  strLifeTimeType = 'Minutes' THEN DATEADD( MINUTE, intLifeTime, A.dtmProductionBatch)
        ELSE NULL END
    ELSE 
    NULL 
    END dtmExpiration
    FROM tblICItem WHERE intItemId = A.intTealingoItemId
)Item
OUTER APPLY(
    SELECT TOP 1 MF.intLotId, IC.strLotNumber
    FROM tblMFLotInventory MF JOIN tblICLot IC ON MF.intLotId = IC.intLotId 
    WHERE MF.intBatchId = A.intBatchId
)LOT
OUTER APPLY(
    SELECT TOP 1 intBatchId, strBatchId FROM
    tblMFBatch WHERE intParentBatchId  = A.intBatchId 
)C