CREATE TABLE [dbo].[tblARInvoice] (
    [intInvoiceId]       INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]   NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intEntityId]        INT             NOT NULL,
    [dtmDueDate]         DATETIME        NOT NULL,
    [dtmDate]            DATETIME        NULL,
    [strTransactionType] NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intTermId]          INT             NOT NULL,
    [dblInvoiceTotal]    NUMERIC (18, 6) NULL,
    [dblDiscount]        NUMERIC (18, 6) NULL,
    [dblAmountDue]       NUMERIC (18, 6) NULL,
    [dblPayment]         NUMERIC (18, 6) NULL,
    [intPaymentMethodId] INT             NOT NULL,
    [intLocationId]      INT             NULL,
    [strNotes]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]       INT             NOT NULL,
    [ysnPosted]          BIT             CONSTRAINT [DF_tblARInvoice_ysnPosted] DEFAULT ((0)) NOT NULL,
    [ysnPaid]            BIT             CONSTRAINT [DF_tblARInvoice_ysnPaid] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]   INT             CONSTRAINT [DF_tblARInvoice_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARInvoice] PRIMARY KEY CLUSTERED ([intInvoiceId] ASC),
    CONSTRAINT [FK_tblARInvoice_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
);





