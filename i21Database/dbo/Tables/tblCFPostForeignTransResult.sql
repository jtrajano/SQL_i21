CREATE TABLE [dbo].[tblCFPostForeignTransResult] (
    [intPostForeignTransResultId] INT            IDENTITY (1, 1) NOT NULL,
    [strBatchId]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intTransactionId]            INT            NULL,
    [strTransactionId]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]                     DATETIME       NULL,
    [intEntityId]                 INT            NULL,
    CONSTRAINT [PK_tblCFPostForeignTransResult] PRIMARY KEY CLUSTERED ([intPostForeignTransResultId] ASC)
);

