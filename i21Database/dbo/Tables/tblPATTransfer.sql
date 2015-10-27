CREATE TABLE [dbo].[tblPATTransfer]
(
	[intTransferId] INT NOT NULL IDENTITY, 
    [strTransferType] NVARCHAR(50) NULL, 
    [dtmTransferDate] DATETIME NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATTransfer] PRIMARY KEY ([intTransferId]) 
)
