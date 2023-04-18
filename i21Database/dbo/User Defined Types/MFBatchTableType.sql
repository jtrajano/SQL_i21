CREATE TYPE MFBatchTableType AS TABLE
(
	intId INT IDENTITY(1,1),
	strBatchId NVARCHAR(50 )COLLATE Latin1_General_CI_AS ,
	intSales INT ,
	intSalesYear INT ,
	dtmSalesDate DATETIME ,
	strTeaType NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intBrokerId INT ,
	strVendorLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	intBuyingCenterLocationId INT , -- company
	intStorageLocationId  INT NULL, -- sub location
	intStorageUnitId  INT NULL, -- ic location
	intBrokerWarehouseId INT NULL,
	intParentBatchId INT NULL,
	intInventoryReceiptId INT NULL,
	intSampleId INT NULL,
	intContractDetailId INT NULL,
	str3PLStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSupplierReference NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAirwayBillCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAWBSampleReceived NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAWBSampleReference NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblBasePrice  NUMERIC(18,6) NULL,
	ysnBoughtAsReserved BIT NULL,
	dblBoughtPrice NUMERIC(18,6) NULL,
	dblBulkDensity  NUMERIC(18,6) NULL,
	strBuyingOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intSubBookId INT NULL,
	strContainerNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intCurrencyId INT NULL,
	dtmProductionBatch DATETIME NULL,
	dtmTeaAvailableFrom DATETIME NULL,
	strDustContent NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnEUCompliant BIT NULL,
	strTBOEvaluatorCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strEvaluatorRemarks NVARCHAR(2048) COLLATE Latin1_General_CI_AS NULL,
	dtmExpiration DATETIME NULL,
	intFromPortId INT NULL,
	dblGrossWeight NUMERIC(18,6) NULL,
	dtmInitialBuy DATETIME NULL,
	dblWeightPerUnit NUMERIC(18,6) NULL,
	dblLandedPrice NUMERIC(18,6) NULL,
	strLeafCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strLeafManufacturingType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strLeafSize NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strLeafStyle NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intBookId INT NULL,
	dblPackagesBought NUMERIC(18,6) NULL,
	intItemUOMId INT NULL,
	intWeightUOMId	INT NULL,
	strTeaOrigin NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intOriginalItemId INT NULL,
	dblPackagesPerPallet NUMERIC(18,6) NULL,
	strPlant NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblTotalQuantity NUMERIC(18,6) NULL,
	strSampleBoxNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblSellingPrice NUMERIC(18,6) NULL,
	dtmStock DATETIME NULL,
	strSubChannel NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnStrategic BIT NULL,
	strTeaLingoSubCluster NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dtmSupplierPreInvoiceDate DATETIME NULL,
	strSustainability NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTasterComments NVARCHAR(2048) COLLATE Latin1_General_CI_AS NULL,
	dblTeaAppearance NUMERIC(18,6) NULL,
	strTeaBuyingOffice NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTeaColour NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTeaGardenChopInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intGardenMarkId INT NULL,
	strTeaGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblTeaHue NUMERIC(18,6) NULL,
	dblTeaIntensity NUMERIC(18,6) NULL,
	strLeafGrade NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblTeaMoisture NUMERIC(18,6) NULL,
	dblTeaMouthFeel NUMERIC(18,6) NULL,
	ysnTeaOrganic BIT NULL,
	dblTeaTaste NUMERIC(18,6) NULL,
	dblTeaVolume NUMERIC(18,6) NULL,
	intTealingoItemId INT NULL,
	dtmWarehouseArrival DATETIME NULL,
	intYearManufacture INT NULL,
	strPackageSize NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intPackageUOMId INT NULL,
	dblTareWeight NUMERIC(18,6) NULL,
	strTaster NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strFeedStock NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strFlourideLimit NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strLocalAuctionNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPOStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strProductionSite NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strReserveMU NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strQualityComments NVARCHAR(2048) COLLATE Latin1_General_CI_AS NULL,
	strRareEarth NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strERPPONumber NVARCHAR(50) COLLATE  Latin1_General_CI_AS  NULL,
	strFreightAgent NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strSealNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strContainerType NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strVoyage NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strVessel NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	intLocationId INT,
	intMixingUnitLocationId INT
	,dblOriginalTeaTaste   NUMERIC(18,6)  NULL
	,dblOriginalTeaHue   NUMERIC(18,6)  NULL
	,dblOriginalTeaIntensity NUMERIC(18,6)  NULL
	,dblOriginalTeaMouthfeel  NUMERIC(18,6)  NULL
	,dblOriginalTeaAppearance  NUMERIC(18,6)  NULL
	,dblOriginalTeaVolume  NUMERIC(18,6)  NULL
	,dblOriginalTeaMoisture  NUMERIC(18,6)  NULL
	,intMarketZoneId INT NULL
	,dblTeaTastePinpoint   NUMERIC(18,6)  NULL
	,dblTeaHuePinpoint   NUMERIC(18,6)  NULL
	,dblTeaIntensityPinpoint NUMERIC(18,6)  NULL
	,dblTeaMouthFeelPinpoint  NUMERIC(18,6)  NULL
	,dblTeaAppearancePinpoint  NUMERIC(18,6)  NULL
	,dtmShippingDate DATETIME 
	,strFines NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intCountryId int 
	,intSupplierId int
)