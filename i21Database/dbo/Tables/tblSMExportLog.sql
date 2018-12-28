CREATE TABLE [dbo].[tblSMExportLog]
(
    [intExportLogId]        INT NOT NULL PRIMARY KEY IDENTITY,
    [intEntityId]           [int] NOT NULL,
    [strContextId]          [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strModule]				[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
    [strName]               [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTab]				[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
    [strType]               [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
    [strQueueType]          [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
    [strJsonData]           [text] COLLATE Latin1_General_CI_AS NULL,
    [strStatus]             [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strMessage]            [text] COLLATE Latin1_General_CI_AS NULL,
    [intTotalColumns]       [int] NULL,
    [intTotalRecords]       [int] NULL,
    [dblExecutionTime]      DECIMAL(18, 4) NULL,
    [dtmCreated]            [datetime] NULL DEFAULT (GETUTCDATE()),
    [dtmStarted]            [datetime] NULL,
    [dtmProcessed]          [datetime] NULL,
    [dtmCompleted]          [datetime] NULL,
    [intConcurrencyId]      [int] NOT NULL DEFAULT (1),
    CONSTRAINT [FK_tblSMExportLog_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE
)
