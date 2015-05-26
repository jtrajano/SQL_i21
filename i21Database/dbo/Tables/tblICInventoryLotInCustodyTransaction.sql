/*
## Overview
When adding or reducing the stock qty of an item under the company's custody, this table will keep a record on every movement of that stock. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.

## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLotInCustodyTransaction]
	(
		[intInventoryLotInCustodyTransactionId] INT NOT NULL IDENTITY, 
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
		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intTransactionTypeId] INT NOT NULL, 		
		[ysnIsUnposted] BIT NULL,
		[strTransactionForm] NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
		[dtmCreated] DATETIME NULL, 
		[intCreatedUserId] INT NULL, 
		[intConcurrencyId] INT NOT NULL DEFAULT 1, 
		CONSTRAINT [PK_tblICInventoryLotInCustodyTransaction] PRIMARY KEY ([intInventoryLotInCustodyTransactionId]),
		CONSTRAINT [FK_tblICInventoryLotInCustodyTransaction_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryLotInCustodyTransaction_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICInventoryLotInCustodyTransaction_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
		CONSTRAINT [FK_tblICInventoryLotInCustodyTransaction_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotInCustodyTransaction_strBatchId]
		ON [dbo].[tblICInventoryLotInCustodyTransaction]([strBatchId] ASC);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLotInCustodyTransaction_intItemId_intItemLocationId]
		ON [dbo].[tblICInventoryLotInCustodyTransaction]([intItemId] ASC, [intItemLocationId] ASC);