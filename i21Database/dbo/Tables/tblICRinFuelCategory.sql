/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICRinFuelCategory]
	(
		[intRinFuelCategoryId] INT NOT NULL IDENTITY, 
		[strRinFuelCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strEquivalenceValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL, 
		CONSTRAINT [PK_tblICRinFuelCategory] PRIMARY KEY ([intRinFuelCategoryId]), 
		CONSTRAINT [AK_tblICRinFuelCategory_strRinFuelCategoryCode] UNIQUE ([strRinFuelCategoryCode])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFuelCategory',
		@level2type = N'COLUMN',
		@level2name = 'intRinFuelCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Fuel Category Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFuelCategory',
		@level2type = N'COLUMN',
		@level2name = 'strRinFuelCategoryCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFuelCategory',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Equivalence Value',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFuelCategory',
		@level2type = N'COLUMN',
		@level2name = 'strEquivalenceValue'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFuelCategory',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFuelCategory',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'