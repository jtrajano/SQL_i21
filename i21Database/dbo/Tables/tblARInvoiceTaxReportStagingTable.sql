CREATE TABLE [dbo].[tblARInvoiceTaxReportStagingTable] (
    [intTransactionId]      			INT             NULL,
	[intTransactionDetailId]			INT             NULL,
	[intTransactionDetailTaxId]			INT				NULL,
	[intTaxCodeId]						INT				NULL,
	[intEntityUserId]					INT             NULL,
	[strRequestId]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxTransactionType]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxClass]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceFormat]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceType]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	[dblAdjustedTax]					NUMERIC (18, 6)	NULL,
	[dblRate]							NUMERIC (18, 6)	NULL,
	[dblTaxPerQty]						NUMERIC (18, 6)	NULL,
	[dblComputedGrossPrice]				NUMERIC (18, 6)	NULL
);