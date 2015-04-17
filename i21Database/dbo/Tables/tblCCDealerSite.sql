﻿CREATE TABLE [dbo].[tblCCDealerSite]
(
	[intDealerSiteId] INT NOT NULL IDENTITY,
	[intVendorDefaultId] INT NULL,
	[intAccountId] INT NOT NULL,
	[ysnPostNetToArCustomer]  BIT  DEFAULT ((0)) NOT NULL,
	[strMerchantCategory] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnSharedFee]  BIT  DEFAULT ((0)) NOT NULL,
	[intSharedFeePercentage] [int] DEFAULT ((0)) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,

	CONSTRAINT [PK_tblCCDealerSite] PRIMARY KEY ([intDealerSiteId]),
	CONSTRAINT [FK_tblCCDealerSite_tblCCSite_intDealerSiteId] FOREIGN KEY ([intDealerSiteId]) REFERENCES [dbo].[tblCCSite] ([intSiteId]) ,
	CONSTRAINT [FK_tblCCDealerSite_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ,
	CONSTRAINT [FK_tblCCDealerSite_tblCCVendorDefault_intVendorDefaultId] FOREIGN KEY ([intVendorDefaultId]) REFERENCES [dbo].[tblCCVendorDefault] ([intVendorDefaultId])
)
