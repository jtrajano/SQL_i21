CREATE TABLE [dbo].[tblCMBankTransactionType] (
    [intBankTransactionTypeID]   INT           NOT NULL,
    [strBankTransactionTypeName] NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID]           INT           NOT NULL,
    CONSTRAINT [PK_tblCMBankTransactionType] PRIMARY KEY CLUSTERED ([intBankTransactionTypeID] ASC)
);

