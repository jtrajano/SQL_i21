CREATE TABLE [dbo].[tblICItemStock]
(
	[intItemStockId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
    [strWarehouse] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intUnitMeasureId] INT NULL, 
	[dblAverageCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitOnHand] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblOrderCommitted] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblOnOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblReorderPoint] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMinOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblSuggestedQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblLeadTime] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strCounted] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intInventoryGroupId] INT NULL, 
    [ysnCountedDaily] BIT NULL DEFAULT ((0)), 
	[intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemStock] PRIMARY KEY ([intItemStockId]), 
    CONSTRAINT [FK_tblICItemStock_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICItemStock_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICItemStock_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
    CONSTRAINT [FK_tblICItemStock_tblICCountGroup] FOREIGN KEY ([intInventoryGroupId]) REFERENCES [tblICCountGroup]([intCountGroupId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemStock_intItemId_intLocationId]
    ON [dbo].[tblICItemStock]([intItemId] ASC, [intLocationId] ASC)
	INCLUDE(dblUnitOnHand, dblAverageCost);
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'intItemStockId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Warehouse',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'strWarehouse'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Units on Hand',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitOnHand'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Committed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblOrderCommitted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'On Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblOnOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reorder Point',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblReorderPoint'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblMinOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Suggested Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblSuggestedQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lead Time for Procurement',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblLeadTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Counted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'strCounted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = 'intInventoryGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Counted Daily',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'ysnCountedDaily'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = 'intConcurrencyId'