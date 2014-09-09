CREATE TABLE [dbo].[tblICCommodityUnitMeasure]
(
	[intCommodityUnitMeasureId] INT NOT NULL IDENTITY, 
    [intCommodityId] INT NOT NULL, 
	[intUnitMeasureId] INT NOT NULL, 
    [dblWeightPerPack] NUMERIC(18, 6) NULL, 
    [ysnStockUnit] BIT NULL, 
    [ysnAllowPurchase] BIT NULL, 
    [ysnAllowSale] BIT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCommodityUnitMeasure] PRIMARY KEY ([intCommodityUnitMeasureId]), 
    CONSTRAINT [FK_tblICCommodityUnitMeasure_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]) ,
	CONSTRAINT [FK_tblICCommodityUnitMeasure_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight per pack',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'dblWeightPerPack'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stock Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'ysnStockUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Purchase on Stock Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowPurchase'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Sale on Stock Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'