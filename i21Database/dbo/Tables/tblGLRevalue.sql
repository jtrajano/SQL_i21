CREATE TABLE [dbo].[tblGLRevalue](
	[intConsolidationId] [int] IDENTITY(1,1) NOT NULL,
	[strConsolidationNumber]  NVARCHAR(20) COLLATE Latin1_General_CI_AS ,
	[intGLFiscalYearPeriodId] [int] NOT NULL,
	[dtmDate] [date] NOT NULL,
	[dtmReverseDate] [date] NOT NULL,
	[intFunctionalCurrencyId] [int] NOT NULL,
	[intTransactionCurrencyId] [int] NOT NULL,
	[strTransactionType] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblForexRate] [numeric](10, 6) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblGLRevalue] PRIMARY KEY CLUSTERED 
(
	[intConsolidationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO




