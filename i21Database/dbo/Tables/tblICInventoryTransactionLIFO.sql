CREATE TABLE [dbo].[tblICInventoryTransactionLIFO]
(
	[intInventoryTransactionLIFOId] INT NOT NULL  IDENTITY, 
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
    CONSTRAINT [PK_tblICInventoryTransactionLIFO] PRIMARY KEY NONCLUSTERED ([intInventoryTransactionLIFOId])    
)
GO

CREATE CLUSTERED INDEX [IDX_tblICInventoryTransactionLIFO]
    ON [dbo].[tblICInventoryTransactionLIFO]([intItemId] ASC, [intItemLocationStoreId] ASC, [dtmDate] ASC, [intInventoryTransactionLIFOId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionLIFO_intInventoryTransactionId]
    ON [dbo].[tblICInventoryTransactionLIFO]([intInventoryTransactionLIFOId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionLIFO_intItemId]
    ON [dbo].[tblICInventoryTransactionLIFO]([intItemId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionLIFO_intItemLocationStoreId]
    ON [dbo].[tblICInventoryTransactionLIFO]([intItemLocationStoreId] ASC);
