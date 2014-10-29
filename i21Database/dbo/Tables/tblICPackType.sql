CREATE TABLE [dbo].[tblICPackType]
(
	[intPackTypeId] INT NOT NULL IDENTITY, 
    [strPackName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICPackType] PRIMARY KEY ([intPackTypeId]), 
    CONSTRAINT [AK_tblICPackType_strPackName] UNIQUE ([strPackName]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPackType',
    @level2type = N'COLUMN',
    @level2name = N'intPackTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pack Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPackType',
    @level2type = N'COLUMN',
    @level2name = N'strPackName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPackType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPackType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'