/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICUnitMeasure]
	(
		[intUnitMeasureId] INT NOT NULL IDENTITY, 
		[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strSymbol] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strUnitType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[intDecimalPlaces] INT NULL DEFAULT 6, 
		CONSTRAINT [PK_tblICUnitMeasure] PRIMARY KEY ([intUnitMeasureId]), 
		CONSTRAINT [AK_tblICUnitMeasure_strUnitMeasure] UNIQUE ([strUnitMeasure]) 
	)
	GO
	--	CREATE NONCLUSTERED INDEX [IX_tblICUnitMeasure_intUnitMeasureId_strUnitMeasure]
	--	ON [dbo].[tblICUnitMeasure]([intUnitMeasureId] ASC, [strUnitMeasure] ASC);
	--GO

		CREATE NONCLUSTERED INDEX [IX_tblICUnitMeasure_intUnitMeasureId]
		ON [dbo].[tblICUnitMeasure]([intUnitMeasureId] ASC)
		INCLUDE (strUnitMeasure); 
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit of Measure Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'strUnitMeasure'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Symbol or Abbreviation',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'strSymbol'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'strUnitType'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	
	GO
	