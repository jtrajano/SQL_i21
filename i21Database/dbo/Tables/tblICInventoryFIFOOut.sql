CREATE TABLE [dbo].[tblICInventoryFIFOOut]
(
	[intId] INT NOT NULL IDENTITY, 
    [intInventoryFIFOId] INT NULL, 
    [intInventoryTransactionId] INT NOT NULL, 
    [dblQty] NUMERIC(18, 6) NOT NULL,
	CONSTRAINT [PK_tblICInventoryFIFOOut] PRIMARY KEY CLUSTERED ([intId])    
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOOut_intInventoryFifoId]
    ON [dbo].[tblICInventoryFIFOOut]([intInventoryFIFOId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryFIFOOut_intInventoryTransactionId]
    ON [dbo].[tblICInventoryFIFOOut]([intInventoryTransactionId] ASC);
GO
