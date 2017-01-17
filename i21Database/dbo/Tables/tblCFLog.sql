CREATE TABLE [dbo].[tblCFLog] (
    [intLogId]     INT            IDENTITY (1, 1) NOT NULL,
    [strProcess]   NVARCHAR (50)  NOT NULL,
    [strProcessid] NVARCHAR (MAX) NOT NULL,
    [strCallStack] NVARCHAR (MAX) NULL,
    [intSortId]    INT            NOT NULL,
    CONSTRAINT [PK_tblCFLog] PRIMARY KEY CLUSTERED ([intLogId] ASC)
);

