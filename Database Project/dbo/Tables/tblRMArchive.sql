CREATE TABLE [dbo].[tblRMArchive] (
    [intArchiveID]   INT             IDENTITY (1, 1) NOT NULL,
    [blbDocument]    VARBINARY (MAX) NULL,
    [strName]        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]        DATETIME        NULL,
    [strDescription] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strUserID]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblRMArchive] PRIMARY KEY CLUSTERED ([intArchiveID] ASC)
);

