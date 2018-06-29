CREATE TABLE [dbo].[tblCMBankTransactionBatch] (
    [intBankTransactionBatchId] INT             IDENTITY (1, 1) NOT NULL,
    [strBankTransactionBatchId] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intBankTransactionTypeId]  INT             NOT NULL,
    [intBankAccountId]          INT             NOT NULL,
    [intCurrencyId]             INT             NOT NULL,
    [dtmBatchDate]              DATETIME        NULL,
    [dblTotal]                  DECIMAL (18, 6) NOT NULL,
    [intCompanyLocationId]      INT             NOT NULL,
    [strDescription]            NVARCHAR (250)  NULL,
    [ysnPosted]                 BIT             DEFAULT ((0)) NULL,
    [intEntityUserId]           INT             NULL,
    [ysnDeleted]                BIT             DEFAULT ((0)) NULL,
    [dtmDateDeleted]            DATETIME        NULL,
    [dtmDateCreated]            DATETIME        DEFAULT (getdate()) NULL,
    [intConcurrencyId]          INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblCMBankTransactionBatch] PRIMARY KEY CLUSTERED ([intBankTransactionBatchId] ASC)
);

