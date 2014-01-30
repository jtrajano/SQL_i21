CREATE TABLE [dbo].[tblCMBankTransactionType] (
    [intBankTransactionTypeId]   INT           NOT NULL,
    [strBankTransactionTypeName] NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [intConcurrencyId]           INT           NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankTransactionType] PRIMARY KEY CLUSTERED ([intBankTransactionTypeId] ASC)
);

