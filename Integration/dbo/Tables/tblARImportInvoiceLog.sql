CREATE TABLE [dbo].[tblARImportInvoiceLog](
	[intImportLogId] [int] IDENTITY(1,1) NOT NULL,
	[strDescription] [nvarchar](200) NULL,
	[intEntityId] [int] NOT NULL,
	[strLogKey] [nvarchar](100) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblARImportInvoiceLog] PRIMARY KEY CLUSTERED 
(
	[intImportLogId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblARImportInvoiceLog] ADD  DEFAULT ((0)) FOR [intConcurrencyId]
GO



