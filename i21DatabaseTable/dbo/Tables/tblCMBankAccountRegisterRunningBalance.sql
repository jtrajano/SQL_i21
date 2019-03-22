CREATE TABLE [dbo].[tblCMBankAccountRegisterRunningBalance](
	[intTransactionId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCompanyLocationId] [int] NULL,
	[strLocationName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intBankTransactionTypeId] [int] NOT NULL,
	[strBankTransactionTypeName] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceNo] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strMemo] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strPayee] [nvarchar](300) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [date] NULL,
	[dtmDateReconciled] [datetime] NULL,
	[ysnCheckVoid] [bit] NULL,
	[ysnClr] [bit] NULL,
	[dblEndingBalance] [decimal](18, 6) NULL,
	[dblOpeningBalance] [decimal](18, 6) NULL,
	[strUniqueId] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateEntered] [datetime] NULL,
	[dblPayment] [decimal](18, 6) NULL,
	[dblDeposit] [decimal](18, 6) NULL,
	rowId INT
) ON [PRIMARY]
GO
