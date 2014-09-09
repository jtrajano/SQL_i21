CREATE TABLE [dbo].[tblICFamily]
(
	[intFamilyId] INT NOT NULL  IDENTITY, 
    [strFamily] NVARCHAR(50) NOT NULL, 
    [strDesciption] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICFamily] PRIMARY KEY ([intFamilyId]), 
    CONSTRAINT [AK_tblICFamily_strFamily] UNIQUE ([strFamily])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFamily',
    @level2type = N'COLUMN',
    @level2name = N'intFamilyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Family Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFamily',
    @level2type = N'COLUMN',
    @level2name = N'strFamily'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFamily',
    @level2type = N'COLUMN',
    @level2name = N'strDesciption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFamily',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICFamily',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'