CREATE TABLE [dbo].[tblAPDefaultPayFromBankAccount]
(
	[intDefaultPayFromBankAccountId] INT NOT NULL IDENTITY,
    [intCompanyLocationId] INT NOT NULL DEFAULT 0,
    [intCurrencyId] INT NOT NULL DEFAULT 0, 
    [intBankAccountId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblAPDefaultPayFromBankAccount] PRIMARY KEY ([intDefaultPayFromBankAccountId])
)