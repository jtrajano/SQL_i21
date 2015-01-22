/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemKitDetail]
	(
		[intItemKitDetailId] INT NOT NULL IDENTITY, 
		[intItemKitId] INT NOT NULL, 
		[intItemId] INT NOT NULL, 
		[dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intUnitMeasureId] INT NULL, 
		[dblPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnSelected] INT NULL, 
		[inSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemKitDetail] PRIMARY KEY ([intItemKitDetailId]), 
		CONSTRAINT [FK_tblICItemKitDetail_tblICItemKit] FOREIGN KEY ([intItemKitId]) REFERENCES [tblICItemKit]([intItemKitId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemKitDetail_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'intItemKitDetailId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Kit Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'intItemKitId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Quantity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'dblQuantity'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Price',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'dblPrice'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Selected',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'ysnSelected'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'inSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemKitDetail',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'