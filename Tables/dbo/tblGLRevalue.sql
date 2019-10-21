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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intConsolidationId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Consolidation Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'strConsolidationNumber' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'G L Fiscal Year Period Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intGLFiscalYearPeriodId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intFiscalYearId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Reverse Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'dtmReverseDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Functional Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intFunctionalCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intTransactionCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Forex Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'dblForexRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Rate Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intRateTypeId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Posted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'ysnPosted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reverse Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intReverseId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalue', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO





