CREATE TABLE [dbo].[tblQMImportCatalogue]
(
	[intImportCatalogueId] INT NOT NULL IDENTITY,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
	[intImportLogId] INT NOT NULL,
    [ysnSuccess] BIT NULL,
    [ysnProcessed] BIT NOT NULL DEFAULT(0),
    [strLogResult] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

    -- Main Fields
	[intSampleId] INT NULL,
    [strSaleYear] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strBuyingCenter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intSaleNumber] BIGINT NULL,
    [strCatalogueType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSupplier] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strChannel] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strSubChannel] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strLotNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS,
    [strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intContractItem] INT NULL,
    [strSampleStatus] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
    [dblBoughtPrice] NUMERIC(18, 6) NULL,
    [strGroupNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblSupplierValuation] NUMERIC(18, 6) NULL,
    [strPackageType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strChopNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strGrade] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strManufacturingLeafType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSeason] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strGardenMark] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strGardenGeoOrigin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strWarehouseCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dtmManufacturingDate] DATETIME NULL,
    [dblTotalQtyOffered] NUMERIC(18, 6), 
    [intTotalNumberOfPackageBreakups] BIGINT NULL,
    [dblNetWtPerPackages] NUMERIC(18, 6) NULL,
    [intNoOfPackages] BIGINT NULL,
    [dblNetWtSecondPackageBreak] NUMERIC(18, 6) NULL,
    [intNoOfPackagesSecondPackageBreak] BIGINT NULL,
    [dblNetWtThirdPackageBreak] NUMERIC(18, 6) NULL,
    [intNoOfPackagesThirdPackageBreak] BIGINT NULL,
    [strSustainability] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [ysnOrganic] BIT DEFAULT 0,
    [dtmSaleDate] DATETIME NULL,
    [dtmPromptDate] DATETIME NULL,
    [strRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dblGrossWeight] NUMERIC(18, 6) NULL,
    [strColour] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSize] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strAppearance] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    [strHue] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    [strIntensity] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    [strTaste] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    [strMouthfeel] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    [strStyle] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strMusterLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strMissingLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strTaster] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strTastersRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strTealingoItem] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [ysnBought] BIT DEFAULT 0,
    [dblB1QtyBought] NUMERIC(18, 6) NULL,
    [strB1QtyUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblB1Price] NUMERIC(18, 6) NULL,
    [strB1PriceUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strB1CompanyCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strB1GroupNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [dblB2QtyBought] NUMERIC(18, 6) NULL,
    [strB2QtyUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblB2Price] NUMERIC(18, 6) NULL,
    [strB2PriceUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblB3QtyBought] NUMERIC(18, 6) NULL,
    [strB3QtyUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblB3Price] NUMERIC(18, 6) NULL,
    [strB3PriceUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strBuyingOrderNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [str3PLStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strAdditionalSupplierReference] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strAirwayBillNumberCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intAWBSampleReceived] BIGINT NULL,
	[strAWBSampleReference] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblBasePrice] NUMERIC(18, 6) NULL,
    [ysnBoughtAsReserve] BIT DEFAULT 0,
    [strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [ysnEuropeanCompliantFlag] BIT DEFAULT 0,
    [strEvaluatorsCodeAtTBO] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strEvaluatorsRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFromLocationCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSampleBoxNumberTBO] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strBatchNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSampleTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,

	CONSTRAINT [PK_tblQMImportLogCatalogue_intImportCatalogueId] PRIMARY KEY CLUSTERED ([intImportCatalogueId] ASC),
    CONSTRAINT [FK_tblQMImportLogCatalogue_tblQMImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [dbo].[tblQMImportLog] ([intImportLogId]),
    CONSTRAINT [FK_tblQMImportLogCatalogue_tblQMSample] FOREIGN KEY ([intSampleId]) REFERENCES [dbo].[tblQMSample] ([intSampleId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblQMImportCatalogue_intImportLogId]
    ON [dbo].[tblQMImportCatalogue]([intImportLogId] ASC)
GO