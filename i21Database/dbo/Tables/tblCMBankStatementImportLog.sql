CREATE TABLE [dbo].[tblCMBankStatementImportLog](
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] [datetime] NULL,
	[intEntityId] [int] NULL,
	[intBankStatementImportId] [int] NULL,
	[strError] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[strBankStatementImportId] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strCategory] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
	[intTaskId] INT NULL,
 CONSTRAINT [PK_tblCMBankStatementImportLog] PRIMARY KEY CLUSTERED 
(
	[intId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

