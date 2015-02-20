/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCategoryUOM]
	(
		[intCategoryUOMId] INT NOT NULL IDENTITY , 
		[intCategoryId] INT NOT NULL,
		[intUnitMeasureId] INT NOT NULL, 
		[dblUnitQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblSellQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblWeight] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[intWeightUOMId] INT NULL,
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strUpcCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnStockUnit] BIT NULL DEFAULT ((0)),
		[ysnAllowPurchase] BIT NULL DEFAULT ((0)),
		[ysnAllowSale] BIT NULL DEFAULT ((0)),
		[dblLength] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intDimensionUOMId] INT NULL,
		[dblVolume] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intVolumeUOMId] INT NULL,
		[dblMaxQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCategoryUOM] PRIMARY KEY ([intCategoryUOMId]), 
		CONSTRAINT [FK_tblICCategoryUOM_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICCategoryUOM_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICCategoryUOM_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICCategoryUOM_DimensionUOM] FOREIGN KEY ([intDimensionUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICCategoryUOM_VolumeUOM] FOREIGN KEY ([intVolumeUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sell Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblSellQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblWeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'UPC Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'strUpcCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stock Unit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'ysnStockUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Purchase',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowPurchase'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allow Sale',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'ysnAllowSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Length',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblLength'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Width',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblWidth'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Height',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblHeight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volume',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblVolume'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dimension Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intDimensionUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volume Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryUOM',
    @level2type = N'COLUMN',
    @level2name = N'intVolumeUOMId'