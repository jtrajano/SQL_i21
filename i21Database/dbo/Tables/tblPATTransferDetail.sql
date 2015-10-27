CREATE TABLE [dbo].[tblPATTransferDetail]
(
	[intTransferDetailId] INT NOT NULL IDENTITY, 
    [intTransferId] INT NULL, 
    [intTransferorId] INT NULL, 
    [intTransfereeId] INT NULL, 
    [intStockId] INT NULL, 
    [intRefundTypeId] INT NULL, 
    [dblQuantityAvailable] DECIMAL(18, 6) NULL, 
    [dblQuantityTransferred] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATTransferDetail] PRIMARY KEY ([intTransferDetailId]) 
)
