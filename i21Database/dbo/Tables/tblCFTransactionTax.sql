CREATE TABLE [dbo].[tblCFTransactionTax] (
    [intTransactionTaxId]    INT             IDENTITY (1, 1) NOT NULL,
    [intTransactionId]       INT             NOT NULL,
    [dblTaxOriginalAmount]   NUMERIC (18, 6) NULL,
    [dblTaxCalculatedAmount] NUMERIC (18, 6) NULL,
    [intTaxCodeId]           INT             NOT NULL,
    [dblTaxRate]             NUMERIC (18, 6) NULL,
    [intConcurrencyId]       INT             CONSTRAINT [DF_tblCFTransactionTaxId_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFTransactionTaxId] PRIMARY KEY CLUSTERED ([intTransactionTaxId] ASC),
    CONSTRAINT [FK_tblCFTransactionTax_tblCFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCFTransaction] ([intTransactionId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFTransactionTax_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId])
);







