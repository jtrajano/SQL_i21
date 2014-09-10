CREATE TABLE [dbo].[tblICInventoryTransaction]
(
	[intInventoryTransactionId] INT NOT NULL  IDENTITY, 
	[intItemId] INT NOT NULL,
	[intItemLocationStoreId] INT NOT NULL,
	[dtmDate] DATETIME NOT NULL, 
    [dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblUOMQty] NUMERIC(18,6) NOT NULL DEFAULT 1,
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[intCurrencyId] INT NULL,
	[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
    [intSourceTransactionId] INT NOT NULL, 
	[intTransactionTypeId] INT NOT NULL, 
	[intCostingId] INT NULL,
    [intLotId] INT NULL, 
    [dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblICInventoryTransaction] PRIMARY KEY NONCLUSTERED ([intInventoryTransactionId])    
)
GO

CREATE CLUSTERED INDEX [IDX_tblICInventoryTransaction]
    ON [dbo].[tblICInventoryTransaction]([intItemId] ASC, [intItemLocationStoreId] ASC, [dtmDate] ASC, [intInventoryTransactionId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intInventoryTransactionId]
    ON [dbo].[tblICInventoryTransaction]([intInventoryTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemId]
    ON [dbo].[tblICInventoryTransaction]([intItemId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemLocationStoreId]
    ON [dbo].[tblICInventoryTransaction]([intItemLocationStoreId] ASC);
