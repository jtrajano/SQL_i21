﻿CREATE TABLE [dbo].[tblGLDetail] (
    [intGLDetailId]             INT              IDENTITY (1, 1) NOT NULL,
    [dtmDate]                   DATETIME         NOT NULL,
    [strBatchId]                NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]              INT              NULL,
    [dblDebit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblDebit]  DEFAULT ((0)),
    [dblCredit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblCredit]  DEFAULT ((0)),
    [dblDebitUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblDebitUnit]  DEFAULT ((0)),
    [dblCreditUnit] [numeric](18, 6) NULL CONSTRAINT [DF_tblGLDetail_dblCreditUnit]  DEFAULT ((0)),
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
	[dblDebitForeign] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblDebitForeign]  DEFAULT ((0)),
    [dblDebitReport] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblDebitReport]  DEFAULT ((0)),
    [dblCreditForeign] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblCreditForeign]  DEFAULT ((0)),
    [dblCreditReport] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblCreditReport]  DEFAULT ((0)),
    [dblReportingRate] [numeric](18, 9) NULL CONSTRAINT [DF_tblGLDetail_dblReportingRate]  DEFAULT ((0)),
    [dblForeignRate] NUMERIC(18, 9) NULL, 
    [intReconciledId] INT NULL, 
    [dtmReconciled] DATETIME NULL, 
    [ysnReconciled] BIT NULL, 
    CONSTRAINT [PK_tblGL] PRIMARY KEY CLUSTERED ([intGLDetailId] ASC),
    CONSTRAINT [FK_tblGL_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);

