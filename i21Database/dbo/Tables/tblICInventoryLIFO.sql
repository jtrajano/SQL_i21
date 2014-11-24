/*
	Tracks all stocks in a LIFO manner. Records are physically arranged in a LIFO manner using a CLUSTERED index. 
*/

CREATE TABLE [dbo].[tblICInventoryLIFO]
(
	[intInventoryLIFOId] INT NOT NULL IDENTITY, 
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
    CONSTRAINT [PK_tblICInventoryLIFO] PRIMARY KEY NONCLUSTERED ([intInventoryLIFOId]) 
)
GO

CREATE CLUSTERED INDEX [IDX_tblICInventoryLIFO]
    ON [dbo].[tblICInventoryLIFO]([dtmDate] DESC, [intItemId] ASC, [intLocationId] ASC, [intInventoryLIFOId] DESC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFO_intItemId]
    ON [dbo].[tblICInventoryLIFO]([intItemId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFO_intInventoryLIFOId]
    ON [dbo].[tblICInventoryLIFO]([intInventoryLIFOId] ASC);