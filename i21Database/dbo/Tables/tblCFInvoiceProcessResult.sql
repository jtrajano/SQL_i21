CREATE TABLE [dbo].[tblCFInvoiceProcessResult] (
    [intInvoiceProcessResultId] INT            IDENTITY (1, 1) NOT NULL,
    [strInvoiceProcessResultId] NVARCHAR (50)  NULL,
    [intTransactionProcessId]   INT            NULL,
    [ysnStatus]                 BIT            NULL,
    [strRunProcessId]           NVARCHAR (MAX) NULL,
    [intCustomerId]             INT            NULL,
    [strInvoiceReportNumber]    NVARCHAR (50)  NULL,
    CONSTRAINT [PK_tblCFInvoiceProcessResult] PRIMARY KEY CLUSTERED ([intInvoiceProcessResultId] ASC)
);

