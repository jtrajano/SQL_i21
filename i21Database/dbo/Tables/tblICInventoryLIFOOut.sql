﻿CREATE TABLE [dbo].[tblICInventoryLIFOOut]
(
	[Id] INT NOT NULL IDENTITY, 
    [intInventoryLIFOId] INT NULL, 
    [intInventoryTransactionId] INT NOT NULL, 
    [dblQty] NUMERIC(18, 6) NOT NULL,
	CONSTRAINT [PK_tblICInventoryLIFOOut] PRIMARY KEY NONCLUSTERED ([Id])    
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOOut_intInventoryLIFOId]
    ON [dbo].[tblICInventoryLIFOOut]([intInventoryLIFOId] DESC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOOut_intInventoryTransactionId]
    ON [dbo].[tblICInventoryLIFOOut]([intInventoryTransactionId] DESC);
GO
