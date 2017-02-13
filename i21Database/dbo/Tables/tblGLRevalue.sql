CREATE TABLE [dbo].[tblGLRevalue](
	[intConsolidationId] [int] IDENTITY(1,1) NOT NULL,
	[intFiscalPeriod] [int] NOT NULL,
	[dtmReverseDate] [date] NOT NULL,
	[intFunctionalCurrencyId] [int] NOT NULL,
	[strTransactionType] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblForexRate] [numeric](10, 6) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblGLRevalue] PRIMARY KEY CLUSTERED 
(
	[intConsolidationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblGLRevalue]  WITH CHECK ADD  CONSTRAINT [FK_tblGLRevalue_tblGLFiscalYearPeriod] FOREIGN KEY([intFiscalPeriod])
REFERENCES [dbo].[tblGLFiscalYearPeriod] ([intGLFiscalYearPeriodId])
GO

ALTER TABLE [dbo].[tblGLRevalue] CHECK CONSTRAINT [FK_tblGLRevalue_tblGLFiscalYearPeriod]
GO

