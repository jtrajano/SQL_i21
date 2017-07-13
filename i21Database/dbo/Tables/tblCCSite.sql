CREATE TABLE [dbo].[tblCCSite]
(
	[intSiteId] INT NOT NULL IDENTITY,
	[intVendorDefaultId] INT NULL,


	[intDealerSiteId] INT NULL,
	[intCompanyOwnedSiteId] INT NULL,

	[strSite] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSiteDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intPaymentMethodId] INT NULL,
	[intCustomerId] INT NULL,

	--CompanyOwnedSite	
	[ysnPassedThruArCustomer]  BIT  DEFAULT ((0)) NOT NULL,
	--
	--DealerSite	
	--intCreditCardReceivableAccountId
	[intAccountId] INT NOT NULL,
	[intFeeExpenseAccountId] INT NULL,
	[ysnPostNetToArCustomer]  BIT  DEFAULT ((0)) NOT NULL,
	[strMerchantCategory] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnSharedFee]  BIT  DEFAULT ((0)) NOT NULL,
	[intSharedFeePercentage] [int] DEFAULT ((0)) NULL,
	[dblSharedFeePercentage]  NUMERIC (18, 6) NULL DEFAULT(0),
	--	
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,


	CONSTRAINT [PK_tblCCSite] PRIMARY KEY ([intSiteId]),
	CONSTRAINT [AK_tblCCSite] UNIQUE ([strSite]),

	CONSTRAINT [FK_tblCCSite_tblCCVendorDefault_intVendorDefaultId] FOREIGN KEY ([intVendorDefaultId]) REFERENCES [dbo].[tblCCVendorDefault] ([intVendorDefaultId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCCSite_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),	
	CONSTRAINT [FK_tblCCSite_tblSMPaymentMethod_intPaymentMethodId] FOREIGN KEY (intPaymentMethodId) REFERENCES [dbo].[tblSMPaymentMethod] ([intPaymentMethodID]),
	CONSTRAINT [FK_tblCCSite_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ,	
	CONSTRAINT [FK_tblCCSite_tblGLAccount_intFeeExpenseAccountId] FOREIGN KEY ([intFeeExpenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
