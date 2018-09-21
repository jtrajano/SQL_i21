CREATE TYPE [dbo].[TFInvoiceDetailTransaction] AS TABLE
(
	intInvoiceDetailId INT, 
	intTaxCodeId INT NULL,
	UNIQUE NONCLUSTERED ([intInvoiceDetailId] ASC, [intTaxCodeId] ASC)
)