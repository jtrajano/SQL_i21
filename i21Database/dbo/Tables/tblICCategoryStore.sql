CREATE TABLE [dbo].[tblICCategoryStore]
(
	[intCategoryStoreId] INT NOT NULL IDENTITY, 
	[intCategoryId] INT NOT NULL, 
    [intStoreId] INT NOT NULL, 
    [intRegisterDepartmentId] INT NULL, 
    [ysnUpdatePrices] BIT NULL, 
    [ysnUseTaxFlag1] BIT NULL, 
	[ysnUseTaxFlag2] BIT NULL, 
	[ysnUseTaxFlag3] BIT NULL, 
	[ysnUseTaxFlag4] BIT NULL, 
	[ysnBlueLaw1] BIT NULL, 
	[ysnBlueLaw2] BIT NULL, 

    [intNucleusGroupId] INT NULL, 
    [dblTargetGrossProfit] NUMERIC(18, 6) NULL, 
    [dblTargetInventoryCost] NUMERIC(18, 6) NULL, 
    [dblCostInventoryBOM] NUMERIC(18, 6) NULL, 
    [dblLowGrossMarginAlert] NUMERIC(18, 6) NULL, 
    [dblHighGrossMarginAlert] NUMERIC(18, 6) NULL, 
    [dtmLastInventoryLevelEntry] DATETIME NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCategoryStore] PRIMARY KEY ([intCategoryStoreId]), 
    CONSTRAINT [FK_tblICCategoryStore_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryStoreId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'intStoreId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cash Register Department Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'intRegisterDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Update Priceson PB Imports',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnUpdatePrices'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Tax Flag 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseTaxFlag1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Tax Flag 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseTaxFlag2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Tax Flag 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseTaxFlag3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Use Tax Flag 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnUseTaxFlag4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Blue Law 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnBlueLaw1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Blue Law 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'ysnBlueLaw2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Nucleus Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'intNucleusGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Target Gross Profit Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'dblTargetGrossProfit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Target Inventory at Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'dblTargetInventoryCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost of Inventory at BOM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'dblCostInventoryBOM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Low Gross Margin Percentage Alert',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'dblLowGrossMarginAlert'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'High Gross Margin Percentage Alert',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'dblHighGrossMarginAlert'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Inventory Level Entry',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastInventoryLevelEntry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryStore',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'