CREATE TABLE [dbo].[tblCFTaxException] (
    [intTaxExceptionId]   INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]        INT             NULL,
    [strTaxState]         NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strAuthorityId1]     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strAuthorityId2]     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intARItemId]         INT             NULL,
    [intVehicleId]        INT             NULL,
    [intCardId]           INT             NULL,
    [ysnFederalExciseTax] BIT             NULL,
    [ysnStateExciseTax]   BIT             NULL,
    [ysnStateSalesTax]    BIT             NULL,
    [ysnLocalTax1]        BIT             NULL,
    [ysnLocalTax2]        BIT             NULL,
    [ysnLocalTax3]        BIT             NULL,
    [ysnLocalTax4]        BIT             NULL,
    [ysnLocalTax5]        BIT             NULL,
    [ysnLocalTax6]        BIT             NULL,
    [ysnLocalTax7]        BIT             NULL,
    [ysnLocalTax8]        BIT             NULL,
    [ysnLocalTax9]        BIT             NULL,
    [ysnLocalTax10]       BIT             NULL,
    [ysnLocalTax11]       BIT             NULL,
    [ysnLocalTax12]       BIT             NULL,
    [dblPriceVariation]   NUMERIC (18, 6) NULL,
    [intInvoiceItemId]    INT             NULL,
    [intConcurrencyId]    INT             CONSTRAINT [DF_tblCFTaxException_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFTaxException] PRIMARY KEY CLUSTERED ([intTaxExceptionId] ASC),
    CONSTRAINT [FK_tblCFTaxException_tblCFAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblCFAccount] ([intAccountId]) ON DELETE CASCADE
);



