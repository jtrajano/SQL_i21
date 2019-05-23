CREATE TABLE [dbo].[tblCMBankAccountRegisterRunningBalance](
	[rowId] [int] NOT NULL,
	[dblAmount] [decimal](18, 6) NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[intBankAccountId] [int] NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intRunningBalanceId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblCMBankAccountRegisterRunningBalance] PRIMARY KEY CLUSTERED 
(
	[intRunningBalanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

