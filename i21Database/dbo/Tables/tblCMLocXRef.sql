CREATE TABLE [dbo].[tblCMLocXRef](
	[Loc] [int] NOT NULL,
	[ATM Reimb] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[ATM Surchg] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Amex-CR] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Amex-DR] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[BA Merchant-CR] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[BA Merchant-DR] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Telecheck-CR] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Telecheck-CR1] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Store Deps] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[Store Chg Orders] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[AR Check Deps] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Misc Office Deps] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Subway] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Cust Init ACH] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[Clark] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[WEX] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]