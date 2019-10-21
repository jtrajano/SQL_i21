CREATE TABLE [dbo].[tblCMBankTransactionType] (
    [intBankTransactionTypeId]   INT           NOT NULL,
    [strBankTransactionTypeName] NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]           INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBankTransactionType] PRIMARY KEY CLUSTERED ([intBankTransactionTypeId] ASC),
    UNIQUE NONCLUSTERED ([strBankTransactionTypeName] ASC)
);

