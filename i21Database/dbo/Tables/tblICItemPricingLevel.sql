/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemPricingLevel]
	(
		[intItemPricingLevelId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[strPriceLevel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intItemUnitMeasureId] INT NULL, 
		[dblUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblMin] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblMax] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strPricingMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[dblAmountRate] NUMERIC(18,6) NULL DEFAULT ((0)), 
		[dblUnitPrice] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[strCommissionOn] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblCommissionRate] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemPricingLevel] PRIMARY KEY ([intItemPricingLevelId]), 
		CONSTRAINT [FK_tblICItemPricingLevel_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemPricingLevel_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICItemPricingLevel_tblICItemUOM] FOREIGN KEY ([intItemUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'intItemPricingLevelId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = 'intItemLocationId'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Price Level',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'strPriceLevel'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = 'intItemUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Units',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'dblUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Minimum',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'dblMin'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Maximum',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'dblMax'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pricing Method',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'strPricingMethod'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commission Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'strCommissionOn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commission Rate',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'dblCommissionRate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Price',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'dblUnitPrice'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemPricingLevel',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	
	GO
	
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount/Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemPricingLevel',
    @level2type = N'COLUMN',
    @level2name = N'dblAmountRate'