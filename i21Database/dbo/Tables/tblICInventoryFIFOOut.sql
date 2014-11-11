CREATE TABLE [dbo].[tblICInventoryFIFOOut]
(
	[Id] INT NOT NULL IDENTITY, 
    [intInventoryFIFOId] INT NOT NULL, 
    [intInventoryTransactionId] INT NOT NULL, 
    [dblQty] NUMERIC(18, 6) NOT NULL,
	CONSTRAINT [PK_tblICInventoryFIFOOut] PRIMARY KEY NONCLUSTERED ([Id])    
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOOut_intInventoryFifoId]
    ON [dbo].[tblICInventoryFIFOOut]([intInventoryFIFOId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOOut_intInventoryTransactionId]
    ON [dbo].[tblICInventoryFIFOOut]([intInventoryTransactionId] ASC);
GO
