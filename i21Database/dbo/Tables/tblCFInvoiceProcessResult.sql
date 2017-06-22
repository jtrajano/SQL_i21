CREATE TABLE [dbo].[tblCFInvoiceProcessResult] (
    [intInvoiceProcessResultId] INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceProcessResultId] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTransactionProcessId]   INT             NULL,
    [ysnStatus]                 BIT             NULL,
    [strRunProcessId]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]             INT             NULL,
    [strInvoiceReportNumber]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblInvoiceAmount]          NUMERIC (18, 6) NULL,
    [dblInvoiceQuantity]        NUMERIC (18, 6) NULL,
    [dblInvoiceDiscount]        NUMERIC (18, 6) NULL,
    [dblInvoiceFee]             NUMERIC (18, 6) NULL,
    [dblPayment]                NUMERIC (18, 6) NULL,
    [intInvoiceId]              INT             NULL,
    [intPaymentId]              INT             NULL,
    [strInvoiceId]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPaymentId]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFInvoiceProcessResult] PRIMARY KEY CLUSTERED ([intInvoiceProcessResultId] ASC)
);





