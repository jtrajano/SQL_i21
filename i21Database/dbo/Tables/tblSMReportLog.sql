CREATE TABLE [dbo].[tblSMReportLog]
(
    [intReportLogId]        INT NOT NULL PRIMARY KEY IDENTITY,
    [intEntityId]           [int] NOT NULL,
    [strContextId]          [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
    [strGroup]               [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
    [strReport]               [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
    [strJsonData]           [text] COLLATE Latin1_General_CI_AS NULL,
    [strStatus]             [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMessage]            [text] COLLATE Latin1_General_CI_AS NULL,
    [intExecutionTime]      [int] NULL,
    [dtmCreated]            [datetime] NULL DEFAULT (GETUTCDATE()), 
    [dtmStarted]            [datetime] NULL,
    [dtmProcessed]          [datetime] NULL,
    [dtmCompleted]          [datetime] NULL, 
    [intConcurrencyId]      [int] NOT NULL DEFAULT (1),
    CONSTRAINT [FK_tblSMReportLog_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE
)
