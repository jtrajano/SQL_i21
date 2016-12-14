CREATE TABLE [dbo].[tblPATTransfer]
(
	[intTransferId] INT NOT NULL IDENTITY,
	[intTransferType] INT NULL,
	[strTransferNo] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransferDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmTransferDate] DATETIME NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATTransfer] PRIMARY KEY ([intTransferId]) 
)