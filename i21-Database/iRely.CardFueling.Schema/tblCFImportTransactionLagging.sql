CREATE TABLE [dbo].[tblCFImportTransactionLagging] (
    [intImportTransactionLaggingId] INT      IDENTITY (1, 1) NOT NULL,
    [dtmLaggingDate]                DATETIME NULL,
    [intConcurrencyId]              INT      CONSTRAINT [DF_tblCFImportTransactionLagging_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportTransactionLagging] PRIMARY KEY CLUSTERED ([intImportTransactionLaggingId] ASC)
);

