CREATE TYPE [dbo].[TFInventoryDetailTax] AS TABLE
(
	intInventoryDetailId INT, 
	intTaxCodeId INT NULL,
	strCriteria NVARCHAR(100) NULL,
	dblTax NUMERIC(18, 8) NULL,
	UNIQUE NONCLUSTERED ([intInventoryDetailId] ASC, [intTaxCodeId] ASC)
)
