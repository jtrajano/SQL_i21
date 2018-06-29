CREATE TABLE [dbo].[tblGLDetailSync] (
    [intGLDetailId]             INT              IDENTITY (1, 1) NOT NULL,
    [intCompanyId] [int] NULL,
    [intMultiCompanyId] [int]   NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]              INT              NULL,
    [dblDebit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetailSync_dblDebit]  DEFAULT ((0)),
    [dblCredit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetailSync_dblCredit]  DEFAULT ((0)),
    [dblDebitUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetailSync_dblDebitUnit]  DEFAULT ((0)),
    [dblCreditUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetailSync_dblCreditUnit]  DEFAULT ((0)),
    [strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
    [strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId]             INT              NULL,
    [dblExchangeRate]           NUMERIC (38, 20) NOT NULL,
    [dtmDateEntered]            DATETIME         NOT NULL,
    [dtmTransactionDate]        DATETIME         NULL,
    [strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
    [ysnIsUnposted]             BIT              NOT NULL,    
    [intUserId]                 INT              NULL,
    [intEntityId]				INT              NULL,
    [strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL,
    [intTransactionId]          INT              NULL,
    [strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetailSync_dblDebitForeign]  DEFAULT ((0)),
    [dblDebitReport] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetailSync_dblDebitReport]  DEFAULT ((0)),
    [dblCreditForeign] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetailSync_dblCreditForeign]  DEFAULT ((0)),
    [dblCreditReport] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetailSync_dblCreditReport]  DEFAULT ((0)),
    [dblReportingRate] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetailSync_dblReportingRate]  DEFAULT ((0)),
    [dblForeignRate] NUMERIC(18, 9) NULL, 
    [intReconciledId] INT NULL, 
    [dtmReconciled] DATETIME NULL, 
    [ysnReconciled] BIT NULL, 
	[ysnRevalued] BIT NULL,
	[ysnExported] BIT NULL,
	[dtmExportedDate] DATETIME NULL,
    CONSTRAINT [PK_tblGLDetailSync] PRIMARY KEY CLUSTERED ([intGLDetailId] ASC),
    CONSTRAINT [FK_tblGLDetailSync_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLDetailSync_tblSMMultiCompany] FOREIGN KEY([intMultiCompanyId]) REFERENCES [dbo].[tblSMMultiCompany] ([intMultiCompanyId])
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intGLDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Multi Company Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intMultiCompanyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batch Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strBatchId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblDebitUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblCreditUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exchange Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblExchangeRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Entered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dtmDateEntered' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dtmTransactionDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Line Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strJournalLineDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Line No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intJournalLineNo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Unposted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'ysnIsUnposted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Form' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strTransactionForm' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'strModuleName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblDebitForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblDebitReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblCreditForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblCreditReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reporting Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblReportingRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dblForeignRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reconciled Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'intReconciledId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Reconciled' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dtmReconciled' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Reconciled?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'ysnReconciled' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Revalued?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'ysnRevalued' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Exported?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'ysnExported' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exported Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailSync', @level2type=N'COLUMN',@level2name=N'dtmExportedDate' 
GO