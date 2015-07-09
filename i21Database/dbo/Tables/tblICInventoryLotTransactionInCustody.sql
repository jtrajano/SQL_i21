/*
## Overview
When adding or reducing the stock qty of an item under the company's custody, this table will keep a record on every movement of that stock. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.

## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLotTransactionInCustody]
	(
		[intInventoryLotTransactionInCustodyId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL,		
		[intLotId] INT NULL, 
		[intLocationId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intItemUOMId] INT NULL,
		[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intTransactionId] INT NOT NULL, 
		[intTransactionDetailId] INT NOT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intLotStatusId] INT,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[ysnIsUnposted] BIT,
		[intInventoryCostBucketInCustodyId] INT NULL, 
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryLotTransactionInCustody] PRIMARY KEY ([intInventoryLotTransactionInCustodyId]),
		CONSTRAINT [FK_tblICInventoryLotTransactionInCustody_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryLotTransactionInCustody_tblICInventoryLotInCustody] FOREIGN KEY ([intInventoryCostBucketInCustodyId]) REFERENCES [tblICInventoryLotInCustody]([intInventoryLotInCustodyId]),
		CONSTRAINT [FK_tblICInventoryLotTransactionInCustody_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICInventoryLotTransactionInCustody_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
		CONSTRAINT [FK_tblICInventoryLotTransactionInCustody_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotTransactionInCustody_strBatchId]
		ON [dbo].[tblICInventoryLotTransactionInCustody]([strBatchId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotTransactionInCustody_intItemId_intItemLocationId]
		ON [dbo].[tblICInventoryLotTransactionInCustody]([intItemId] ASC, [intItemLocationId] ASC);
