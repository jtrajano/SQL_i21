CREATE TABLE [dbo].[tblARCompanyDefaultPayToBankAccount]
(	
	[intCompanyDefaultPayToBankAccountId]	INT	IDENTITY (1, 1) NOT NULL,
	[intCompanyLocationId]					INT	NOT NULL,
	[intCurrencyId]							INT	NOT NULL,
	[intBankAccountId]						INT	NOT NULL,
    [intConcurrencyId]						INT	NOT NULL,
    CONSTRAINT [PK_tblARCompanyDefaultPayToBankAccount] PRIMARY KEY CLUSTERED ([intCompanyDefaultPayToBankAccountId] ASC),
	CONSTRAINT [FK_tblARCompanyDefaultPayToBankAccount_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblARCompanyDefaultPayToBankAccount_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblARCompanyDefaultPayToBankAccount_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
)