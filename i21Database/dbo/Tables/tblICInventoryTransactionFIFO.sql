CREATE TABLE [dbo].[tblICInventoryTransactionFIFO]
(
	[intInventoryTransactionFIFOId] INT NOT NULL  IDENTITY, 
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
    CONSTRAINT [PK_tblICInventoryTransactionFIFO] PRIMARY KEY NONCLUSTERED ([intInventoryTransactionFIFOId])    
)
GO

CREATE CLUSTERED INDEX [IDX_tblICInventoryTransactionFIFO]
    ON [dbo].[tblICInventoryTransactionFIFO]([intItemId] ASC, [intItemLocationStoreId] ASC, [dtmDate] ASC, [intInventoryTransactionFIFOId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionFIFO_intInventoryTransactionId]
    ON [dbo].[tblICInventoryTransactionFIFO]([intInventoryTransactionFIFOId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionFIFO_intItemId]
    ON [dbo].[tblICInventoryTransactionFIFO]([intItemId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionFIFO_intItemLocationStoreId]
    ON [dbo].[tblICInventoryTransactionFIFO]([intItemLocationStoreId] ASC);
