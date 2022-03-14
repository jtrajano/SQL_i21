CREATE TABLE [dbo].[tblAPDefaultPayFromBankAccount]
(
	[intDefaultPayFromBankAccountId] INT NOT NULL IDENTITY,
    [intCurrencyId] INT NOT NULL, 
    [intBankAccountId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblAPDefaultPayFromBankAccount] PRIMARY KEY ([intDefaultPayFromBankAccountId])
)