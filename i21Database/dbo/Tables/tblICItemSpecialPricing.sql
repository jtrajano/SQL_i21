/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemSpecialPricing]
	(
		[intItemSpecialPricingId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intLocationId] INT NOT NULL, 
		[strPromotionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmBeginDate] DATETIME NULL, 
		[dtmEndDate] DATETIME NULL, 
		[intUnitMeasureId] INT NULL, 
		[dblUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strDiscountBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
		[dblDiscount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblUnitAfterDiscount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblAccumulatedQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblAccumulatedAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemSpecialPricing] PRIMARY KEY ([intItemSpecialPricingId]), 
		CONSTRAINT [FK_tblICItemSpecialPricing_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemSpecialPricing_tblICItemLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICItemSpecialPricing_tblICItemUOM] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'intItemSpecialPricingId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'intLocationId'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Promotion Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'strPromotionType'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Begin Date',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dtmBeginDate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'End Date',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dtmEndDate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Units',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dblUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Discount By',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'strDiscountBy'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Discount',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dblDiscount'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Units After Discount',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dblUnitAfterDiscount'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Accumulated Qty',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dblAccumulatedQty'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Accumulated Amount',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'dblAccumulatedAmount'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSpecialPricing',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'