CREATE TABLE [dbo].[tblCMABRActivityMatchedDetail]
(
	[intABRActivityMatchedDetailId] INT IDENTITY(1,1) NOT NULL,
    [intABRActivityMatchedId] INT NOT NULL,
	[intABRActivityId] INT NOT NULL,
    [intTransactionId] INT NOT NULL,
	[intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblCMABRActivityMatchedDetail] FOREIGN KEY ([intABRActivityId]) REFERENCES [dbo].[tblCMABRActivity] ([intABRActivityId]),
	CONSTRAINT [FK_tblCMABRActivityMatchedDetail_BankTransation] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCMBankTransaction] ([intTransactionId]),
    CONSTRAINT [PK_tblCMABRActivityMatchedDetail] PRIMARY KEY ([intABRActivityMatchedDetailId]), 
)
