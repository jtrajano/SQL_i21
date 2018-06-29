/*
## Overview
This is the hierarchy table for tracking the source and destination of a stock. 
It helps to track the transaction(s) with a vendor where it was purchased, how it was used internally like in manufacturing or during inventory transfers, and to its final destination as sale to a customer. 

## Fields, description, and mapping. 
*	[intId] INT NOT NULL IDENTITY
	System control number. 
	Maps: None 


* 	[intItemId] INT NOT NULL
	Foreign key to tblICItem. One of the unique keys in this table. 
	Maps: None


* 	[intItemLocationId] INT NOT NULL
	Foreign key to tblICItemLocation. One of the unique keys in this table. 
	Maps: None


* 	[intAncestorId] INT NULL
	Foreign key to tblICInventoryTransaction. One of the unique keys in this table. 
	Maps: None


* 	[intDescendantId] INT NULL
	Foreign key to tblICInventoryTransaction. One of the unique keys in this table. 
	Maps: None


* 	[intConcurrencyId] INT NULL
	Concurrency field. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemStockPath]
	(
		[intId] BIGINT NOT NULL IDENTITY, 	
		[intItemId] INT NOT NULL,	
		[intItemLocationId] INT NOT NULL,
		[intAncestorId] INT NULL,	
		[intDescendantId] INT NULL,	
		[intDepth] INT NOT NULL DEFAULT ((0)),	
		[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
		CONSTRAINT [PK_tblICItemStockPath] PRIMARY KEY CLUSTERED ([intId] ASC),
		CONSTRAINT [UN_tblICItemStockPath] UNIQUE NONCLUSTERED ([intItemId] ASC, [intItemLocationId] ASC, [intAncestorId] ASC, [intDescendantId] ASC),
		CONSTRAINT [FK_tblICItemStockPath_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICItemStockPath_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICItemStockPath_tblICInventoryTransaction_Ancestor] FOREIGN KEY ([intAncestorId]) REFERENCES [tblICInventoryTransaction]([intInventoryTransactionId]),
		CONSTRAINT [FK_tblICItemStockPath_tblICInventoryTransaction_Descendant] FOREIGN KEY ([intDescendantId]) REFERENCES [tblICInventoryTransaction]([intInventoryTransactionId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICItemStockPath_intItemId_intItemLocationId]
		ON [dbo].[tblICItemStockPath]([intItemId] ASC, [intItemLocationId] ASC);

	