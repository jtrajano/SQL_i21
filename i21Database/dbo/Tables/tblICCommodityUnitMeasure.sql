/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCommodityUnitMeasure]
	(
		[intCommodityUnitMeasureId] INT NOT NULL IDENTITY, 
		[intCommodityId] INT NOT NULL, 
		[intUnitMeasureId] INT NOT NULL, 
		[dblUnitQty] NUMERIC(18, 6) NULL,
		[ysnStockUnit] BIT NULL DEFAULT ((0)), 
		[ysnDefault] BIT NULL DEFAULT ((0)),
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCommodityUnitMeasure] PRIMARY KEY ([intCommodityUnitMeasureId]), 
		CONSTRAINT [FK_tblICCommodityUnitMeasure_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]) ,
		CONSTRAINT [FK_tblICCommodityUnitMeasure_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Stock Unit',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'ysnStockUnit'
	GO
	
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityUnitMeasure',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default UOM',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityUnitMeasure',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'