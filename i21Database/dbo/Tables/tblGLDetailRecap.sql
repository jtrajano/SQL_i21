CREATE TABLE [dbo].[tblGLDetailRecap] (
    [intGLDetailId]             INT              IDENTITY (1, 1) NOT NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
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
    [intConcurrencyId]          INT              DEFAULT 1 NOT NULL
);

GO
CREATE NONCLUSTERED INDEX [IX_tblGLDetailRecap]
    ON [dbo].[tblGLDetailRecap]([strTransactionId] ASC, [intTransactionId] ASC);

