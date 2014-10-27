CREATE TABLE [dbo].[tblICItemKit]
(
	[intItemKitId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [strComponent] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strInputType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemKit] PRIMARY KEY ([intItemKitId]), 
    CONSTRAINT [FK_tblICItemKit_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemKit',
    @level2type = N'COLUMN',
    @level2name = N'intItemKitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemKit',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Component Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemKit',
    @level2type = N'COLUMN',
    @level2name = 'strComponent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Input Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemKit',
    @level2type = N'COLUMN',
    @level2name = N'strInputType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemKit',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemKit',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'