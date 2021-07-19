/*
## Overview
This tables holds all inventory transactions for storage/custody items (not company owned stocks). 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryTransactionStorage]
	(
		[intInventoryTransactionStorageId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[intLotId] INT NULL, 
		[dtmDate] DATETIME NOT NULL,	
		[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 0, 		
		[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
		[dblValue] NUMERIC(38, 20) NULL, 
		[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intCurrencyId] INT NULL,
		[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
		[intTransactionId] INT NOT NULL, 
		[intTransactionDetailId] INT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intInventoryCostBucketStorageId] INT NULL, 
		[strBatchId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 		
		[ysnIsUnposted] BIT NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[intRelatedInventoryTransactionId] INT NULL, 
		[intRelatedTransactionId] INT NULL, 
		[strRelatedTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
		[intCostingMethod] INT NULL, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL,
		[intCreatedEntityId] INT NULL,		
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		[intForexRateTypeId] INT NULL,
		[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1,
		[intCompanyId] INT NULL, 
		[intSourceEntityId] INT NULL,
		[intTransactionItemUOMId] INT NULL,
		CONSTRAINT [PK_tblICInventoryTransactionStorage] PRIMARY KEY ([intInventoryTransactionStorageId]),
		CONSTRAINT [FK_tblICInventoryTransactionStorage_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryTransactionStorage_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICInventoryTransactionStorage_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
		CONSTRAINT [FK_tblICInventoryTransactionStorage_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionStorage_strBatchId]
		ON [dbo].[tblICInventoryTransactionStorage]([strBatchId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionStorage_intItemId_intItemLocationId]
		ON [dbo].[tblICInventoryTransactionStorage]([intItemId] ASC, [intItemLocationId] ASC);
