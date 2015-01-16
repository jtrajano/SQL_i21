CREATE TABLE [dbo].[tblICItemLocation]
(
	[intItemLocationId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
	[intLocationId] INT NOT NULL, 
    [intVendorId] INT NULL, 
    [strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intCostingMethod] INT NULL, 
	[intAllowNegativeInventory] INT DEFAULT 3,
    [intCategoryId] INT NULL, 
    [strRow] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intDefaultUOMId] INT NULL, 
    [intIssueUOMId] INT NULL, 
    [intReceiveUOMId] INT NULL, 
    [intFamilyId] INT NULL, 
    [intClassId] INT NULL, 
	[intProductCodeId] INT NULL, 
    [intFuelTankId] INT NULL, 
    [strPassportFuelId1] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strPassportFuelId2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strPassportFuelId3] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnTaxFlag1] BIT NULL, 
	[ysnTaxFlag2] BIT NULL, 
	[ysnTaxFlag3] BIT NULL, 
	[ysnTaxFlag4] BIT NULL, 
    [ysnPromotionalItem] BIT NULL, 
    [intMixMatchId] INT NULL, 
    [ysnDepositRequired] BIT NULL, 
    [intBottleDepositNo] INT NULL, 
    [ysnSaleable] BIT NULL, 
    [ysnQuantityRequired] BIT NULL, 
    [ysnScaleItem] BIT NULL, 
    [ysnFoodStampable] BIT NULL, 
    [ysnReturnable] BIT NULL, 
    [ysnPrePriced] BIT NULL, 
    [ysnOpenPricePLU] BIT NULL, 
    [ysnLinkedItem] BIT NULL, 
    [strVendorCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnCountBySINo] BIT NULL, 
    [strSerialNoBegin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSerialNoEnd] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnIdRequiredLiquor] BIT NULL, 
    [ysnIdRequiredCigarette] BIT NULL, 
    [intMinimumAge] INT NULL, 
    [ysnApplyBlueLaw1] BIT NULL, 
	[ysnApplyBlueLaw2] BIT NULL, 
    [intItemTypeCode] INT NULL, 
    [intItemTypeSubCode] INT NULL, 
    [ysnAutoCalculateFreight] BIT NULL, 
    [intFreightMethodId] INT NULL, 
    [dblFreightRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intShipViaId] INT NULL, 
    [intNegativeInventory] INT NULL DEFAULT ((3)), 
    [dblReorderPoint] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblMinOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblSuggestedQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblLeadTime] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strCounted] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intCountGroupId] INT NULL, 
    [ysnCountedDaily] BIT NULL DEFAULT ((0)), 
	[intSort] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [FK_tblICItemLocation_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemLocation_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblICItemLocation_tblICUnitMeasure_Default] FOREIGN KEY ([intDefaultUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblICItemLocation_tblICUnitMeasure_Issue] FOREIGN KEY ([intIssueUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblICItemLocation_tblICUnitMeasure_Receive] FOREIGN KEY ([intDefaultUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [PK_tblICItemLocation] PRIMARY KEY ([intItemLocationId]), 
    CONSTRAINT [FK_tblICItemLocation_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intVendorId]), 
    CONSTRAINT [FK_tblICItemLocation_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
    CONSTRAINT [FK_tblICItemLocation_tblICCountGroup] FOREIGN KEY ([intCountGroupId]) REFERENCES [tblICCountGroup]([intCountGroupId]), 
    CONSTRAINT [FK_tblICItemLocation_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intShipViaID])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemLocation_intItemId_intLocationId]
    ON [dbo].[tblICItemLocation]([intItemId] ASC, [intLocationId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemLocation_intCategoryId]
    ON [dbo].[tblICItemLocation]([intCategoryId] ASC);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = 'intItemLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intVendorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Costing Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCostingMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Row',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strRow'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strBin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intDefaultUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Issue Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intIssueUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receive Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intReceiveUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Family Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intFamilyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Class Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Code Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intProductCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fuel Tank Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intFuelTankId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Passport Fuel Id 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPassportFuelId1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Passport Fuel Id 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPassportFuelId2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Passport Fuel Id 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strPassportFuelId3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Flag 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxFlag1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Flag 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxFlag2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Flag 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxFlag3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Flag 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnTaxFlag4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotional Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPromotionalItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mix/Match Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intMixMatchId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deposit Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnDepositRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bottle Deposit Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intBottleDepositNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Saleable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnSaleable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity Required',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnQuantityRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnScaleItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Food Stampable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnFoodStampable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Returnable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnReturnable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pre Priced',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrePriced'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Open Price PLU',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnOpenPricePLU'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Linked Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnLinkedItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strVendorCategory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Count By Serial Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnCountBySINo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serial Number Begin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strSerialNoBegin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serial Number End',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strSerialNoEnd'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id Required for Liquor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnIdRequiredLiquor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id Required for Cigarrettes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnIdRequiredCigarette'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Age',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intMinimumAge'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Apply Blue Law 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnApplyBlueLaw1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Apply Blue Law 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnApplyBlueLaw2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Type Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intItemTypeCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Type Sub Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intItemTypeSubCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Auto Calculate Freight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnAutoCalculateFreight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Method Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intFreightMethodId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'dblFreightRate'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1: Yes allow negative, 2: Yes with Write-Off, 3: No. Default to 3 (Do not allow negative)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intAllowNegativeInventory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Negative Inventory',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intNegativeInventory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reorder Point',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'dblReorderPoint'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'dblMinOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Suggested Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'dblSuggestedQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lead Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'dblLeadTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Counted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'strCounted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Count Group',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intCountGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Counted Daily',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'ysnCountedDaily'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Via Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemLocation',
    @level2type = N'COLUMN',
    @level2name = N'intShipViaId'