﻿CREATE TABLE [dbo].[tblGLJournal] (
    [intJournalId]       INT              IDENTITY (1, 1) NOT NULL,
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
	intExchangeRateDetailId INT NULL,
    CONSTRAINT [PK_tblGLJournal] PRIMARY KEY CLUSTERED ([intJournalId] ASC),
	CONSTRAINT [FK_tblGLJournal_tblSMCurrencyExchangeRateDetail] FOREIGN KEY([intExchangeRateDetailId])REFERENCES [dbo].[tblSMCurrencyExchangeRateDetail] ([intCurrencyExchangeRateDetailId]),
	CONSTRAINT [FK_tblGLJournal_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblGLJournal_tblGLFiscalYearPeriod] FOREIGN KEY([intFiscalPeriodId], [intFiscalYearId])REFERENCES [dbo].[tblGLFiscalYearPeriod] ([intGLFiscalYearPeriodId], [intFiscalYearId])
);

