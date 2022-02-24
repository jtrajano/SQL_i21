﻿/*
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
		[dblUnitQty] NUMERIC(38, 20) NULL,
		[ysnStockUnit] BIT NULL DEFAULT ((0)), 
		[ysnDefault] BIT NULL DEFAULT ((0)),
		[ysnStockUOM] BIT NULL, 
		[dblPremiumDiscount] NUMERIC(38,20) NULL,
		[intCurrencyId] INT NULL,
		[intPriceUnitMeasureId] INT NULL,
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICCommodityUnitMeasure] PRIMARY KEY ([intCommodityUnitMeasureId]), 
		CONSTRAINT [FK_tblICCommodityUnitMeasure_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]) ON DELETE CASCADE,
		CONSTRAINT [FK_tblICCommodityUnitMeasure_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [AK_tblICCommodityUnitMeasure] UNIQUE ([intCommodityId], [intUnitMeasureId]), 
		CONSTRAINT [CHK_tblICCommodityUnitMeasure_CurrencyPerUOM] CHECK ((COALESCE(NULLIF(dblPremiumDiscount, 0), intCurrencyId, intPriceUnitMeasureId) IS NULL) OR (dblPremiumDiscount IS NOT NULL AND intCurrencyId IS NOT NULL AND intPriceUnitMeasureId IS NOT NULL))
	)

	GO

	CREATE NONCLUSTERED INDEX [IX_tblICCommodityUnitMeasure]
		ON [dbo].[tblICCommodityUnitMeasure]([intCommodityId] ASC, [intUnitMeasureId] ASC)
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