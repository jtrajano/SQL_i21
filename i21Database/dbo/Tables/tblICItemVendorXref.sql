CREATE TABLE [dbo].[tblICItemVendorXref]
(
	[intItemVendorXrefId] INT NOT NULL IDENTITY , 
    [intItemId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
    [intVendorId] INT NOT NULL, 
    [strVendorProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [dblConversionFactor] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intUnitMeasureId] INT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemVendorXref] PRIMARY KEY ([intItemVendorXrefId]), 
    CONSTRAINT [FK_tblICItemVendorXref_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICItemVendorXref_tblICItemLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
    CONSTRAINT [FK_tblICItemVendorXref_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intVendorId]), 
    CONSTRAINT [FK_tblICItemVendorXref_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intItemVendorXrefId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intVendorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Product',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'strVendorProduct'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'strProductDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Conversion Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'dblConversionFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemVendorXref',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'