CREATE TABLE [dbo].[tblCCDealerHeader]
(
	[intDealerHeaderId] INT NOT NULL IDENTITY,
	[intVendorId] INT NOT NULL DEFAULT 0,
	[intBankAccountId] INT NOT NULL DEFAULT 0,
	[strApType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate]   DATETIME  NOT NULL,
	[strInvoice] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strReference] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCcdReferece] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPayReferece] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCDealerHeader] PRIMARY KEY ([intDealerHeaderId]),
	
	CONSTRAINT [FK_tblCCDealerHeader_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [dbo].[tblAPVendor] ([intVendorId]),
	CONSTRAINT [FK_tblCCDealerHeader_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])  
)