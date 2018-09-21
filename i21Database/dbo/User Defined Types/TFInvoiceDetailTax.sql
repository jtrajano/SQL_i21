CREATE TYPE [dbo].[TFInvoiceDetailTax] AS TABLE
(
	intInvoiceDetailId INT, 
	intTaxCodeId INT NULL,
	strCriteria NVARCHAR(100) NULL,
	dblTax NUMERIC(18, 8) NULL,
	PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC) WITH (IGNORE_DUP_KEY = OFF),
	UNIQUE NONCLUSTERED ([intInvoiceDetailId] ASC, [intTaxCodeId] ASC)
)
