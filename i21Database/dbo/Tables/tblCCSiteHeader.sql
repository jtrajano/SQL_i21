﻿CREATE TABLE [dbo].[tblCCSiteHeader]
(
	[intSiteHeaderId] INT NOT NULL IDENTITY,
	[intVendorDefaultId] INT NOT NULL DEFAULT 0,
	[intBankAccountId] INT NOT NULL DEFAULT 0,
	[strApType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate]   DATETIME  NOT NULL,
	[strInvoice] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strReference] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strCcdReference] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPayReference] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[ysnPosted]  BIT  DEFAULT ((0)) NOT NULL,
	[intCMBankTransactionId] INT NULL,
	[intSort] [int] NULL,
	[intCompanyLocationId] [int] null,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCSiteHeader] PRIMARY KEY ([intSiteHeaderId]),
	CONSTRAINT [FK_tblCCSiteHeader_tblCCVendorDefault_intVendorDefaultId] FOREIGN KEY ([intVendorDefaultId]) REFERENCES [dbo].[tblCCVendorDefault] ([intVendorDefaultId]),
	CONSTRAINT [FK_tblCCSiteHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblCCSiteHeader_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])  
)