CREATE TABLE [dbo].[tblCCSiteHeader]
(
	[intSiteHeaderId] INT NOT NULL IDENTITY,
	[intVendorDefaultId] INT NOT NULL DEFAULT 0,
	[intBankAccountId] INT NOT NULL DEFAULT 0,
	[strApType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate]   DATETIME  NOT NULL,
	[strInvoice] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strReference] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCcdReference] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPayReference] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[ysnPosted]  BIT  DEFAULT ((0)) NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCSiteHeader] PRIMARY KEY ([intSiteHeaderId]),
	CONSTRAINT [FK_tblCCSiteHeader_tblCCVendorDefault_intVendorDefaultId] FOREIGN KEY ([intVendorDefaultId]) REFERENCES [dbo].[tblCCVendorDefault] ([intVendorDefaultId]),
	CONSTRAINT [FK_tblCCSiteHeader_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])  
)