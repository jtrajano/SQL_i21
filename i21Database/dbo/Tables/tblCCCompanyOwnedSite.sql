CREATE TABLE [dbo].[tblCCCompanyOwnedSite]
(
	[intCompanyOwnedSiteId] INT NOT NULL IDENTITY,
	[intCreditCardReceivableAccountId] INT NOT NULL,
	[intFeeExpenseAccountId] INT NOT NULL,
	[ysnPassedThruArCustomer]  BIT  DEFAULT ((0)) NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCCompanyOwnedSite] PRIMARY KEY ([intCompanyOwnedSiteId]),
	CONSTRAINT [FK_tblCCCompanyOwnedSite_tblGLAccount_intCreditCardReceivableAccountId] FOREIGN KEY ([intCreditCardReceivableAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ,
	CONSTRAINT [FK_tblCCCompanyOwnedSite_tblGLAccount_intFeeExpenseAccountId] FOREIGN KEY ([intFeeExpenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ,
)