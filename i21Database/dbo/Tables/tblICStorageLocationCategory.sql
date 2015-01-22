/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICStorageLocationCategory]
	(
		[intStorageLocationCategoryId] INT NOT NULL IDENTITY, 
		[intStorageLocationId] INT NOT NULL, 
		[intCategoryId] INT NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICStorageLocationCategory] PRIMARY KEY ([intStorageLocationCategoryId]), 
		CONSTRAINT [FK_tblICStorageLocationCategory_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationCategory',
		@level2type = N'COLUMN',
		@level2name = N'intStorageLocationCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Storage Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationCategory',
		@level2type = N'COLUMN',
		@level2name = N'intStorageLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Category Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationCategory',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationCategory',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationCategory',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'