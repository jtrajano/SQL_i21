CREATE TABLE [dbo].[tblICItemSales]
(
	[intItemId] INT NOT NULL, 
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
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemSales] PRIMARY KEY ([intItemId]), 
    CONSTRAINT [FK_tblICItemSales_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Patronage Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intPatronageCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Class Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intTaxClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stocked Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnStockedItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dyed Fuel',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnDyedFuel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Barcode Print',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'strBarcodePrint'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'MSDS Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnMSDSRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EPA Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'strEPANumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inbound Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnInboundTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Outbound Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnOutboundTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Restricted Chemical',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnRestrictedChemical'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnTankRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Available for TM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnAvailableTM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Percentage Full',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultFull'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fuel Inspect Fee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'strFuelInspectFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'strRINRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Fuel Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intRINFuelTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Denaturant Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'dblDenaturantPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tonnage Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnTonnageTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Load Tracking',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnLoadTracking'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mix Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'dblMixOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hand Add Ingredients',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnHandAddIngredient'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medication Tag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intMedicationTag'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ingredient Tag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intIngredientTag'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volume Rebate Group',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'strVolumeRebateGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Physical Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intPhysicalItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extend Pick Ticket',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnExtendPickTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Export EDI',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnExportEDI'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hazard Material',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnHazardMaterial'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Fee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'ysnMaterialFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemSales',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'