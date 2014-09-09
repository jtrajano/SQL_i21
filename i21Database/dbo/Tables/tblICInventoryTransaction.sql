CREATE TABLE [dbo].[tblICInventoryTransaction]
(
	[intInventoryTransactionId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intItemId] INT NOT NULL,
	[intItemLocationStoreId] INT NOT NULL,
	[dtmDate] DATE NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblUOMQty] NUMERIC(18,6) NOT NULL DEFAULT 1,
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL,
    [intTransactionTypeId] INT NOT NULL, 
    [intLotId] INT NULL, 
    [dtmCreated] DATE NULL, 
    [intCreatedUserId] INT NULL    
)

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemId]
    ON [dbo].[tblICInventoryTransaction]([intItemId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransaction_intItemLocationStoreId]
    ON [dbo].[tblICInventoryTransaction]([intItemLocationStoreId] ASC);
