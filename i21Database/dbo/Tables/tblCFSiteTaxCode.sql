CREATE TABLE [dbo].[tblCFSiteTaxCode] (
    [intSiteTaxCodeId]       INT             NULL,
    [intTransactionTicketId] INT             NULL,
    [intSiteTaxCode]         INT             NULL,
    [dblSiteTaxAmount]       NUMERIC (18, 6) NULL,
    [intConcurrencyId]       INT             CONSTRAINT [DF_tblCFSiteTaxCode_intConcurrencyId] DEFAULT ((1)) NULL
);

