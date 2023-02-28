
CREATE TABLE [dbo].[tblGLAuditorReportByAccountId](
	[intAuditorReportId] [int] IDENTITY(1,1) NOT NULL,
	[intGLDetailId] [int] NULL,
	[strCurrency] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strAccountId] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblBeginningBalance] [numeric](38, 6) NULL,
	[dblEndingBalance] [numeric](38, 6) NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblBeginningBalanceForeign] [numeric](38, 9) NULL,
	[dblEndingBalanceForeign] [numeric](38, 9) NULL,
	[dblDebitForeign] [numeric](18, 9) NULL,
	[dblCreditForeign] [numeric](18, 9) NULL,
	[intEntityId] [int] NULL,
	[strBatchId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[intAccountId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[dtmDateEntered] [datetime] NULL,
	[dblDebitReport] [numeric](18, 9) NULL,
	[dblCreditReport] [numeric](18, 9) NULL,
	[strUserName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strCode] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strComments] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strJournalLineDescription] [nvarchar](300) COLLATE Latin1_General_CI_AS NULL,
	[strUOMCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] [int] NULL,
	[strTransactionType] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strModuleName] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strDocument] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[dblExchangeRate] [numeric](38, 20) NULL,
	[dblSourceUnitDebit] [numeric](18, 9) NULL,
	[dblSourceUnitCredit] [numeric](18, 9) NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
	[strCommodityCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSourceDocumentId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLocation] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyLocation] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSourceUOMId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSourceEntity] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyID] [int] NOT NULL,
 CONSTRAINT [PK_tblGLAuditorReportByAccountId] PRIMARY KEY CLUSTERED 
(
	[intAuditorReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


