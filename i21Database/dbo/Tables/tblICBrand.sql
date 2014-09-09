CREATE TABLE [dbo].[tblICBrand]
(
	[intBrandId] INT NOT NULL IDENTITY , 
    [strBrand] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICBrand] PRIMARY KEY ([intBrandId]), 
    CONSTRAINT [AK_tblICBrand_strBrand] UNIQUE ([strBrand])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBrand',
    @level2type = N'COLUMN',
    @level2name = N'intBrandId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Brand Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBrand',
    @level2type = N'COLUMN',
    @level2name = N'strBrand'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBrand',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBrand',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBrand',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'