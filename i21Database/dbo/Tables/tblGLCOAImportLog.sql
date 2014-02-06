CREATE TABLE [dbo].[tblGLCOAImportLog] (
    [intImportLogID]       INT           IDENTITY (1, 1) NOT NULL,
    [strEvent]             NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strIrelySuiteVersion] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intUserID]            INT           NULL,
    [dtmDate]              DATETIME      NULL,
    [strMachineName]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strJournalType]       NCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAImportLog] PRIMARY KEY CLUSTERED ([intImportLogID] ASC)
);

