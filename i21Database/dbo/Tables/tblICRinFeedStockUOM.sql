/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICRinFeedStockUOM]
	(
		[intRinFeedStockUOMId] INT NOT NULL IDENTITY, 
		[intUnitMeasureId] INT NULL, 
		[strRinFeedStockUOMCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICRinFeedStockUOM] PRIMARY KEY ([intRinFeedStockUOMId]), 
		CONSTRAINT [FK_tblICRinFeedStockUOM_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFeedStockUOM',
		@level2type = N'COLUMN',
		@level2name = N'intRinFeedStockUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Feed Stock Unit of Measure',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFeedStockUOM',
		@level2type = N'COLUMN',
		@level2name = 'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Feed Stock Unit of Measure Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFeedStockUOM',
		@level2type = N'COLUMN',
		@level2name = N'strRinFeedStockUOMCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFeedStockUOM',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRinFeedStockUOM',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'