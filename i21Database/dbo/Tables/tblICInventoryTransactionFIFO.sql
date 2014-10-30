/*
	The purpose of this table is keep track of all inbound and outbound flow of items with each having its own separate records. 
	So an inbound will have its own record and the outbound will also have its own. The intCostingId field will be the link back to the tblICInventoryFIFO table. 
	When an outbound transaction is un-posted, we will use the record in this table to update the appropriate record in tblICInventoryFIFO.
*/

CREATE TABLE [dbo].[tblICInventoryTransactionFIFO]
(
	[intInventoryTransactionFIFOId] INT NOT NULL  IDENTITY, 
	[intItemId] INT NOT NULL,
	[intItemLocationId] INT NOT NULL,
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
    ON [dbo].[tblICInventoryTransactionFIFO]([intItemId] ASC, [intItemLocationId] ASC, [dtmDate] ASC, [intInventoryTransactionFIFOId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionFIFO_intInventoryTransactionId]
    ON [dbo].[tblICInventoryTransactionFIFO]([intInventoryTransactionFIFOId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionFIFO_intItemId]
    ON [dbo].[tblICInventoryTransactionFIFO]([intItemId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblICInventoryTransactionFIFO_intItemLocationId]
    ON [dbo].[tblICInventoryTransactionFIFO]([intItemLocationId] ASC);
