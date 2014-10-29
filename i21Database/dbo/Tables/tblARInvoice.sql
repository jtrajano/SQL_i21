CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]         INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]     NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intCustomerId]        INT             NOT NULL,
    [dtmDate]              DATETIME        NOT NULL,
    [dtmDueDate]           DATETIME        NOT NULL,
    [intCurrencyId]        INT             NOT NULL,
    [intCompanyLocationId] INT             NULL,
    [intSalespersonId]     INT             NOT NULL,
    [dtmShipDate]          DATETIME        NULL,
    [intShipViaId]         INT             NOT NULL,
    [strPONumber]          NVARCHAR (25)   NULL,
    [intTermId]            INT             NOT NULL,
    [dblInvoiceSubtotal]   NUMERIC (18, 6) NULL,
    [dblShipping]          NUMERIC (18, 6) NULL,
    [dblTax]               NUMERIC (18, 6) NULL,
    [dblInvoiceTotal]      NUMERIC (18, 6) NULL,
    [dblDiscount]          NUMERIC (18, 6) NULL,
    [dblAmountDue]         NUMERIC (18, 6) NULL,
    [dblPayment]           NUMERIC (18, 6) NULL,
    [strTransactionType]   NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intPaymentMethodId]   INT             NOT NULL,
    [strComments]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]         INT             NOT NULL,
    [ysnPosted]            BIT             CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)) NOT NULL,
    [ysnPaid]              BIT             CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]     INT             CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARInvoice] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
    CONSTRAINT [FK_tblARInvoice_tblEntity] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
);









