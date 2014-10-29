/*
	Tracks all stocks in a LIFO manner. Records are physically arranged in a LIFO manner using a CLUSTERED index. 
	Records must be maintained in this table even if the costing method for an item is not LIFO.
*/

CREATE TABLE [dbo].[tblICInventoryLIFO]
(
	[intInventoryLIFOId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
	[intItemLocationId] INT NOT NULL,
    [dtmDate] DATETIME NOT NULL, 
    [dblStockIn] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblStockOut] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblICInventoryLIFO] PRIMARY KEY NONCLUSTERED ([intInventoryLIFOId]) 
)
GO

CREATE CLUSTERED INDEX [IDX_tblICInventoryLIFO]
    ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intItemLocationId] ASC, [intInventoryLIFOId] DESC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFO_intItemId]
    ON [dbo].[tblICInventoryLIFO]([intItemId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFO_intInventoryLIFOId]
    ON [dbo].[tblICInventoryLIFO]([intInventoryLIFOId] ASC);