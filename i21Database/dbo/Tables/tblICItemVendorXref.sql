/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemVendorXref]
	(
		[intItemVendorXrefId] INT NOT NULL IDENTITY , 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intVendorId] INT NOT NULL, 
		[strVendorProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[dblConversionFactor] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
		[intItemUnitMeasureId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemVendorXref] PRIMARY KEY ([intItemVendorXrefId]), 
		CONSTRAINT [FK_tblICItemVendorXref_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemVendorXref_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICItemVendorXref_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]), 
		CONSTRAINT [FK_tblICItemVendorXref_tblICItemUOM] FOREIGN KEY ([intItemUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
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
		@value = N'Item Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemVendorXref',
		@level2type = N'COLUMN',
		@level2name = 'intItemLocationId'
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
		@value = N'Item Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemVendorXref',
		@level2type = N'COLUMN',
		@level2name = 'intItemUnitMeasureId'
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