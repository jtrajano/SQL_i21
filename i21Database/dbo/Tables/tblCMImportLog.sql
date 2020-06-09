CREATE TABLE [dbo].[tblCMImportLog](
	[intImportLogId] [int] IDENTITY(1,1) NOT NULL,
	[strEvent] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strMessage] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strVersion] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[dtmDate] [datetime] NULL,
	[intSuccessCount] [int] NULL,
	[intErrorCount] [int] NULL,
	[strFilePath] [nvarchar](300) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strImportLogId] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblCMImportLog] PRIMARY KEY CLUSTERED 
(
	[intImportLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMImportLog] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'intImportLogId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Event' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'strEvent'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Message' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'strMessage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Irely Suite Version' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'strVersion'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'intEntityId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'dtmDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Success Count' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'intSuccessCount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Error Count' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'intErrorCount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'File Path' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'strFilePath'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblCMImportLog', @level2type=N'COLUMN',@level2name=N'intConcurrencyId'
GO

