CREATE TABLE [dbo].[tblGLJournal] (
    [intJournalId]       INT              IDENTITY (1, 1) NOT NULL,
	[intCompanyId]		 INT			  NULL,
    [dtmReverseDate]     DATETIME         NULL,
    [strJournalId]       NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType] NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]            DATETIME         NULL,
    [strReverseLink]     NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId]      INT              NULL,
    [dblExchangeRate]    NUMERIC (38, 20) NULL,
    [dtmPosted]          DATETIME         NULL,
    [strDescription]     NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]          BIT              NULL,
    [intConcurrencyId]   INT              DEFAULT 1 NOT NULL,
    [dtmDateEntered]     DATETIME         DEFAULT (GETDATE()) NULL,
    [intUserId]          INT              NULL,
    [intEntityId]        INT              NULL,
    [strSourceId]        NVARCHAR (10)    COLLATE Latin1_General_CI_AS NULL,
    [strJournalType]     NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strRecurringStatus] NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strSourceType]      NVARCHAR (10)    COLLATE Latin1_General_CI_AS NULL,
    [intFiscalYearId] INT NULL, 
    [intFiscalPeriodId] INT NULL, 
    [intJournalIdToReverse] INT NULL, 
    [ysnReversed] BIT NULL, 
    [ysnRecurringTemplate] BIT NULL, 
	[ysnExported] BIT NULL,
	[intCurrencyExchangeRateId] INT NULL,
    CONSTRAINT [PK_tblGLJournal] PRIMARY KEY CLUSTERED ([intJournalId] ASC),
	CONSTRAINT [FK_tblGLJournal_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblGLJournal_tblGLFiscalYearPeriod] FOREIGN KEY([intFiscalPeriodId], [intFiscalYearId])REFERENCES [dbo].[tblGLFiscalYearPeriod] ([intGLFiscalYearPeriodId], [intFiscalYearId]),
	CONSTRAINT [FK_tblGLJournal_tblSMCurrencyExchangeRate] FOREIGN KEY([intCurrencyExchangeRateId])REFERENCES [dbo].[tblSMCurrencyExchangeRate] ([intCurrencyExchangeRateId])
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intJournalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reverse Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'dtmReverseDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strJournalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Posting Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reverse Link' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strReverseLink' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exchange Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'dblExchangeRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Posted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'dtmPosted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Posted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'ysnPosted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Entered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'dtmDateEntered' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strSourceId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strJournalType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Recurring Status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strRecurringStatus' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'strSourceType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intFiscalYearId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Period Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intFiscalPeriodId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id To Reverse' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intJournalIdToReverse' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reversed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'ysnReversed' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Recurring Template' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'ysnRecurringTemplate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Exchange Rate Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'intCurrencyExchangeRateId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exported' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLJournal', @level2type=N'COLUMN',@level2name=N'ysnExported' 
GO