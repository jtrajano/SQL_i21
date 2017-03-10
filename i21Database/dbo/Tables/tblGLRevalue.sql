CREATE TABLE [dbo].[tblGLRevalue](
	[intConsolidationId] [int] IDENTITY(1,1) NOT NULL,
	[strConsolidationNumber]   NVARCHAR(20) COLLATE Latin1_General_CI_AS ,
	[intGLFiscalYearPeriodId] [int] NULL,
	[intFiscalYearId] [int] NULL,
	[dtmDate] [datetime] NULL,
	[dtmReverseDate] [datetime] NULL,
	[intFunctionalCurrencyId] [int] NOT NULL,
	[intTransactionCurrencyId] [int] NOT NULL,
	[strTransactionType] [nvarchar](20) COLLATE Latin1_General_CI_AS,
	[dblForexRate] [numeric](10, 6) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intRateTypeId] [int] NOT NULL,
	[ysnPosted] [bit] NULL CONSTRAINT [DF_tblGLRevalue_ysnPosted]  DEFAULT ((0)),
	[intReverseId] [int] NULL,
	[strDescription] [nvarchar](300) COLLATE Latin1_General_CI_AS,
	[intEntityId] INT NULL,
 CONSTRAINT [PK_tblGLRevalue] PRIMARY KEY CLUSTERED
(
	[intConsolidationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO




