﻿CREATE TABLE [dbo].[tblGLRecurringHistory] (
    [intRecurringHistoryId] INT           IDENTITY (1, 1) NOT NULL,
    [strTransactionType]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalRecurringId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strGroup]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalId]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strReference]          NVARCHAR (75) COLLATE Latin1_General_CI_AS NULL,
    [dtmLastProcess]        DATETIME      DEFAULT (getdate()) NULL,
    [dtmNextProcess]        DATETIME      DEFAULT (getdate()) NULL,
    [dtmProcessDate]        DATETIME      DEFAULT (getdate()) NULL,
    [intConcurrencyId]      INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLRecurringHistory] PRIMARY KEY CLUSTERED ([intRecurringHistoryId] ASC)
);

