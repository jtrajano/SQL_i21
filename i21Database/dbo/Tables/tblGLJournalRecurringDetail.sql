﻿CREATE TABLE [dbo].[tblGLJournalRecurringDetail] (
    [intJournalRecurringDetailID] INT              IDENTITY (1, 1) NOT NULL,
    [intLineNo]                   INT              NULL,
    [ysnAllocatingEntry]          BIT              NULL,
    [intJournalRecurringID]       INT              NOT NULL,
    [dtmDate]                     DATETIME         NULL,
    [intAccountID]                INT              NULL,
    [intCurrencyID]               INT              NULL,
    [dblExchangeRate]             NUMERIC (38, 20) NULL,
    [dblDebit]                    NUMERIC (18, 6)  NULL,
    [dblDebitRate]                NUMERIC (18, 6)  NULL,
    [dblCredit]                   NUMERIC (18, 6)  NULL,
    [dblCreditRate]               NUMERIC (18, 6)  NULL,
    [strNameID]                   NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intJobID]                    INT              NULL,
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
    CONSTRAINT [PK_tblGLJournalRecurringDetail] PRIMARY KEY CLUSTERED ([intJournalRecurringDetailID] ASC),
    CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLJournalRecurring] FOREIGN KEY ([intJournalRecurringID]) REFERENCES [dbo].[tblGLJournalRecurring] ([intJournalRecurringID])
);

