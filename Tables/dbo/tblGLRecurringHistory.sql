CREATE TABLE [dbo].[tblGLRecurringHistory] (
    [intRecurringHistoryId] INT           IDENTITY (1, 1) NOT NULL,
    [strTransactionType]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalRecurringId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strGroup]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalId]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strReference]          NVARCHAR (75) COLLATE Latin1_General_CI_AS NULL,
    [dtmLastProcess]        DATETIME      DEFAULT (getdate()) NULL,
    [dtmNextProcess]        DATETIME      DEFAULT (getdate()) NULL,
    [dtmProcessDate]        DATETIME      DEFAULT (getdate()) NULL,
    [intConcurrencyId]      INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLRecurringHistory] PRIMARY KEY CLUSTERED ([intRecurringHistoryId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'intRecurringHistoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Recurring Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'strJournalRecurringId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'strGroup' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'strJournalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Last Process' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'dtmLastProcess' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Next Process' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'dtmNextProcess' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Process Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'dtmProcessDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRecurringHistory', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
