IF OBJECT_ID(N'[dbo].[tblGLDetailRecap]', 'U') IS NOT NULL
    DROP TABLE [dbo].[tblGLDetailRecap];

CREATE TABLE tblGLDetailRecap (
	[intGLDetailID] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[intTransactionID] [int]  NULL,
	[dtmDate] [datetime] NOT NULL,
	[strBatchID] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountID] [int] NULL,
	[strAccountGroup] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
	[strDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strJobID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyID] [int] NULL,
	[dblExchangeRate] [numeric](38, 20) NOT NULL,
	[dtmDateEntered] [datetime] NOT NULL,
	[dtmTransactionDate] [datetime] NULL,
	[ysnIsUnposted] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
	[intUserID] [int] NULL,
	[strTransactionForm] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strModuleName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strUOMCode] [char](6)  COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblGLDetailRecap] PRIMARY KEY CLUSTERED 
(
	[intGLDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX IX_tblGLDetailRecap ON tblGLDetailRecap (strTransactionID, intTransactionID)

GO


