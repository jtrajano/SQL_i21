CREATE TYPE [dbo].[BankTransactionBatchDetailTable] AS TABLE(
	[intBankTransactionBatchId] [int] NULL,
	[intTransactionId] [int] NOT NULL,
	[intBankLoanId] [int] NULL,
	[strBankLoanId] [NVARCHAR](40),
	[strTransactionId] [nvarchar](40) NULL,
	[dtmDate] [datetime] NULL,
	[intGLAccountId] [int] NOT NULL,
	[strAccountId] [nvarchar](40) NULL,
	[strDescription] [nvarchar](255) NULL,
	[strName] [nvarchar](50) NULL,
	[dblCredit] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[dblDebit] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[ysnPosted] [bit] NULL,
	[strRowState] [nvarchar](20) NULL,
	[intConcurrencyId] [int] NOT NULL
)
GO

