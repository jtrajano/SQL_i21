CREATE TABLE [dbo].[tblRMArchive] (
    [intArchiveId]     INT             IDENTITY (1, 1) NOT NULL,
    [blbDocument]      VARBINARY (MAX) NULL,
    [strName]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]          DATETIME        NULL,
    [strDescription]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strUserId]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT             DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMArchive] PRIMARY KEY CLUSTERED ([intArchiveId] ASC)
);

