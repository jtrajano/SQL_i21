
CREATE TABLE [dbo].[tblARPaymentBankAccount](
	[intPaymentBankAccount]     INT IDENTITY(1,1) NOT NULL,
	[intBankAccountId]          INT NOT NULL,
	[strBankAccountNo]          NVARCHAR(200) NULL,
	[intConcurrencyId]          INT NULL,
	CONSTRAINT [PK_tblARPaymentBankAccount_intPaymentBankAccount] PRIMARY KEY CLUSTERED ([intPaymentBankAccount] ASC),
    CONSTRAINT [FK_tblARPaymentBankAccount_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);
GO
CREATE INDEX [idx_tblARPaymentBankAccount] ON [dbo].[tblARPaymentBankAccount] (intBankAccountId) INCLUDE (strBankAccountNo)
GO