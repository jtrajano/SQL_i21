CREATE TABLE [dbo].[tblCMBankAccountRegisterRunningBalance](
	[intTransactionId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) NOT NULL,
	[intCompanyLocationId] [int] NULL,
	[strLocationName] [nvarchar](50) NULL,
	[intBankTransactionTypeId] [int] NOT NULL,
	[strBankTransactionTypeName] [nvarchar](20) NULL,
	[strReferenceNo] [nvarchar](20) NULL,
	[strMemo] [nvarchar](255) NULL,
	[strPayee] [nvarchar](300) NULL,
	[dtmDate] [date] NULL,
	[dtmDateReconciled] [datetime] NULL,
	[ysnCheckVoid] [bit] NULL,
	[ysnClr] [bit] NULL,
	[dblEndingBalance] [decimal](18, 6) NULL,
	[dblOpeningBalance] [decimal](18, 6) NULL,
	[strUniqueId] [nvarchar](10) NULL,
	[dtmDateEntered] [datetime] NULL,
	[dblPayment] [decimal](18, 6) NULL,
	[dblDeposit] [decimal](18, 6) NULL,
	rowId INT
) ON [PRIMARY]
GO
