/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICUnitMeasureConversion]
	(
		[intUnitMeasureConversionId] INT NOT NULL IDENTITY, 
		[intUnitMeasureId] INT NOT NULL, 
		[intStockUnitMeasureId] INT NOT NULL, 
		[dblConversionToStock] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICUnitMeasureConversion] PRIMARY KEY ([intUnitMeasureConversionId]), 
		CONSTRAINT [FK_tblICUnitMeasureConversion_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) ON DELETE CASCADE,
		CONSTRAINT [FK_tblICUnitMeasureConversion_StockUnitMeasure] FOREIGN KEY ([intStockUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasureConversion',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureConversionId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasureConversion',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Stock Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasureConversion',
		@level2type = N'COLUMN',
		@level2name = N'intStockUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Conversion To Stock Unit of Measure',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasureConversion',
		@level2type = N'COLUMN',
		@level2name = N'dblConversionToStock'
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasureConversion',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasureConversion',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'