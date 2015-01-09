CREATE TABLE [dbo].[tblICItemPOSCategory]
(
	[intItemPOSCategoryId] INT NOT NULL IDENTITY , 
    [intItemId] INT NOT NULL, 
    [intCategoryId] INT NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemPOSCategory] PRIMARY KEY ([intItemPOSCategoryId]), 
    CONSTRAINT [FK_tblICItemPOSCategory_tblICItemPOS] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemPOSCategory_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOSCategory',
    @level2type = N'COLUMN',
    @level2name = N'intItemPOSCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOSCategory',
    @level2type = N'COLUMN',
    @level2name = 'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOSCategory',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOSCategory',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPOSCategory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'