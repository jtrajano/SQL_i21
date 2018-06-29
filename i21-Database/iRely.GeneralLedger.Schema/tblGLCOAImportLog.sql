CREATE TABLE [dbo].[tblGLCOAImportLog] (
    [intImportLogId]       INT           IDENTITY (1, 1) NOT NULL,
    [strEvent]             NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strIrelySuiteVersion] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intUserId]            INT           NULL,
    [intEntityId]          INT           NULL,
    [dtmDate]              DATETIME      NULL,
    [strMachineName]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalType]       NCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
	[intSuccessCount]	   INT NULL,
	[intErrorCount]		   INT NULL,
	[strFilePath]		   NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,	
    [intConcurrencyId]     INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAImportLog] PRIMARY KEY CLUSTERED ([intImportLogId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'intImportLogId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Event' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'strEvent' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Irely Suite Version' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'strIrelySuiteVersion' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Machine Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'strMachineName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'strJournalType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLog', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
