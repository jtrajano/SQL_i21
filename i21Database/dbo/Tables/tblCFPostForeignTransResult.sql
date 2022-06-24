CREATE TABLE [dbo].[tblCFPostForeignTransResult] (
    [intPostForeignTransResultId] INT            IDENTITY (1, 1) NOT NULL,
    [strBatchId]                  NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intTransactionId]            INT            NULL,
    [strTransactionId]            NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]          NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]                     DATETIME       NULL,
    [intEntityId]                 INT            NULL,
    CONSTRAINT [PK_tblCFPostForeignTransResult] PRIMARY KEY CLUSTERED ([intPostForeignTransResultId] ASC)
);

