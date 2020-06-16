CREATE TABLE [dbo].[tblCMBankStatementImportLog](
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionId] [nvarchar](40) NULL,
	[dtmDateCreated] [datetime] NULL,
	[intEntityId] [int] NULL,
	[intBankStatementImportId] [int] NULL,
	[strError] [nvarchar](500) NULL,
	[strBankStatementImportId] [nvarchar](20) NULL,
	[strCategory] [nvarchar](50) NULL
) ON [PRIMARY]
GO

