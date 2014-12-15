﻿CREATE TABLE [dbo].[tblICItemPricingLevel]
(
	[intItemPricingLevelId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
	[intLocationId] INT NOT NULL, 
    [strPriceLevel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intUnitMeasureId] INT NULL, 
    [dblUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMin] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMax] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strPricingMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCommissionOn] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblCommissionRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblUnitPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnActive] BIT NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemPricingLevel] PRIMARY KEY ([intItemPricingLevelId]), 
    CONSTRAINT [FK_tblICItemPricingLevel_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemPricingLevel_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICItemPricingLevel_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'intItemPricingLevelId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price Level',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'strPriceLevel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'dblUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'dblMin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Maximum',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'dblMax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pricing Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'strPricingMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commission Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'strCommissionOn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commission Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'dblCommissionRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'