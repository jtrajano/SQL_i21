﻿CREATE TABLE [dbo].[tblGLJournalRecurring] (
    [intJournalRecurringId] INT              IDENTITY (1, 1) NOT NULL,
    [strJournalRecurringId] NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [strDescription]        NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strStoreId]            NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]               DATETIME         NULL,
    [intCurrencyId]         INT              NULL,
    [dblExchangeRate]       NUMERIC (38, 20) NULL,
    [strReference]          NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT              DEFAULT 1 NOT NULL,
    [strMode]               NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [strUserMode]           NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intAdvanceReminder]    INT              NULL,
    [dtmStartDate]          DATETIME         NOT NULL,
    [dtmEndDate]            DATETIME         NOT NULL,
    [strRecurringPeriod]    NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [intInterval]           INT              NULL,
    [strDays]               NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [dtmNextDueDate]        DATETIME         NULL,
    [dtmSingle]             DATETIME         NULL,
    [dtmLastDueDate]        DATETIME         NULL,
    [intMonthInterval]      INT              NULL,
    [dtmReverseDate]        DATETIME         NULL,
    [intJournalId] INT NULL, 
    [ysnImported] BIT NULL, 
    CONSTRAINT [PK_tblGLJournalRecurring] PRIMARY KEY CLUSTERED ([intJournalRecurringId] ASC)
);

