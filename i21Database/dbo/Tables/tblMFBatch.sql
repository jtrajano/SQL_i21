CREATE TABLE tblMFBatch
(
	intBatchId INT IDENTITY(1,1) NOT NULL,
	strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intSales INT NOT NULL,
	intSalesYear INT NOT NULL,
	dtmSalesDate DATETIME NOT NULL,
	strTeaType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intBrokerId INT NOT NULL,
	strVendorLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intBuyingCenterLocationId INT NOT NULL,
	intParentBatchId INT NULL,
	intInventoryReceiptId INT NULL,
	intSampleId INT NULL,
	intContractDetailId INT NULL,
	str3PLStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strSupplierReference NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL ,
	strAirwayBillCode NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strAWBSampleReceived NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strAWBSampleReference NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dblBasePrice  NUMERIC(18,6)  NULL,
	ysnBoughtAsReserved BIT  NULL,
	ysnBoughtPrice BIT  NULL,
	intBrokerWarehouseId INT  NULL,
	dblBulkDensity  NUMERIC(18,6)  NULL,
	strBuyingOrderNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	intSubBookId INT  NULL,
	strContainerNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	intCurrencyId INT  NULL,
	dtmProductionBatch DATETIME  NULL,
	dtmTeaAvailableFrom DATETIME  NULL,
	strDustContent NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	ysnEUCompliant BIT  NULL,
	strTBOEvaluatorCode NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strEvaluatorRemarks NVARCHAR(2048) COLLATE Latin1_General_CI_AS  NULL,
	dtmExpiration DATETIME  NULL,
	intFromPortId INT  NULL,
	dblGrossWeight NUMERIC(18,6)  NULL,
	dtmInitialBuy DATETIME  NULL,
	dblWeightPerUnit NUMERIC(18,6)  NULL,
	dblLandedPrice NUMERIC(18,6)  NULL,
	strLeafCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strLeafManufacturingType NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strLeafSize NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strLeafStyle NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	intBookId INT  NULL,
	dblPackagesBought NUMERIC(18,6)  NULL,
	strTeaOrigin NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	intOriginalItemId INT NOT NULL,
	dblPackagesPerPallet NUMERIC(18,6)  NULL,
	strPlant NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dblTotalQuantity NUMERIC(18,6)  NULL,
	strSampleBoxNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dblSellingPrice NUMERIC(18,6)  NULL,
	dtmStock DATETIME  NULL,
	strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strSubChannel NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	ysnStrategic BIT  NULL,
	strTeaLingoSubCluster NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dtmSupplierPreInvoiceDate DATETIME  NULL,
	strSustainability NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strTasterComments NVARCHAR(2048) COLLATE Latin1_General_CI_AS  NULL,
	dblTeaAppearance NUMERIC(18,6)  NULL,
	strTeaBuyingOffice NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strTeaColour NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strTeaGardenChopInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	intGardenMarkId INT  NULL,
	strTeaGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dblTeaHue NUMERIC(18,6)  NULL,
	dblTeaIntensity NUMERIC(18,6)  NULL,
	strLeafGrade NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dblTeaMoisture NUMERIC(18,6)  NULL,
	dblTeaMouthFeel NUMERIC(18,6)  NULL,
	ysnTeaOrganic BIT  NULL,
	dblTeaTaste NUMERIC(18,6)  NULL,
	dblTeaVolume NUMERIC(18,6)  NULL,
	intTealingoItemId INT  NULL,
	strTinNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	dtmWarehouseArrival DATETIME  NULL,
	intYearManufacture INT  NULL,
	strPackageSize NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intPackageUOMId INT NULL,
	dblTareWeight NUMERIC(18,6) NULL,
	strTaster NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strFeedStock NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strFlourideLimit NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strLocalAuctionNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strPOStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strProductionSite NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strReserveMU NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	strQualityComments NVARCHAR(2048) COLLATE Latin1_General_CI_AS  NULL,
	strRareEarth NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    CONSTRAINT [PK_tblMFBatch] PRIMARY KEY CLUSTERED 
    (
        [intSales] ASC,
        [intSalesYear] ASC,
        [dtmSalesDate] ASC,
        [strTeaType] ASC,
        [intBrokerId] ASC,
        [strVendorLotNumber] ASC,
        [intBuyingCenterLocationId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)ON [PRIMARY]
GO