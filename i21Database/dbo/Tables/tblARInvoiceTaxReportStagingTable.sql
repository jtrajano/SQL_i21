CREATE TABLE [dbo].[tblARInvoiceTaxReportStagingTable] (
    [intTransactionId]      			INT             NOT NULL,
	[intTransactionDetailId]			INT             NOT NULL,
	[intTransactionDetailTaxId]			INT				NOT NULL,
	[intTaxCodeId]						INT				NULL,
	[intEntityUserId]					INT             NULL,
	[strRequestId]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxTransactionType]				NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxClass]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceFormat]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceType]					NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	[dblAdjustedTax]					NUMERIC (18, 6)	NULL,
	[dblRate]							NUMERIC (18, 6)	NULL,
	[dblTaxPerQty]						NUMERIC (18, 6)	NULL,
	[dblComputedGrossPrice]				NUMERIC (18, 6)	NULL,
	[ysnIncludeInvoicePrice]			BIT				NULL
);
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceTaxReportStagingTable] 
	ON [dbo].[tblARInvoiceTaxReportStagingTable] ([intTransactionId], [intTransactionDetailId], [intEntityUserId],[strTaxTransactionType])
GO