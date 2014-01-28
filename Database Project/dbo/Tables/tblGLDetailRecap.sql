CREATE TABLE [dbo].[tblGLDetailRecap] (
    [intGLDetailID]      INT              IDENTITY (1, 1) NOT NULL,
    [strTransactionID]   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
    [intTransactionID]   INT              NULL,
    [dtmDate]            DATETIME         NOT NULL,
    [strBatchID]         NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountID]       INT              NULL,
    [strAccountGroup]    NVARCHAR (30)    COLLATE Latin1_General_CI_AS NULL,
    [dblDebit]           NUMERIC (18, 6)  NULL,
    [dblCredit]          NUMERIC (18, 6)  NULL,
    [dblDebitUnit]       NUMERIC (18, 6)  NULL,
    [dblCreditUnit]      NUMERIC (18, 6)  NULL,
    [strDescription]     NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
    [strCode]            NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
    [strReference]       NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strJobID]           NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyID]      INT              NULL,
    [dblExchangeRate]    NUMERIC (38, 20) NOT NULL,
    [dtmDateEntered]     DATETIME         NOT NULL,
    [dtmTransactionDate] DATETIME         NULL,
    [ysnIsUnposted]      BIT              NOT NULL,
    [intConcurrencyId]   INT              NOT NULL DEFAULT 1,
    [intUserID]          INT              NULL,
    [strTransactionForm] NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strModuleName]      NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strUOMCode]         CHAR (6)         COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLDetailRecap] PRIMARY KEY CLUSTERED ([intGLDetailID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblGLDetailRecap]
    ON [dbo].[tblGLDetailRecap]([strTransactionID] ASC, [intTransactionID] ASC);

