CREATE TABLE [dbo].[tblARCustomerDefaultPayToAccount]
(	
	[intDefaultPayToAccountId]	INT	IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]		INT	NOT NULL,
	[intCompanyLocationId]		INT	NOT NULL,
	[intCurrencyId]				INT	NOT NULL,
	[intBankAccountId]			INT	NOT NULL,
    [intConcurrencyId]			INT	NOT NULL,
    CONSTRAINT [PK_tblARCustomerDefaultPayToAccount] PRIMARY KEY CLUSTERED ([intDefaultPayToAccountId] ASC),
	CONSTRAINT [FK_intCustomerDefaultPayToAccount_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_intCustomerDefaultPayToAccount_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_intCustomerDefaultPayToAccount_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_intCustomerDefaultPayToAccount_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
)