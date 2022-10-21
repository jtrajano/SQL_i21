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
    A.strVendorLotNumber,--unique
    A.intBuyingCenterLocationId, -- company id--unique
    strCompanyLocation = CL.strLocationName, -- company 
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
    A.ysnBoughtPrice,
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
    A.dblGrossWeight,
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
    A.dtmWarehouseArrival,
    A.intYearManufacture,
    A.strPackageSize,
    A.intPackageUOMId,
    A.dblTareWeight,
    A.strTaster,
    A.strFeedStock,
    A.strFlourideLimit,
    A.strLocalAuctionNumber,
    A.strPOStatus,
    A.strProductionSite,
    A.strReserveMU,
    A.strQualityComments,
    A.strRareEarth,
    A.strFreightAgent,
	A.strSealNumber,
	A.strContainerType,
	A.strVoyage,
	A.strVessel,
    A.intConcurrencyId
FROM tblMFBatch A
LEFT JOIN tblMFBatch B ON A.intParentBatchId = B.intBatchId
OUTER APPLY(
    SELECT TOP 1 intTINClearanceId, strTINNumber 
    FROM  tblQMTINClearance  
    WHERE intBatchId = A.intBatchId 
)TIN
OUTER APPLY(
    SELECT TOP 1 strLocationName 
    FROM tblSMCompanyLocation 
    WHERE intCompanyLocationId = A.intBuyingCenterLocationId    
)CL
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
