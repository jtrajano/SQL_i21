CREATE TABLE [dbo].[tblCMABRActivityMatched]
(
	[intABRActivityMatchedId] INT IDENTITY(1,1) NOT NULL,
	[intABRActivityId] INT NOT NULL,
    [intTransactionId] INT NOT NULL,
    [dtmDateEntered] DATETIME,
    [intEntityId] INT NOT NULL,
	CONSTRAINT [FK_tblCMABRActivityMatched] FOREIGN KEY ([intABRActivityId]) REFERENCES [dbo].[tblCMABRActivity] ([intABRActivityId]),
	CONSTRAINT [FK_tblCMABRActivityMatched_BankTransation] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCMBankTransaction] ([intTransactionId]),
    CONSTRAINT [PK_tblCMABRActivityMatched] PRIMARY KEY ([intABRActivityMatchedId]), 
)
