/*
## Overview
In VisionCore, we called this table as tblGLVoucher. This table will be used to hold all the details of an item related to the posted transaction. 
It will include the stock quantity, cost, and sales prices. It is very relevant to the items costing method and valuation. 
Records from this table will be used to generate the GL entries and later on for the inventory valuation report. 

All inbound stock records can have related record/s in tblICInventoryFIFO or tblICInventoryLIFO. Additional records in the costing bucket may be added to 
track accrual of the cost. 

Accrual of the cost means additional cost are added to an item after it has been received. Cost used during receiving may be an estimate cost (usually the last cost of the item). 
This is common as when the final bill is received from the Vendor, only when the final cost is determined. These additional cost can be freight charges, duties, foreign exchange rates, levies, taxes, and/or other kinds of costs. 
Such costs need to be considered and must make-up the cost of the item. 

Outbound (sold) items before the final cost is determined are recomputed to include the accrued costs. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryTransaction]
	(
		[intInventoryTransactionId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblValue] NUMERIC(38, 20) NULL, 
		[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intCurrencyId] INT NULL,
		[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL, -- OBSOLETE, use dblForexRate instead. 
		[intTransactionId] INT NOT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionDetailId] INT NULL, 
		[strBatchId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 
		[intLotId] INT NULL, 
		[ysnIsUnposted] BIT NULL,
		[intRelatedInventoryTransactionId] INT NULL,
		[intRelatedTransactionId] INT NULL,
		[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[intCostingMethod] INT NULL, 
		[intInTransitSourceLocationId] INT NULL, 
		[dtmCreated] DATETIME NOT NULL DEFAULT GETDATE(), 
		[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
		[intFobPointId] TINYINT NULL,
		[ysnNoGLPosting] BIT NULL DEFAULT 0, 
		[intForexRateTypeId] INT NULL,
		[dblForexRate] NUMERIC(38, 20) NOT NULL DEFAULT 1, 
		[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intCreatedUserId] INT NULL, 
		[intCreatedEntityId] INT NULL, 
		[intCompanyId] INT NULL, 
		[dblUnitRetail] NUMERIC(38, 20) NULL,
		[dblCategoryCostValue] NUMERIC(38, 20) NULL, 
		[dblCategoryRetailValue] NUMERIC(38, 20) NULL, 
		[intCategoryId] INT NULL,
		[intSourceEntityId] INT NULL,
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 		
		-- AUDIT (UTC)---
		[dtmDateCreated] DATETIME2 NULL,
		[dtmDateModified] DATETIME2 NULL,
		CONSTRAINT [PK_tblICInventoryTransaction] PRIMARY KEY ([intInventoryTransactionId], [dtmCreated]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblICFobPoint] FOREIGN KEY ([intFobPointId]) REFERENCES [tblICFobPoint]([intFobPointId]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
		CONSTRAINT [FK_tblICInventoryTransaction_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId])
	)
	GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemId]
	--	ON [dbo].[tblICInventoryTransaction]([intItemId] ASC);
	--GO 

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intInventoryTransactionId]
		ON [dbo].[tblICInventoryTransaction]([intInventoryTransactionId] ASC)
		INCLUDE (intItemId, intItemLocationId, strTransactionId, strBatchId) 
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_forGLEntries]
		ON [dbo].[tblICInventoryTransaction]([strBatchId], [intItemId], [strTransactionId])
		INCLUDE ([intInTransitSourceLocationId]);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_detail]
		ON [dbo].[tblICInventoryTransaction]([strTransactionId] ASC, [intTransactionId] ASC, [intTransactionDetailId] ASC)
		INCLUDE (intItemId, intItemLocationId, strBatchId, intTransactionTypeId, intItemUOMId) 
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_related]
		ON [dbo].[tblICInventoryTransaction]([intRelatedTransactionId] ASC, [strRelatedTransactionId] ASC)
		INCLUDE (intItemId, intItemLocationId, intTransactionTypeId, ysnIsUnposted) 
	GO
	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_strTransactionId]
	--	ON [dbo].[tblICInventoryTransaction] ([strTransactionId])
	--	INCLUDE ([intItemId],[intItemUOMId],[dtmDate],[dblQty],[intTransactionId],[intTransactionDetailId],[intTransactionTypeId],[intInTransitSourceLocationId])
	--GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemLocationId]
	--	ON [dbo].[tblICInventoryTransaction]([intItemLocationId] ASC);

	GO 
	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_forDPR]
		ON [dbo].[tblICInventoryTransaction] ([intItemId])
		INCLUDE ([intItemLocationId],[intItemUOMId],[dtmDate],[dblQty],[intCurrencyId],[intTransactionId],[strTransactionId],[intTransactionDetailId],[intTransactionTypeId],[strTransactionForm],[intInTransitSourceLocationId])

	GO
