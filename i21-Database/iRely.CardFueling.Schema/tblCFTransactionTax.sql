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










GO
CREATE NONCLUSTERED INDEX [tblCFTransactionTax_intTransactionTaxId]
    ON [dbo].[tblCFTransactionTax]([intTransactionTaxId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransactionTax_intTransactionId]
    ON [dbo].[tblCFTransactionTax]([intTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransactionTax_intTaxCodeId]
    ON [dbo].[tblCFTransactionTax]([intTaxCodeId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCFTransactionTax_intTransactionId_intTransactionTaxId_intTaxCodeId] ON [dbo].[tblCFTransactionTax]
(
	[intTransactionId] ASC,
	[intTransactionTaxId] ASC,
	[intTaxCodeId] ASC
)
INCLUDE ( 	[dblTaxOriginalAmount],[dblTaxCalculatedAmount]) 

GO