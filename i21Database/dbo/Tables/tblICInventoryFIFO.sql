/*
	Tracks all stocks in a FIFO manner. Records are physically arranged in a FIFO manner using a CLUSTERED index. 
	Records must be maintained in this table even if the costing method for an item is not FIFO.
*/

CREATE TABLE [dbo].[tblICInventoryFIFO]
(
	[intInventoryFIFOId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
	[intLocationId] INT NOT NULL,
    [dtmDate] DATETIME NOT NULL, 
    [dblStockIn] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblStockOut] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTransactionId] INT NOT NULL,
    [dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblICInventoryFIFO] PRIMARY KEY NONCLUSTERED ([intInventoryFIFOId]) 
)
GO

CREATE CLUSTERED INDEX [IDX_tblICInventoryFIFO]
    ON [dbo].[tblICInventoryFIFO]([dtmDate] ASC, [intItemId] ASC, [intLocationId] ASC, [intInventoryFIFOId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFO_intItemId]
    ON [dbo].[tblICInventoryFIFO]([intItemId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFO_intInventoryFIFOId]
    ON [dbo].[tblICInventoryFIFO]([intInventoryFIFOId] ASC);