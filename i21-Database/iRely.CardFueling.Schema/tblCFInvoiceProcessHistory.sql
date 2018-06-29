CREATE TABLE [dbo].[tblCFInvoiceProcessHistory] (
    [intInvoiceProcessHistoryId]  INT             IDENTITY (1, 1) NOT NULL,
    [intCustomerId]               INT             NULL,
    [intInvoiceId]                INT             NULL,
    [intPaymentId]                INT             NULL,
    [strCustomerNumber]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumber]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPaymentNumber]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblInvoiceAmount]            NUMERIC (18, 6) NULL,
    [dblTotalQuantity]            NUMERIC (18, 6) NULL,
    [dblDiscountEligibleQuantity] NUMERIC (18, 6) NULL,
    [dblDiscountAmount]           NUMERIC (18, 6) NULL,
    [dtmInvoiceDate]              DATETIME        NULL,
    [strInvoiceNumberHistory]     NVARCHAR (MAX)  NULL,
    [ysnRemittancePage]           BIT             NULL,
    [strReportName]               NVARCHAR (MAX)  NULL,
    [dtmBalanceForwardDate]       DATETIME        NULL,
    [intConcurrencyId]            INT             CONSTRAINT [DF_tblCFInvoiceProcessHistoryId_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFInvoiceProcessHistoryId] PRIMARY KEY CLUSTERED ([intInvoiceProcessHistoryId] ASC)
);





