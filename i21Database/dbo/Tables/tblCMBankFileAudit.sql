CREATE TABLE [dbo].[tblCMBankFileAudit](
	[intBankFileAuditId] [int] IDENTITY(1,1) NOT NULL,
	[intBankAccountId] [nvarchar](100) NULL,
	[intUserId] [int] NULL,
	[dtmDate] [datetime] NULL,
	[strFileName][nvarchar](200) NULL,
	[blbBankFile] [varbinary](max) NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblCMBankFileAudit] PRIMARY KEY CLUSTERED 
(
	[intBankFileAuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]