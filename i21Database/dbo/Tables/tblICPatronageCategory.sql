CREATE TABLE [dbo].[tblICPatronageCategory]
(
	[intPatronageCategoryId] INT NOT NULL IDENTITY , 
    [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPurchaseSale] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strUnitAmount] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intSort] INT NULL DEFAULT ((0)),
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICPatronageCategory] PRIMARY KEY ([intPatronageCategoryId]), 
    CONSTRAINT [AK_tblICPatronageCategory_strCategoryCode] UNIQUE ([strCategoryCode])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'intPatronageCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'strCategoryCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase or Sale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'strPurchaseSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit or Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'strUnitAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICPatronageCategory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'