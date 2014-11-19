CREATE TABLE [dbo].[tblICItem] (
    [intItemId]                  INT             IDENTITY (1, 1) NOT NULL,
    [strItemNo]                  NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]              NVARCHAR(50)    COLLATE Latin1_General_CI_AS           NOT NULL,
    [strDescription]             NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intManufacturerId]          INT             NULL,
    [intBrandId]                 INT             NULL,
    [strStatus]                NVARCHAR(50)    COLLATE Latin1_General_CI_AS           NULL,
    [strModelNo]                 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intTrackingId] INT NULL, 
    [strLotTracking] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnRequireCustomerApproval] BIT NULL DEFAULT ((0)), 
    [intRecipeId] INT NULL, 
    [ysnSanitationRequired] BIT NULL DEFAULT ((0)), 
    [intLifeTime] INT NOT NULL, 
    [strLifeTimeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intReceiveLife] INT NULL, 
    [strGTIN] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strRotationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intNMFCId] INT NULL, 
    [ysnStrictFIFO] BIT NULL DEFAULT ((0)), 
    [intDimensionUOMId] INT NULL, 
    [dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblDepth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intWeightUOMId] INT NULL, 
    [dblWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intMaterialPackTypeId] INT NULL, 
    [strMaterialSizeCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intInnerUnits] INT NULL, 
    [intLayerPerPallet] INT NULL, 
    [intUnitPerLayer] INT NULL, 
    [dblStandardPalletRatio] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strMask1] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strMask2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strMask3] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intPatronageCategoryId] INT NULL, 
    [intTaxClassId] INT NULL, 
    [ysnStockedItem] BIT NULL DEFAULT ((0)), 
    [ysnDyedFuel] BIT NULL DEFAULT ((0)), 
    [strBarcodePrint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnMSDSRequired] BIT NULL DEFAULT ((0)), 
    [strEPANumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnInboundTax] BIT NULL DEFAULT ((0)), 
    [ysnOutboundTax] BIT NULL DEFAULT ((0)), 
    [ysnRestrictedChemical] BIT NULL DEFAULT ((0)), 
    [ysnTankRequired] BIT NULL DEFAULT ((0)), 
    [ysnAvailableTM] BIT NULL DEFAULT ((0)), 
    [dblDefaultFull] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strFuelInspectFee] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strRINRequired] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intRINFuelTypeId] INT NULL, 
    [dblDenaturantPercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnTonnageTax] BIT NULL DEFAULT ((0)), 
    [ysnLoadTracking] BIT NULL DEFAULT ((0)), 
    [dblMixOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnHandAddIngredient] BIT NULL DEFAULT ((0)), 
    [intMedicationTag] INT NULL, 
    [intIngredientTag] INT NULL, 
    [strVolumeRebateGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intPhysicalItem] INT NULL, 
    [ysnExtendPickTicket] BIT NULL DEFAULT ((0)), 
    [ysnExportEDI] BIT NULL DEFAULT ((0)), 
    [ysnHazardMaterial] BIT NULL DEFAULT ((0)), 
    [ysnMaterialFee] BIT NULL DEFAULT ((0)), 
	[strUPCNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCaseUOM] INT NULL, 
    [strNACSCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strWICCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intAGCategory] INT NULL, 
    [ysnReceiptCommentRequired] BIT NULL DEFAULT ((0)), 
    [strCountCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnLandedCost] BIT NOT NULL DEFAULT ((0)), 
    [strLeadTime] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnTaxable] BIT NOT NULL DEFAULT ((0)), 
    [strKeywords] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dblCaseQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dtmDateShip] DATETIME NULL, 
    [dblTaxExempt] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnDropShip] BIT NOT NULL DEFAULT ((0)), 
    [ysnCommisionable] BIT NOT NULL DEFAULT ((0)), 
    [ysnSpecialCommission] BIT NOT NULL DEFAULT ((0)), 
    [intCommodityId] INT NULL,
    [intCommodityHierarchyId] INT NULL, 
    [dblGAShrinkFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intOriginId] INT NULL, 
    [intProductTypeId] INT NULL, 
    [intRegionId] INT NULL, 
    [intSeasonId] INT NULL, 
    [intClassVarietyId] INT NULL, 
    [intProductLineId] INT NULL, 
    [strMarketValuation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [AK_tblICItem_strItemNo] UNIQUE ([strItemNo]), 
    CONSTRAINT [PK_tblICItem] PRIMARY KEY ([intItemId]), 
    CONSTRAINT [FK_tblICItem_tblICManufacturer] FOREIGN KEY ([intManufacturerId]) REFERENCES [tblICManufacturer]([intManufacturerId]), 
    CONSTRAINT [FK_tblICItem_tblICCategory] FOREIGN KEY ([intTrackingId]) REFERENCES [tblICCategory]([intCategoryId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblICItem_intItemId]
    ON [dbo].[tblICItem]([intItemId] ASC);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identity Field', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intItemId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique key that corresponds to the item number. Origin: agitm-no ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strItemNo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inventory type (e.g. 1=Inventory Item, 2=Service Item, 3=Finished Goods, 4=Bulk, 5=Pre-Mixes, 6=Raw Materials)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = 'strType';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Item Description. Origin: agitm-desc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strDescription';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a manufacturer. Origin: agitm-mfg-id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intManufacturerId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a brand. Origin: stpbk_brand_name ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intBrandId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status of an item (e.g. 1=Active, 2=Phased Out, 3=Discontinued)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = 'strStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Model number of an item. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strModelNo';
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Patronage Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intPatronageCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Class Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intTaxClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stocked Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnStockedItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dyed Fuel',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnDyedFuel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Barcode Print',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strBarcodePrint'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'MSDS Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnMSDSRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EPA Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strEPANumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inbound Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnInboundTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Outbound Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnOutboundTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Restricted Chemical',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnRestrictedChemical'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnTankRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Available for TM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnAvailableTM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Percentage Full',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultFull'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fuel Inspect Fee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strFuelInspectFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strRINRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Fuel Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intRINFuelTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Denaturant Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblDenaturantPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tonnage Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnTonnageTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Load Tracking',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnLoadTracking'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mix Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblMixOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hand Add Ingredients',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnHandAddIngredient'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medication Tag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intMedicationTag'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ingredient Tag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intIngredientTag'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volume Rebate Group',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strVolumeRebateGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Physical Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intPhysicalItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extend Pick Ticket',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnExtendPickTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Export EDI',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnExportEDI'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hazard Material',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnHazardMaterial'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Fee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnMaterialFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Require Customer Approval',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnRequireCustomerApproval'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recipe Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intRecipeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sanitation Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnSanitationRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Life Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intLifeTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Life Time Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strLifeTimeType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receive Life',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intReceiveLife'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'GTIN',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strGTIN'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rotation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strRotationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'NMFC Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intNMFCId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Strict FIFO',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnStrictFIFO'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dimension Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intDimensionUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Height',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblHeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Width',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblWidth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Depth',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblDepth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Size Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strMaterialSizeCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inner Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intInnerUnits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Layer Per Pallet',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intLayerPerPallet'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Per Layer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intUnitPerLayer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Pallet Ratio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblStandardPalletRatio'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mask 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strMask1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mask 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strMask2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mask 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strMask3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Pack Type Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intMaterialPackTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tracking Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intTrackingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lot Tracking',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strLotTracking'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UPC No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strUPCNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Case Unit of Measure',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intCaseUOM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'NACS Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strNACSCategory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'WIC Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strWICCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'AG Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intAGCategory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Comment Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnReceiptCommentRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Count Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strCountCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Landed Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnLandedCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lead Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strLeadTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Keywords',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strKeywords'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Case Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblCaseQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Ship',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateShip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Exempt',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxExempt'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Drop Ship',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnDropShip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commisionable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnCommisionable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Special Commission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = 'ysnSpecialCommission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Hierarchy Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityHierarchyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'GA Shrink Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblGAShrinkFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Origin Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intOriginId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intProductTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Region Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intRegionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intSeasonId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Class/Variety Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intClassVarietyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Line Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intProductLineId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Market Valuation',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'strMarketValuation'