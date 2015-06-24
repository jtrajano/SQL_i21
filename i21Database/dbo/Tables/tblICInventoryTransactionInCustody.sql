/*
## Overview
This tables holds all inventory transactions for storage/custody items (not company owned stocks). 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryTransactionInCustody]
	(
		[intInventoryTransactionInCustodyId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[intLotId] INT NOT NULL, 
		[dtmDate] DATETIME NOT NULL,	
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 		
		[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[dblValue] NUMERIC(18, 6) NULL, 
		[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intCurrencyId] INT NULL,
		[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
		[intTransactionId] INT NOT NULL, 
		[intTransactionDetailId] INT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intInventoryCostBucketInCustodyId] INT NULL, 
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 		
		[ysnIsUnposted] BIT NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryTransactionInCustody] PRIMARY KEY ([intInventoryTransactionInCustodyId]),
		CONSTRAINT [FK_tblICInventoryTransactionInCustody_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryTransactionInCustody_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICInventoryTransactionInCustody_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
		CONSTRAINT [FK_tblICInventoryTransactionInCustody_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionInCustody_strBatchId]
		ON [dbo].[tblICInventoryTransactionInCustody]([strBatchId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionInCustody_intItemId_intItemLocationId]
		ON [dbo].[tblICInventoryTransactionInCustody]([intItemId] ASC, [intItemLocationId] ASC);