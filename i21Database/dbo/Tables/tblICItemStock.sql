/*
## Overview
This table holds stock information like quantity on hand and etc. 

## Fields, description, and mapping. 
*	[intItemStockId] INT NOT NULL IDENTITY
	Internal id for this table. 
	Maps: None

*	[intItemId] INT NOT NULL
	FK to the tblICItem table. 
	Maps: None

*	[intItemLocationId] INT NOT NULL
	FK to the tblICItemLocation table. 
	Maps: None

*	[intSubLocationId] INT NULL
	FK to the tblICItemLocation table. It an additional locator field where exactly the item is stored in a location. 
	Maps: None

*	[dblUnitOnHand] NUMERIC(18, 6) NULL DEFAULT ((0))
	The number of stocks currently at hand. At hand means those transactions that has been posted in the system regardless of the transaction date. 
	Maps: None

*	[dblOrderCommitted] NUMERIC(18, 6) NULL DEFAULT ((0))
	The number of stocks committed at the sales order transactions. When a sales order is created, this order committed goes up. If the sales order has been shipped, it goes down. 
	Maps: None

*	[dblOnOrder] NUMERIC(18, 6) NULL DEFAULT ((0))
	The number of stocks at the purchase order transactions. When a purchase order is created, the On order qty goes up. If the purchase order has been received, it goes down. 
	Maps: None

*	[dblBackOrder] NUMERIC(18, 6) NULL DEFAULT ((0))
	The number of stocks at the sales order that is not yet shipped. When a back order transaction is created, the back order qty goes up. When the back order is fulfilled, the back order qty goes down. 
	Maps: None

*	[dblLastCountRetail] NUMERIC(18, 6) NULL DEFAULT ((0))
	The last physical count of the item at the retail stores. This can be edited by the end user. 
	Maps: None

*	[intSort] INT NULL
	An internal field that can be used to sort the order of the records. It helps to shows a set of records in descending or ascending order. It is usually used on grids. 
	Maps: None

*	[intConcurrencyId] INT NULL DEFAULT ((0))
	An internal field that mananges the concurrency of a record. 
	Maps: None

## Important Notes:
	The cost fields like Average Cost, Last Cost, and Standard Cost are moved to tblICItemPricing table. The users can edit that cost from that table whereas editing of values are not allowed on this table. 

## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemStock]
	(
		[intItemStockId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intSubLocationId] INT NULL, 
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
		INCLUDE(dblUnitOnHand, dblOnOrder);
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
		@value = N'Back Order',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemStock',
		@level2type = N'COLUMN',
		@level2name = N'dblBackOrder'
