CREATE TABLE [dbo].[tblCFInvoiceProcessHistory] (
    [intInvoiceProcessHistoryId]  INT             IDENTITY (1, 1) NOT NULL,
    [intCustomerId]               INT             NULL,
    [intInvoiceId]                INT             NULL,
    [intPaymentId]                INT             NULL,
    [strCustomerNumber]           NVARCHAR (MAX)  NULL,
    [strCustomerName]             NVARCHAR (MAX)  NULL,
    [strInvoiceNumber]            NVARCHAR (MAX)  NULL,
    [strPaymentNumber]            NVARCHAR (MAX)  NULL,
    [dblInvoiceAmount]            NUMERIC (18, 6) NULL,
    [dblTotalQuantity]            NUMERIC (18, 6) NULL,
    [dblDiscountEligibleQuantity] NUMERIC (18, 6) NULL,
    [dblDiscountAmount]           NUMERIC (18, 6) NULL,
    [intConcurrencyId]            INT             CONSTRAINT [DF_tblCFInvoiceProcessHistoryId_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFInvoiceProcessHistoryId] PRIMARY KEY CLUSTERED ([intInvoiceProcessHistoryId] ASC)
);

