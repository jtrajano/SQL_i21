CREATE TABLE [dbo].[tblICBuildAssembly]
(
	[intBuildAssemblyId] INT NOT NULL IDENTITY, 
    [dtmBuildDate] DATETIME NOT NULL DEFAULT (getdate()), 
    [intItemId] INT NOT NULL, 
    [strBuildNo] NVARCHAR(50) NOT NULL, 
    [intLocationId] INT NULL, 
    [dblBuildQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSubLocationId] INT NULL, 
    [intItemUOMId] INT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICBuildAssembly] PRIMARY KEY ([intBuildAssemblyId]), 
    CONSTRAINT [AK_tblICBuildAssembly_strBuildNo] UNIQUE ([strBuildNo]), 
    CONSTRAINT [FK_tblICBuildAssembly_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICBuildAssembly_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICBuildAssembly_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblICBuildAssembly_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intBuildAssemblyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Build Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'dtmBuildDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Build Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'strBuildNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Build Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'dblBuildQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'dblCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssembly',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'