CREATE TABLE [dbo].[tblICRinFeedStockUOM]
(
	[intRinFeedStockUOMId] INT NOT NULL IDENTITY, 
    [strRinFeedStockUOM] NVARCHAR(50) NULL, 
    [strRinFeedStockUOMCode] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICRinFeedStockUOM] PRIMARY KEY ([intRinFeedStockUOMId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStockUOM',
    @level2type = N'COLUMN',
    @level2name = N'intRinFeedStockUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Feed Stock Unit of Measure',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStockUOM',
    @level2type = N'COLUMN',
    @level2name = N'strRinFeedStockUOM'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Feed Stock Unit of Measure Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStockUOM',
    @level2type = N'COLUMN',
    @level2name = N'strRinFeedStockUOMCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStockUOM',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStockUOM',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'