CREATE TABLE [dbo].[tblICCommodity]
(
	[intCommodityId] INT NOT NULL IDENTITY, 
    [strCommodityCode] NVARCHAR(50) NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intDecimalDPR] INT NULL DEFAULT ((2)), 
    [dblConsolidateFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnFXExposure] BIT NULL, 
    [dblPriceCheckMin] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblPriceCheckMax] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strCheckoffTaxDesc] NVARCHAR(50) NULL, 
	[strCheckoffAllState] NVARCHAR(50) NULL, 
    [strInsuranceTaxDesc] NVARCHAR(50) NULL,
	[strInsuranceAllState] NVARCHAR(50) NULL, 
    [dtmCropEndDateCurrent] DATETIME NULL, 
	[dtmCropEndDateNew] DATETIME NULL, 

    [strEDICode] NVARCHAR(50) NULL, 
    [strScheduleStore] NVARCHAR(50) NULL, 
    [strScheduleDiscount] NVARCHAR(50) NULL, 
    [strTextPurchase] NVARCHAR(50) NULL, 
    [strTextSales] NVARCHAR(50) NULL, 
	[strTextFees] NVARCHAR(50) NULL, 
    [strAGItemNumber] NVARCHAR(50) NULL, 
    [strScaleAutoDist	] NVARCHAR(50) NULL, 
    [ysnRequireLoadNumber] BIT NULL, 
    [ysnAllowVariety] BIT NULL, 
    [ysnAllowLoadContracts] BIT NULL, 
    [dblMaxUnder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMaxOver] NUMERIC(18, 6) NULL DEFAULT ((0)), 

    [intPatronageCategoryId] INT NULL, 
    [intPatronageCategoryDirectId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCommodity] PRIMARY KEY ([intCommodityId]), 
    CONSTRAINT [FK_tblICCommodity_tblICPatronageCategory1] FOREIGN KEY ([intPatronageCategoryId]) REFERENCES [tblICPatronageCategory]([intPatronageCategoryId]),
	CONSTRAINT [FK_tblICCommodity_tblICPatronageCategory2] FOREIGN KEY ([intPatronageCategoryDirectId]) REFERENCES [tblICPatronageCategory]([intPatronageCategoryId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strCommodityCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Decimals on DPR',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'intDecimalDPR'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Consolidate Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dblConsolidateFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FX Exposure',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'ysnFXExposure'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Checks - Minimum',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dblPriceCheckMin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Checks - Maximum',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dblPriceCheckMax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Checkoff Tax Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strCheckoffTaxDesc'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Checkoff All States',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strCheckoffAllState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Insurance Tax Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strInsuranceTaxDesc'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Insurance All States',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strInsuranceAllState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Crop End Date Current',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dtmCropEndDateCurrent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Crop End Date New',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dtmCropEndDateNew'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EDI Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strEDICode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Schedule Store',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strScheduleStore'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strScheduleDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Text Purchase',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strTextPurchase'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Text Sales',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strTextSales'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Text Fees',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strTextFees'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'AG Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strAGItemNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Auto Distribution Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'strScaleAutoDist	'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Require Load Number at Kiosk',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'ysnRequireLoadNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Variety',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowVariety'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Load Contracts',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowLoadContracts'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Maximum Under',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxUnder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Maximum Over',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxOver'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Patronage Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'intPatronageCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Patronage Category Direct Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'intPatronageCategoryDirectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'