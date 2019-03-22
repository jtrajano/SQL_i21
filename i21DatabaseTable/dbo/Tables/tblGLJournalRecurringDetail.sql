CREATE TABLE [dbo].[tblGLJournalRecurringDetail] (
    [intJournalRecurringDetailId] INT              IDENTITY (1, 1) NOT NULL,
    [intLineNo]                   INT              NULL,
    [ysnAllocatingEntry]          BIT              NULL,
    [intJournalRecurringId]       INT              NOT NULL,
    [dtmDate]                     DATETIME         NULL,
    [intAccountId]                INT              NULL,
    [intCurrencyId]               INT              NULL,
    [dblExchangeRate]             NUMERIC (38, 20) NULL,
    [dblDebit]                    NUMERIC (18, 6)  NULL,
    [dblDebitRate]                NUMERIC (18, 6)  NULL,
    [dblCredit]                   NUMERIC (18, 6)  NULL,
    [dblCreditRate]               NUMERIC (18, 6)  NULL,
    [strNameId]                   NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intJobId]                    INT              NULL,
    [strLink]                     NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strDescription]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]            INT              DEFAULT 1 NOT NULL,
    [dblUnitsInLBS]               NUMERIC (18, 6)  NULL,
    [strDocument]                 NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strComments]                 NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strReference]                NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strUOMCode]                  NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [dblDebitUnit]                NUMERIC (18, 6)  NULL,
    [dblCreditUnit]               NUMERIC (18, 6)  NULL,
    CONSTRAINT [PK_tblGLJournalRecurringDetail] PRIMARY KEY CLUSTERED ([intJournalRecurringDetailId] ASC),
    CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLJournalRecurring] FOREIGN KEY ([intJournalRecurringId]) REFERENCES [dbo].[tblGLJournalRecurring] ([intJournalRecurringId]) ON DELETE CASCADE
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intJournalRecurringDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Line Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intLineNo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Allocating Entry' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'ysnAllocatingEntry' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Recurring Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intJournalRecurringId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exchange Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblExchangeRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblDebitRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblCreditRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strNameId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Job Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intJobId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Link' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strLink' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Units In lbs.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblUnitsInLBS' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strDocument' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strComments' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit Of Measure Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'strUOMCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblDebitUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournalRecurringDetail', @level2type=N'COLUMN',@level2name=N'dblCreditUnit' 
GO