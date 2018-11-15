CREATE TABLE [dbo].[tblICInventoryStockMovement]
(
	[intInventoryStockMovementId] INT NOT NULL IDENTITY, 
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
	[intInventoryTransactionId] INT NULL,
	[intInventoryTransactionStorageId] INT NULL,
	[intOwnershipType] INT NOT NULL,
	CONSTRAINT [PK_tblICInventoryStockMovement] PRIMARY KEY NONCLUSTERED([intInventoryStockMovementId]),
	CONSTRAINT [FK_tblICInventoryStockMovement_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICInventoryStockMovement_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
	CONSTRAINT [FK_tblICInventoryStockMovement_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
	CONSTRAINT [FK_tblICInventoryStockMovement_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) 

)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryStockMovement_strBatchId]
	ON [dbo].[tblICInventoryStockMovement]([strBatchId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryStockMovement_intItemId_intItemLocationId]
	ON [dbo].[tblICInventoryStockMovement]([intItemId] ASC, [intItemLocationId] ASC);
GO

CREATE CLUSTERED INDEX [IX_tblICInventoryStockMovement_dtmDate]
	ON [dbo].[tblICInventoryStockMovement]([dtmDate] ASC, [intInventoryStockMovementId] ASC);
GO