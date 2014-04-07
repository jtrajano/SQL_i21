CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]     INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber] NVARCHAR (25)   NOT NULL,
    [intEntityId]      INT             NOT NULL,
    [dtmDate]          DATETIME        NOT NULL,
    [strType]          NVARCHAR (25)   NULL,
    [dblTotal]         NUMERIC (18, 6) NULL,
    [dblAmountPaid]    NUMERIC (18, 6) NULL,
    [ysnPaid]          BIT             NOT NULL,
    [dblAmountDue]     NUMERIC (18, 6) NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARInvoice] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC)
);

