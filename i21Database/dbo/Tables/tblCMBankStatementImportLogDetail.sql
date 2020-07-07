CREATE TABLE [dbo].[tblCMBankStatementImportLogDetail](
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[intImportBankStatementLogId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[intBankStatementImportId] [int] NULL,
	[strError] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[strBankStatementImportId] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strCategory] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	intLineNo INT NULL,
	[intConcurrencyId] [int] NULL,
	[strTaskId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblCMBankStatementImportLogDetail] PRIMARY KEY CLUSTERED 
(
	[intId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

