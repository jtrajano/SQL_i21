

CREATE TYPE MFBatchTableType AS TABLE
(
	intSales INT ,
	intSalesYear INT ,
	dtmSalesDate DATETIME ,
	strTeaType NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intBrokerId INT ,
	strVendorLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intBuyingCenterLocationId INT ,
	intParentBatchId INT,
	intInventoryReceiptId INT,
	intSampleId INT,
	intContractDetailId INT,
	str3PLStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strSupplierReference NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strAirwayBillCode NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strAWBSampleReceived NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strAWBSampleReference NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	dblBasePrice  NUMERIC(18,6) ,
	ysnBoughtAsReserved BIT ,
	ysnBoughtPrice BIT ,
	intBrokerWarehouseId INT ,
	dblBulkDensity  NUMERIC(18,6) ,
	strBuyingOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intSubBookId INT ,
	strContainerNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intCurrencyId INT ,
	dtmProductionBatch DATETIME ,
	dtmTeaAvailableFrom DATETIME ,
	strDustContent NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	ysnEUCompliant BIT ,
	strTBOEvaluatorCode NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strEvaluatorRemarks NVARCHAR(2048) COLLATE Latin1_General_CI_AS ,
	dtmExpiration DATETIME ,
	intFromPortId INT ,
	dblGrossWeight NUMERIC(18,6) ,
	dtmInitialBuy DATETIME ,
	dblWeightPerUnit NUMERIC(18,6) ,
	dblLandedPrice NUMERIC(18,6) ,
	strLeafCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strLeafManufacturingType NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strLeafSize NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strLeafStyle NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intBookId INT ,
	dblPackagesBought NUMERIC(18,6) ,
	intItemUOMId INT NULL,
	intWeightUOMId	INT NULL,
	strTeaOrigin NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intOriginalItemId INT ,
	dblPackagesPerPallet NUMERIC(18,6) ,
	strPlant NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	dblTotalQuantity NUMERIC(18,6) ,
	strSampleBoxNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	dblSellingPrice NUMERIC(18,6) ,
	dtmStock DATETIME ,
	strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strSubChannel NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	ysnStrategic BIT ,
	strTeaLingoSubCluster NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	dtmSupplierPreInvoiceDate DATETIME ,
	strSustainability NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strTasterComments NVARCHAR(2048) COLLATE Latin1_General_CI_AS ,
	dblTeaAppearance NUMERIC(18,6) ,
	strTeaBuyingOffice NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strTeaColour NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strTeaGardenChopInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intGardenMarkId INT ,
	strTeaGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	dblTeaHue NUMERIC(18,6) ,
	dblTeaIntensity NUMERIC(18,6) ,
	strLeafGrade NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	dblTeaMoisture NUMERIC(18,6) ,
	dblTeaMouthFeel NUMERIC(18,6) ,
	ysnTeaOrganic BIT ,
	dblTeaTaste NUMERIC(18,6) ,
	dblTeaVolume NUMERIC(18,6) ,
	intTealingoItemId INT ,
	dtmWarehouseArrival DATETIME ,
	intYearManufacture INT ,
	strPackageSize NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intPackageUOMId INT ,
	dblTareWeight NUMERIC(18,6) ,
	strTaster NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strFeedStock NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strFlourideLimit NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strLocalAuctionNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strPOStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strProductionSite NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strReserveMU NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	strQualityComments NVARCHAR(2048) COLLATE Latin1_General_CI_AS ,
	strRareEarth NVARCHAR(50) COLLATE Latin1_General_CI_AS
)