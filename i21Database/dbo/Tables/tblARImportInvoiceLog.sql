CREATE TABLE [dbo].[tblARImportInvoiceLog](
	[intImportLogId]	INT NOT NULL IDENTITY(1,1),
	[strData]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDataType]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[strDescription]	NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]		INT NOT NULL,
	[strLogKey]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate]			DATETIME NOT NULL,
	[intConcurrencyId]	INT NOT NULL,
 CONSTRAINT [PK_tblARImportInvoiceLog] PRIMARY KEY CLUSTERED 
(
	[intImportLogId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblARImportInvoiceLog] ADD  DEFAULT ((0)) FOR [intConcurrencyId]
GO



