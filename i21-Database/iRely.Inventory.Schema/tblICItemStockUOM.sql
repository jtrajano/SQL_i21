﻿/*
## Overview
This table will hold the qty per UOM for an item per location. 
It only tracks the qty of those non-'Stock UOM's. 

## Fields, description, and mapping. 
*	[intItemStockUOMId] INT NOT NULL IDENTITY
	Internal id for this table. 
	Maps: None

*	[intItemId] INT NOT NULL
	FK to the tblICItem table. 
	Maps: None

*	[intItemLocationId] INT NOT NULL
	FK to the tblICItemLocation table. 
	Maps: None

*	[intItemUOMId] INT NOT NULL,
	FK to the tblICItemUOM table. 
	Maps: None

*	[dblOnHand] NUMERIC(38, 20) NULL DEFAULT ((0))
	The number of stocks currently at the specific UOM. 
	Maps: None

*	[intConcurrencyId] INT NULL DEFAULT ((0))
	An internal field that mananges the concurrency of a record. 
	Maps: None

## Important Notes:
	The cost fields like Average Cost, Last Cost, and Standard Cost are moved to tblICItemPricing table. The users can edit that cost from that table whereas editing of values are not allowed on this table. 

## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemStockUOM]
	(
		[intItemStockUOMId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intItemUOMId] INT NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[dblOnHand] NUMERIC(38, 20) NULL DEFAULT ((0)),
		--[dblStorage] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblInConsigned] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblOnOrder] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblOrderCommitted] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblUnitReserved] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblInTransitInbound] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblInTransitOutbound] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblInTransitDirect] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblUnitStorage] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblConsignedPurchase] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblConsignedSale] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblOpenPurchaseContract] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[dblOpenSalesContract] NUMERIC(38, 20) NULL DEFAULT ((0)),
		[intConcurrencyId] INT NULL DEFAULT ((1)), 
		CONSTRAINT [PK_tblICItemStockUOM] PRIMARY KEY ([intItemStockUOMId]), 
		CONSTRAINT [FK_tblICItemStockUOM_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
	)
	GO
	CREATE NONCLUSTERED INDEX [IX_tblICItemStockUOM_intItemId_intLocationId_intItemUOMId]
		ON [dbo].[tblICItemStockUOM]([intItemId] ASC, [intItemLocationId] ASC, [intItemUOMId] ASC)
		INCLUDE(dblOnHand);
	GO
