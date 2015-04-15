CREATE TABLE [dbo].[tblICBuildAssemblyDetail]
(
	[intBuildAssemblyDetailId] INT NOT NULL IDENTITY, 
    [intBuildAssemblyId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [intSubLocationId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intItemUOMId] INT NULL, 
    [dblCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICBuildAssemblyDetail] PRIMARY KEY ([intBuildAssemblyDetailId]), 
    CONSTRAINT [FK_tblICBuildAssemblyDetail_tblICBuildAssembly] FOREIGN KEY ([intBuildAssemblyId]) REFERENCES [tblICBuildAssembly]([intBuildAssemblyId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICBuildAssemblyDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICBuildAssemblyDetail_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblICBuildAssemblyDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intBuildAssemblyDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Build Assembly Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intBuildAssemblyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sub Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSubLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICBuildAssemblyDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'