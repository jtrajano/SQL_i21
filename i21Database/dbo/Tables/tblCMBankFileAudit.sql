﻿CREATE TABLE [dbo].[tblCMBankFileAudit](
	[intBankFileAuditId] [int] IDENTITY(1,1) NOT NULL,
	[intBankAccountId] INT NULL,
	[dtmCreated] [datetime] NULL,
	[strFileName][nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[blbBankFile] [varbinary](max) NULL,
	[strDescription][nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_tblCMBankFileAudit] PRIMARY KEY CLUSTERED 
(
	[intBankFileAuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
) TEXTIMAGE_ON [PRIMARY]
