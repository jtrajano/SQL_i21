CREATE TABLE tblGLRecap (
	[intGLDetailId] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] [int]  NULL,
	[dtmDate] [datetime] NOT NULL,
	[strBatchId] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountId] [int] NULL,
	[strAccountGroup] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
	[strDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strJobId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId] [int] NULL,
	[dblExchangeRate] [numeric](38, 20) NOT NULL,
	[dtmDateEntered] [datetime] NOT NULL,
	[dtmTransactionDate] [datetime] NULL,
	[ysnIsUnposted] [bit] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	[intUserId] [int] NULL,
	[strTransactionForm] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strModuleName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strUOMCode] [char](6)  COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblGLRecap] PRIMARY KEY CLUSTERED 
(
	[intGLDetailId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX IX_tblGLRecap ON tblGLRecap (strTransactionId, intTransactionId)



