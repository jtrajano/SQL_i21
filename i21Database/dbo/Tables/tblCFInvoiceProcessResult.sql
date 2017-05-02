CREATE TABLE [dbo].[tblCFInvoiceProcessResult] (
    [intInvoiceProcessResultId] INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceProcessResultId] NVARCHAR (50)   NULL,
    [intTransactionProcessId]   INT             NULL,
    [ysnStatus]                 BIT             NULL,
    [strRunProcessId]           NVARCHAR (MAX)  NULL,
    [intCustomerId]             INT             NULL,
    [strInvoiceReportNumber]    NVARCHAR (50)   NULL,
    [dblInvoiceAmount]          NUMERIC (18, 6) NULL,
    [dblInvoiceQuantity]        NUMERIC (18, 6) NULL,
    [dblInvoiceDiscount]        NUMERIC (18, 6) NULL,
    [dblInvoiceFee]             NUMERIC (18, 6) NULL,
    [dblPayment]                NUMERIC (18, 6) NULL,
    [intInvoiceId]              INT             NULL,
    [intPaymentId]              INT             NULL,
    [strInvoiceId]              NVARCHAR (50)   NULL,
    [strPaymentId]              NVARCHAR (50)   NULL,
    CONSTRAINT [PK_tblCFInvoiceProcessResult] PRIMARY KEY CLUSTERED ([intInvoiceProcessResultId] ASC)
);



