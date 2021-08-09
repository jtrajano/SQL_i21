
CREATE TABLE [dbo].[tblFAImportLogDetail](
	[intImportLogId] [int] NULL,
	[intImportLogDetailId] [int] IDENTITY(1,1) NOT NULL,
	[strAssetId] [nvarchar](20) COLLATE Latin1_General_CI_AS  NULL,
	[intLineNo] [int] NULL,
	[strEvent] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblFAImportLogDeteail] PRIMARY KEY CLUSTERED 
(
	[intImportLogDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblFAImportLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblFAImportLogDeteail_tblFAImportLog] FOREIGN KEY([intImportLogId])
REFERENCES [dbo].[tblFAImportLog] ([intImportLogId])
GO

ALTER TABLE [dbo].[tblFAImportLogDetail] CHECK CONSTRAINT [FK_tblFAImportLogDeteail_tblFAImportLog]
GO

