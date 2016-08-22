CREATE TYPE [dbo].[BankTransactionBatchDetailTable] AS TABLE (
    [intBankTransactionBatchId] INT             NULL,
    [intTransactionId]          INT             NOT NULL,
    [strTransactionId]          NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDate]                   DATETIME        NULL,
    [intGLAccountId]            INT             NOT NULL,
    [strAccountId]              NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [strDescription]            NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dblCredit]                 DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [dblDebit]                  DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [ysnPosted]                 BIT             NULL,
    [strRowState]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]          INT             NOT NULL);

