CREATE TABLE [dbo].[tblRKM2MTransaction]
(
	[intM2MTransactionId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKM2MTransaction] PRIMARY KEY ([intM2MTransactionId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE
)
