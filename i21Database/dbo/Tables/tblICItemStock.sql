/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemStock]
	(
		[intItemStockId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intSubLocationId] INT NULL, 
		[dblAverageCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblUnitOnHand] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblOrderCommitted] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblOnOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblBackOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblLastCountRetail] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemStock] PRIMARY KEY ([intItemStockId]), 
		CONSTRAINT [FK_tblICItemStock_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemStock_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICItemStock_intItemId_intLocationId]
		ON [dbo].[tblICItemStock]([intItemId] ASC, [intItemLocationId] ASC)
		INCLUDE(dblUnitOnHand, dblAverageCost);
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'intItemStockId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'intItemLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sub Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = 'intSubLocationId'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Units on Hand',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'dblUnitOnHand'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Order Committed',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'dblOrderCommitted'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'On Order',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'dblOnOrder'
	GO

	GO

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
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = 'intConcurrencyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Count Retail',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'dblLastCountRetail'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Average Cost',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'dblAverageCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Back Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemStock',
    @level2type = N'COLUMN',
    @level2name = N'dblBackOrder'
