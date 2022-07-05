CREATE TABLE [dbo].[tblARCustomerDefaultPayToBankAccount]
(	
	[intCustomerDefaultPayToBankAccountId]	INT	IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]					INT	NOT NULL,
	[intCompanyLocationId]					INT	NOT NULL,
	[intCurrencyId]							INT	NOT NULL,
	[intBankAccountId]						INT	NOT NULL,
    [intConcurrencyId]						INT	NOT NULL,
    CONSTRAINT [PK_tblARCustomerDefaultPayToBankAccount] PRIMARY KEY CLUSTERED ([intCustomerDefaultPayToBankAccountId] ASC),
	CONSTRAINT [FK_tblARCustomerDefaultPayToBankAccount_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerDefaultPayToBankAccount_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblARCustomerDefaultPayToBankAccount_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblARCustomerDefaultPayToBankAccount_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
)