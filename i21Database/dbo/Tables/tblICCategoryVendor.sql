/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICCategoryVendor]
	(
		[intCategoryVendorId] INT NOT NULL IDENTITY, 
		[intCategoryId] INT NOT NULL, 
		[intCategoryLocationId] INT NULL, 
		[intVendorId] INT NULL, 
		[strVendorDepartment] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL  , 
		[ysnAddOrderingUPC] BIT NULL, 
		[ysnUpdateExistingRecords] BIT NULL, 
		[ysnAddNewRecords] BIT NULL, 
		[ysnUpdatePrice] BIT NULL, 
		[intFamilyId] INT NULL, 
		[intSellClassId] INT NULL, 
		[intOrderClassId] INT NULL, 
		[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCategoryVendor] PRIMARY KEY ([intCategoryVendorId]), 
		CONSTRAINT [FK_tblICCategoryVendor_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICCategoryVendor_tblAPVendor] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]), 
		CONSTRAINT [FK_tblICCategoryVendor_tblICCategoryLocation] FOREIGN KEY ([intCategoryLocationId]) REFERENCES [tblICCategoryLocation]([intCategoryLocationId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryVendorId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Category Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Category Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = 'intCategoryLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Vendor Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intVendorId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Vendor Department',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'strVendorDepartment'
	GO

	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Add Ordering UPC to Pricebook',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'ysnAddOrderingUPC'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Update Existing Records',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'ysnUpdateExistingRecords'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Add New Records',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'ysnAddNewRecords'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Update Price',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'ysnUpdatePrice'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Family Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intFamilyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Sell Class Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intSellClassId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Order Class Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intOrderClassId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Comments',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'strComments'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryVendor',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'