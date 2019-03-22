CREATE TABLE [dbo].[tblCFImportLog] (
    [intImportLogId]       INT            IDENTITY (1, 1) NOT NULL,
    [strEvent]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strIrelySuiteVersion] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intUserId]            INT            NULL,
    [intEntityId]          INT            NULL,
    [dtmDate]              DATETIME       NULL,
    [strMachineName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strImportType]        NCHAR (50)     COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblCFImportLog_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFImportLog] PRIMARY KEY CLUSTERED ([intImportLogId] ASC)
);

