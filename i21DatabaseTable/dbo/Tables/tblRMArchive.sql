CREATE TABLE [dbo].[tblRMArchive] (
    [intArchiveId]     INT             IDENTITY (1, 1) NOT NULL,
    [blbDocument]      VARBINARY (MAX) NULL,
    [strDocumentKey]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strName]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]          DATETIME        NULL,
    [dtmTimeStart]     DATETIME        NULL,
    [dtmTimeEnd]       DATETIME        NULL,
    [strDescription]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intUserId]        INT             NULL,
    [strRunSummary]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strUserName]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strServerName]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDatabaseName]  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strStatus]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnIsArchived]    BIT             NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF__tblRMArch__intCo__689361F1] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMArchive] PRIMARY KEY CLUSTERED ([intArchiveId] ASC)
);





