
CREATE TABLE [dbo].[tblAPImportLogDetail](
	[intImportLogDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intImportLogId] [int] NULL,
	[strEventDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblAPImportLogDetail] PRIMARY KEY CLUSTERED 
(
	[intImportLogDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblAPImportLogDetail] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblAPImportLogDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_tblAPImportLogDetail_tblAPImportLog] FOREIGN KEY([intImportLogId])
REFERENCES [dbo].[tblAPImportLog] ([intImportLogId])
GO

ALTER TABLE [dbo].[tblAPImportLogDetail] CHECK CONSTRAINT [FK_tblAPImportLogDetail_tblAPImportLog]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblAPImportLogDetail', @level2type=N'COLUMN',@level2name=N'intImportLogDetailId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foeign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblAPImportLogDetail', @level2type=N'COLUMN',@level2name=N'intImportLogId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Event Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblAPImportLogDetail', @level2type=N'COLUMN',@level2name=N'strEventDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblAPImportLogDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO



