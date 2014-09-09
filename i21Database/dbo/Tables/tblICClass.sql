CREATE TABLE [dbo].[tblICClass]
(
	[intClassId] INT NOT NULL  IDENTITY, 
    [strClass] NVARCHAR(50) NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICClass] PRIMARY KEY ([intClassId]), 
    CONSTRAINT [AK_tblICClass_strClass] UNIQUE ([strClass])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICClass',
    @level2type = N'COLUMN',
    @level2name = N'intClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Class Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICClass',
    @level2type = N'COLUMN',
    @level2name = N'strClass'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICClass',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICClass',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICClass',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'