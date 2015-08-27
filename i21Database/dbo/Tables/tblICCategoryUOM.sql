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
		[ysnStockUnit] BIT NULL DEFAULT ((0)),
		[ysnAllowPurchase] BIT NULL DEFAULT ((0)),
		[ysnAllowSale] BIT NULL DEFAULT ((0)),
		[ysnDefault] BIT NULL DEFAULT ((0)),
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCategoryUOM] PRIMARY KEY ([intCategoryUOMId]), 
		CONSTRAINT [FK_tblICCategoryUOM_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICCategoryUOM_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [AK_tblICCategoryUOM] UNIQUE ([intCategoryId], [intUnitMeasureId])
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

GO

GO

GO

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

GO

GO

GO

GO

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

GO

GO
