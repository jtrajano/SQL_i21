CREATE TABLE [dbo].[tblGLTrialBalance](
	[intTrialBalanceId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountId] [int] NOT NULL,
	[MTDBalance] [numeric](38, 6) NULL,
	[YTDBalance] [numeric](38, 6) NULL,
	[intGLFiscalYearPeriodId] [int] NULL,
	[intConcurrencyId] [int] NULL,
	[dtmDateModified] [datetime] NULL,
 CONSTRAINT [PK_tblGLTrialBalance] PRIMARY KEY CLUSTERED 
(
	[intTrialBalanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

