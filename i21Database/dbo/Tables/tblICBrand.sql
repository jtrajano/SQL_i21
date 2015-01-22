/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICBrand]
	(
		[intBrandId] INT NOT NULL IDENTITY , 
		[strBrandCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strBrandName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intManufacturerId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICBrand] PRIMARY KEY ([intBrandId]), 
		CONSTRAINT [AK_tblICBrand_strBrand] UNIQUE ([strBrandCode]), 
		CONSTRAINT [FK_tblICBrand_tblICManufacturer] FOREIGN KEY ([intManufacturerId]) REFERENCES [tblICManufacturer]([intManufacturerId])
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
		@value = N'Brand Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICBrand',
		@level2type = N'COLUMN',
		@level2name = 'strBrandCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Brand Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICBrand',
		@level2type = N'COLUMN',
		@level2name = 'strBrandName'
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
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Manufacturer Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICBrand',
		@level2type = N'COLUMN',
		@level2name = N'intManufacturerId'