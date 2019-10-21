CREATE TABLE [dbo].[tblGLJournalRecurring] (
    [intJournalRecurringId] INT              IDENTITY (1, 1) NOT NULL,
    [strJournalRecurringId] NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strDescription]        NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strStoreId]            NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]               DATETIME         NULL,
    [intCurrencyId]         INT              NULL,
    [dblExchangeRate]       NUMERIC (38, 20) NULL,
    [strReference]          NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT              DEFAULT 1 NOT NULL,
    [strMode]               NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [strUserMode]           NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAdvanceReminder]    INT              NULL,
    [dtmStartDate]          DATETIME         NOT NULL,
    [dtmEndDate]            DATETIME         NOT NULL,
    [strRecurringPeriod]    NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intInterval]           INT              NULL,
    [strDays]               NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [dtmNextDueDate]        DATETIME         NULL,
    [dtmSingle]             DATETIME         NULL,
    [dtmLastDueDate]        DATETIME         NULL,
    [intMonthInterval]      INT              NULL,
    [dtmReverseDate]        DATETIME         NULL,
    [intJournalId] INT NULL, 
    [ysnImported] BIT NULL, 
    CONSTRAINT [PK_tblGLJournalRecurring] PRIMARY KEY CLUSTERED ([intJournalRecurringId] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intJournalRecurringId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Recurring Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strJournalRecurringId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Store Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strStoreId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exchange Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dblExchangeRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strMode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Mode' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strUserMode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Advance Reminder' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intAdvanceReminder' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Start Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmStartDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'End Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmEndDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Recurring Period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strRecurringPeriod' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Interval' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intInterval' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Days' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'strDays' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Next Due Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmNextDueDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Single' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmSingle' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Last Due Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmLastDueDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Month Interval' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intMonthInterval' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Reverse Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'dtmReverseDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'intJournalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Imported?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurring', @level2type=N'COLUMN',@level2name=N'ysnImported' 
GO