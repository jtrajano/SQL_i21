CREATE TYPE [dbo].[TFCommonDetailTax] AS TABLE
(
	intTransactionDetailId INT, 
	intTaxCodeId INT NULL,
	strCriteria NVARCHAR(100) NULL,
	dblTax NUMERIC(18, 8) NULL,
	UNIQUE NONCLUSTERED ([intTransactionDetailId] ASC, [intTaxCodeId] ASC)
)
