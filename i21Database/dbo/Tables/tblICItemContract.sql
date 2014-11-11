CREATE TABLE [dbo].[tblICItemContract]
(
	[intItemContractId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
    [strContractItemName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCountryId] INT NULL, 
    [strGrade] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strGradeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strGarden] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblYieldPercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTolerancePercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblFranchisePercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemContract] PRIMARY KEY ([intItemContractId]), 
    CONSTRAINT [FK_tblICItemContract_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemContract_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICItemContract_tblSMCountry] FOREIGN KEY ([intCountryId]) REFERENCES [tblSMCountry]([intCountryID])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'intItemContractId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Item Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'strContractItemName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'intCountryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grade',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'strGrade'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grade Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'strGradeType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Garden',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'strGarden'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Yield Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'dblYieldPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tolerance Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'dblTolerancePercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Franchise Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'dblFranchisePercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemContract',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'