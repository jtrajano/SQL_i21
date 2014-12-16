﻿CREATE TABLE [dbo].[tblICInventoryLIFOOut]
(
	[intId] INT NOT NULL IDENTITY, 
    [intInventoryLIFOId] INT NULL, 
    [intInventoryTransactionId] INT NOT NULL, 
    [dblQty] NUMERIC(18, 6) NOT NULL,
	[intRevalueLifoId] INT NULL,
	CONSTRAINT [PK_tblICInventoryLIFOOut] PRIMARY KEY CLUSTERED ([intId])    
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOOut_intInventoryTransactionId]
    ON [dbo].[tblICInventoryLIFOOut]([intInventoryTransactionId] ASC)
    INCLUDE(intInventoryLIFOId);
GO