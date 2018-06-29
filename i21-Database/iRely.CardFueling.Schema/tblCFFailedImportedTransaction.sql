CREATE TABLE [dbo].[tblCFFailedImportedTransaction] (
    [intImportTransactionId] INT            IDENTITY (1, 1) NOT NULL,
    [intTransactionId]       INT            NULL,
    [strFailedReason]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblCFImportTransaction_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportTransaction] PRIMARY KEY CLUSTERED ([intImportTransactionId] ASC)
);

