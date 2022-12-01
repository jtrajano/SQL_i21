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
    BC.strBuyingCenterLocation,
    MU.strMixingUnitLocation,
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
    A.dtmExpiration,
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
    strFeedStock = Item.strShortName,
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
FROM tblMFBatch A
LEFT JOIN tblMFBatch B ON A.intParentBatchId = B.intBatchId
LEFT JOIN tblQMGardenMark Garden ON Garden.intGardenMarkId = B.intGardenMarkId
OUTER APPLY(
    SELECT TOP 1 intTINClearanceId, strTINNumber 
    FROM  tblQMTINClearance  
    WHERE intBatchId = A.intBatchId 
)TIN
OUTER APPLY(
    SELECT TOP 1 strLocationName 
    FROM tblSMCompanyLocation 
    WHERE intCompanyLocationId = A.intLocationId    
)CL
OUTER APPLY(
    SELECT TOP 1 strLocationName strBuyingCenterLocation
    FROM tblSMCompanyLocation 
    WHERE intCompanyLocationId = A.intBuyingCenterLocationId    
)BC
OUTER APPLY(
    SELECT TOP 1 strLocationName strMixingUnitLocation
    FROM tblSMCompanyLocation 
    WHERE intCompanyLocationId = A.intMixingUnitLocationId    
)MU
OUTER APPLY( 
    SELECT TOP 1 strSubLocationName FROM tblSMCompanyLocationSubLocation 
    WHERE A.intBrokerWarehouseId = intCompanyLocationSubLocationId
)BR
OUTER APPLY( 
    SELECT TOP 1 strSubLocationName FROM tblSMCompanyLocationSubLocation 
    WHERE A.intStorageLocationId = intCompanyLocationSubLocationId
)D
OUTER APPLY( 
    SELECT TOP 1 strName FROM tblICStorageLocation ICS
    WHERE A.intStorageUnitId = ICS.intStorageLocationId
)E
OUTER APPLY(
    SELECT TOP 1 strItemNo,strDescription, strShortName  FROM tblICItem WHERE intItemId = A.intTealingoItemId
)Item
OUTER APPLY(
	SELECT top 1 strUnitMeasure  FROM tblICUnitMeasure WHERE intUnitMeasureId= A.intItemUOMId
)UOM
OUTER APPLY(
	SELECT top 1 strUnitMeasure  FROM tblICUnitMeasure WHERE intUnitMeasureId= A.intWeightUOMId
)WUOM
OUTER APPLY(
	SELECT top 1 strUnitMeasure  FROM tblICUnitMeasure WHERE intUnitMeasureId= A.intPackageUOMId
)PUOM
OUTER APPLY(
    SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = A.intBrokerId
)Broker
OUTER APPLY(
    SELECT TOP 1 MF.intLotId, IC.strLotNumber
    FROM tblMFLotInventory MF JOIN tblICLot IC ON MF.intLotId = IC.intLotId 
    WHERE MF.intBatchId = A.intBatchId
)LOT
OUTER APPLY (
    SELECT TOP 1  strReasonCode FROM tblMFReasonCode WHERE intReasonCodeId = A.intReasonCodeId
)Reason