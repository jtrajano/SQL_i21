CREATE TABLE [dbo].[tblCFTransactionTax] (
    [intTransactionTaxId]    INT             IDENTITY (1, 1) NOT NULL,
    [intTransactionId]       INT             NOT NULL,
    [strTransactionTaxId]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblTaxOriginalAmount]   NUMERIC (18, 6) NULL,
    [dblTaxCalculatedAmount] NUMERIC (18, 6) NULL,
    [intConcurrencyId]       INT             CONSTRAINT [DF_tblCFTransactionTaxId_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFTransactionTaxId] PRIMARY KEY CLUSTERED ([intTransactionTaxId] ASC),
    CONSTRAINT [FK_tblCFTransactionTax_tblCFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCFTransaction] ([intTransactionId]) ON DELETE CASCADE
);



