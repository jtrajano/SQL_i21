CREATE TABLE [dbo].[tblGLJournal] (
    [intJournalID]       INT              IDENTITY (1, 1) NOT NULL,
    [dtmReverseDate]     DATETIME         NULL,
    [strJournalID]       NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType] NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]            DATETIME         NULL,
    [strReverseLink]     NVARCHAR (25)    COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyID]      INT              NULL,
    [dblExchangeRate]    NUMERIC (38, 20) NULL,
    [dtmPosted]          DATETIME         NULL,
    [strDescription]     NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]          BIT              NULL,
    [intConcurrencyID]   INT              NULL,
    [dtmJournalDate]     DATETIME         NULL,
    [intUserID]          INT              NULL,
    [strSourceID]        NVARCHAR (10)    COLLATE Latin1_General_CI_AS NULL,
    [strJournalType]     NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strRecurringStatus] NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strSourceType]      NVARCHAR (10)    COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLJournal] PRIMARY KEY CLUSTERED ([intJournalID] ASC)
);

