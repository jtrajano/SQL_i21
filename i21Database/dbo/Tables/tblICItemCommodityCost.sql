CREATE TABLE [dbo].[tblICItemCommodityCost]
(
	[intItemCommodityCostId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intItemLocationId] INT NOT NULL, 
    [dblLastCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblStandardCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblAverageCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblEOMCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemCommodityCost] PRIMARY KEY ([intItemCommodityCostId]), 
    CONSTRAINT [FK_tblICItemCommodityCost_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemCommodityCost_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'intItemCommodityCostId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = 'intItemLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'dblLastCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'dblStandardCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Moving Average Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'dblAverageCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End of Month Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'dblEOMCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemCommodityCost',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'