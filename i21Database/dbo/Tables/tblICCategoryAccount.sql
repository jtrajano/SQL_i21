﻿CREATE TABLE [dbo].[tblICCategoryAccount]
(
	[intCategoryAccountId] INT NOT NULL IDENTITY, 
	[intCategoryId] INT NOT NULL, 
    [intLocationId] INT NULL, 
    [intStoreId] INT NULL, 
	[strAccountDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCategoryAccount] PRIMARY KEY ([intCategoryAccountId]), 
    CONSTRAINT [FK_tblICCategoryAccount_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intStoreId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'strAccountDescription'