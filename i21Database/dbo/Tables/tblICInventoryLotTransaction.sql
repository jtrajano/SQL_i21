/*
## Overview
This table logs all inventory transactions related to Lot

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLotTransaction]
	(
		[intInventoryLotTransactionId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL,		
		[intLotId] INT NULL, 
		[intLocationId] INT NOT NULL,
		[intItemLocationId] INT NOT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[dtmDate] DATETIME NOT NULL, 
		[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intItemUOMId] INT NULL,
		--[dblWeight] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		--[intWeightUOMId] INT NULL,
		[dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
		[intTransactionId] INT NOT NULL, 
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intLotStatusId] INT,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[ysnIsUnposted] BIT,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryLotTransaction] PRIMARY KEY ([intInventoryLotTransactionId]),
		CONSTRAINT [FK_tblICInventoryLotTransaction_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryLotTransaction_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICInventoryLotTransaction_tblICInventoryLotTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
		CONSTRAINT [FK_tblICInventoryLotTransaction_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotTransaction_strBatchId]
		ON [dbo].[tblICInventoryTransaction]([strBatchId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotTransaction_intLotId_intItemId_intItemLocationId]
		ON [dbo].[tblICInventoryTransaction]([intLotId] ASC, [intItemId] ASC, [intItemLocationId] ASC);
