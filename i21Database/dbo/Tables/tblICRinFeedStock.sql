CREATE TABLE [dbo].[tblICRinFeedStock]
(
	[intRinFeedStockId] INT NOT NULL IDENTITY, 
    [strRinFeedStockCode] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICRinFeedStock] PRIMARY KEY ([intRinFeedStockId]), 
    CONSTRAINT [AK_tblICRinFeedStock_strRinFeedStockCode] UNIQUE ([strRinFeedStockCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStock',
    @level2type = N'COLUMN',
    @level2name = N'intRinFeedStockId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RIN Feed Stock Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStock',
    @level2type = N'COLUMN',
    @level2name = N'strRinFeedStockCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStock',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStock',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICRinFeedStock',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'