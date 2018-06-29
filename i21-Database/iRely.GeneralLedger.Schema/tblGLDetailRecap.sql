CREATE TABLE [dbo].[tblGLDetailRecap] (
    [intGLDetailId]             INT              IDENTITY (1, 1) NOT NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]              INT              NULL,
    [dblDebit]                  NUMERIC (18, 6)  NULL,
    [dblCredit]                 NUMERIC (18, 6)  NULL,
    [dblDebitUnit]              NUMERIC (18, 6)  NULL,
    [dblCreditUnit]             NUMERIC (18, 6)  NULL,
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
    [strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
    [intTransactionId]          INT              NULL,
    [strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign] NUMERIC(18, 9) NULL, 
    [dblDebitReport] NUMERIC(18, 9) NULL, 
	[dblCreditForeign] NUMERIC(18, 9) NULL, 
    [dblCreditReport] NUMERIC(18, 9) NULL, 
);

GO
CREATE NONCLUSTERED INDEX [IX_tblGLDetailRecap]
    ON [dbo].[tblGLDetailRecap]([strTransactionId] ASC, [intTransactionId] ASC);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'G L Detail Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intGLDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Batch Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strBatchId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblDebit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblDebitUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Unit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblCreditUnit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Exchange Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblExchangeRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Entered' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dtmDateEntered' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dtmTransactionDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Line Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strJournalLineDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Line No' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intJournalLineNo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Unposted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'ysnIsUnposted' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intEntityId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Form' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strTransactionForm' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'strModuleName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblDebitForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblDebitReport' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Foreign' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblCreditForeign' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Credit Report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLDetailRecap', @level2type=N'COLUMN',@level2name=N'dblCreditReport' 
GO