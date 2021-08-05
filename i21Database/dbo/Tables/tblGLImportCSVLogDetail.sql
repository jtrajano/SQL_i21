CREATE TABLE [dbo].[tblGLImportCSVLogDetail](
	[intImportLogDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intImportLogId] [int] NULL,
	[intLineNo] [int] NULL,
	[strKeyId]	nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strEvent] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLImportCSVLogDetail] PRIMARY KEY CLUSTERED 
(
	[intImportLogDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblGLImportCSVLogDetail] ADD  CONSTRAINT [FK_tblGLImportCSVLogDetail_tblGLImportCSVLog] FOREIGN KEY([intImportLogId])
REFERENCES [dbo].[tblGLImportCSVLog] ([intImportLogId])
GO

ALTER TABLE [dbo].[tblGLImportCSVLogDetail] CHECK CONSTRAINT [FK_tblGLImportCSVLogDetail_tblGLImportCSVLog]
GO

