CREATE TYPE [dbo].[TFInvoiceDetailTax] AS TABLE
(
	intInvoiceDetailId INT, 
	intTaxCodeId INT NULL,
	strCriteria NVARCHAR(100) NULL,
	dblTax NUMERIC(18, 8) NULL,
	UNIQUE NONCLUSTERED ([intInvoiceDetailId] ASC, [intTaxCodeId] ASC)
)
