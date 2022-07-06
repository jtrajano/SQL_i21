CREATE TYPE [dbo].[BankTransactionBatchDetailTable] AS TABLE(
	[intBankTransactionBatchId] [INT] NULL,
	[intTransactionId] [INT] NOT NULL,
	[intBankLoanId] [INT] NULL,
	[strBankLoanId] [NVARCHAR](40) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionId] [NVARCHAR](40) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [DATETIME] NULL,
	[intGLAccountId] [INT] NOT NULL,
	[strAccountId] [NVARCHAR](40) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [NVARCHAR](255) COLLATE Latin1_General_CI_AS NULL,
	[strName] [NVARCHAR](50) COLLATE Latin1_General_CI_AS NULL,
	[dblCredit] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[dblDebit] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[dblCreditForeign] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[dblDebitForeign] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[intCurrencyExchangeRateTypeId] INT NULL,
	[strCurrencyExchangeRateType] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[dblExchangeRate] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[dblAmount] [decimal](18, 6) NOT NULL DEFAULT ((0)),
	[ysnPosted] [BIT] NULL,
	[strRowState] [NVARCHAR](20) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [INT] NOT NULL	
)
GO

