CREATE TABLE [dbo].[tblGLPostHistory] (
    [intPostHistoryID]   INT             IDENTITY (1, 1) NOT NULL,
    [strBatchID]         NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [strSource]          NVARCHAR (30)   COLLATE Latin1_General_CI_AS NULL,
    [strReference]       NVARCHAR (75)   COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType] NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dtmPostDate]        DATETIME        NOT NULL,
    [dblTotal]           NUMERIC (18, 6) NOT NULL,
    [intConcurrencyId]   INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLPostHistory] PRIMARY KEY CLUSTERED ([intPostHistoryID] ASC)
);

