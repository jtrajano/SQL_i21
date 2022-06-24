CREATE TABLE [dbo].[tblCFLog] (
    [intLogId]     INT            IDENTITY (1, 1) NOT NULL,
    [strProcess]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strProcessid] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strCallStack] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intSortId]    INT            NOT NULL,
    [strMessage]   NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFLog] PRIMARY KEY CLUSTERED ([intLogId] ASC)
);



