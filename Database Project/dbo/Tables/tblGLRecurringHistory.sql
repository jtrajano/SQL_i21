CREATE TABLE [dbo].[tblGLRecurringHistory] (
    [intRecurringHistoryID] INT           IDENTITY (1, 1) NOT NULL,
    [strTransactionType]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalRecurringID] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strGroup]              NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalID]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strReference]          NVARCHAR (75) COLLATE Latin1_General_CI_AS NULL,
    [dtmLastProcess]        DATETIME      CONSTRAINT [DF_tblGLRecurringHistory_dtmLastProcess] DEFAULT (getdate()) NULL,
    [dtmNextProcess]        DATETIME      CONSTRAINT [DF_tblGLRecurringHistory_dtmNextProcess] DEFAULT (getdate()) NULL,
    [dtmProcessDate]        DATETIME      CONSTRAINT [DF_tblGLRecurringHistory_dtmProcessDate] DEFAULT (getdate()) NULL,
    [intConcurrencyID]      INT           CONSTRAINT [DF_tblGLRecurringHistory_intConcurrencyID] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLRecurringHistory] PRIMARY KEY CLUSTERED ([intRecurringHistoryID] ASC)
);

