CREATE TABLE [dbo].[tblICItemPricing]
(
	[intItemPricingId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
	[intItemUnitMeasureId] INT NULL, 
    [dblRetailPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblWholesalePrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblLargeVolumePrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblAmountPercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblSalePrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMSRPPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strPricingMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblLastCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblStandardCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMovingAverageCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblEndMonthCost] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dtmBeginDate] DATETIME NULL DEFAULT getdate(),
	[dtmEndDate] DATETIME NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemPricing] PRIMARY KEY ([intItemPricingId]), 
    CONSTRAINT [FK_tblICItemPricing_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemPricing_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICItemPricing_tblICItemUOM] FOREIGN KEY ([intItemUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intItemPricingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Retail Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblRetailPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Wholesale Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblWholesalePrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Large Volume Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblLargeVolumePrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sale Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblSalePrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'MSRP Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblMSRPPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pricing Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'strPricingMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblLastCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblStandardCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Moving Average Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblMovingAverageCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End of Month Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblEndMonthCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount/Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblAmountPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intItemUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Begin Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeginDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'