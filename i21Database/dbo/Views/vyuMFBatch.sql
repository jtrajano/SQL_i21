CREATE VIEW vyuMFBatch   
AS  
SELECT
    A.intBatchId,
    A.strBatchId,
    A.intSales,
    A.intSalesYear,
    A.dtmSalesDate,
    A.strTeaType,
    A.intBrokerId,
    A.strVendorLotNumber,
    A.intBuyingCenterLocationId,
    A.intParentBatchId,
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
    A.intBrokerWarehouseId,
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
    A.strTeaOrigin,
    A.intOriginalItemId,
    A.dblPackagesPerPallet,
    A.strPlant,
    A.dblTotalQuantity,
    A.strSampleBoxNumber,
    A.dblSellingPrice,
    A.dtmStock,
    A.strStorageLocation,
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
    A.strTinNumber,
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
    strParentBatchId = B.strBatchId,
    A.intTinId,
    A.intConcurrencyId
FROM tblMFBatch A
LEFT JOIN tblMFBatch B
ON A.intParentBatchId = B.intBatchId