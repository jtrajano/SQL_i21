﻿/*
## Overview
Tracks the custody of customer-owned stocks (not owned by the company) in a FIFO manner. Records are physically arranged in a FIFO manner using a CLUSTERED index. 
Records must be maintained in this table even if the costing method for an item is average costing. 

## Fields, description, and mapping. 
*	[intInventoryLotStorageId] INT NOT NULL IDENTITY
	Primay key. 
	Maps: None 


* 	[intItemId] INT NOT NULL
	Foreign key to tblICItem. It links to the item table. 
	Maps: None


* 	[intLocationId] INT NOT NULL
	Foreign key to tblSMCompanyLocation. It links to the company location table. 
	Maps: None


*	[intLotId] INT NOT NULL 
	Foreign key to the tblICLot table. It links to the lot number. 
	Maps: None


* 	[dblStockIn] NUMERIC(38, 20) NOT NULL DEFAULT 0
	Stock Qty, in base units, received from the transaction. 
	Maps: None


* 	[dblStockOut] NUMERIC(38, 20) NOT NULL DEFAULT 0 
	Stock Qty, in base units, sold to the transaction. 
	Maps: None


* 	[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0 
	Cost of the stock per base units. 
	Maps: None


* 	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
	The string id of the transaction. 
	Maps: None


* 	[intTransactionId] INT NOT NULL
	The integer id of the transaction. 
	Maps: None


*	[dtmCreated] DATETIME NULL
	The date when the record is created in the server. This is different from the date of the transaction. 
	Maps: None


*	[ysnIsUnposted] BIT NOT NULL DEFAULT 0
	Flags if the cost bucket has been unposted. 
	Maps: None


*	[intCreatedUserId] INT NULL
	Internal field used to track the user id who created the cost bucket. 
	Maps: None


*	[intConcurrencyId] INT NOT NULL DEFAULT 1
	Internal field used to track the concurrency of the record. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLotStorage]
	(
		[intInventoryLotStorageId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[intLotId] INT NOT NULL, 
		[dtmDate] DATETIME NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[dblStockIn] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblStockOut] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionId] INT NOT NULL,
		[intTransactionDetailId] INT NULL,
		[dtmCreated] DATETIME NULL, 
		[ysnIsUnposted] BIT NOT NULL DEFAULT 0, 
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityId] INT NULL,
		[intCompanyId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		[dblStockAvailable] AS (ROUND(ISNULL(dblStockIn, 0) - ISNULL(dblStockOut, 0), 6)) PERSISTED,
		CONSTRAINT [PK_tblICInventoryLotStorage] PRIMARY KEY NONCLUSTERED ([intInventoryLotStorageId]),
		CONSTRAINT [FK_tblICInventoryLotStorage_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
		CONSTRAINT [FK_tblICInventoryLotStorage_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
	)
	GO

	CREATE CLUSTERED INDEX [IDX_tblICInventoryLotStorage]
		ON [dbo].[tblICInventoryLotStorage]([intInventoryLotStorageId] ASC, [intItemId] ASC, [intItemLocationId] ASC, [intLotId] ASC, [intItemUOMId] ASC);
	GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotStorage_intItemId_intLocationId]
	--	ON [dbo].[tblICInventoryLotStorage]([intItemId] ASC, [intItemLocationId] ASC)
	--	INCLUDE (dtmDate, intLotId, intItemUOMId, dblStockIn, dblStockOut, dblCost);
	--GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotStorage_Posting]
		ON [dbo].[tblICInventoryLotStorage]([intItemId] ASC, [intItemLocationId] ASC, [intItemUOMId] ASC, [intLotId] ASC, [dtmDate] ASC, [dblStockAvailable] ASC)
		INCLUDE (intTransactionId, strTransactionId, dblCost);
	GO