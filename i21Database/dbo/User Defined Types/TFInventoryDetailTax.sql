CREATE TYPE [dbo].[TFInventoryDetailTax] AS TABLE
(
	intInventoryDetailId INT, 
	intTaxCodeId INT NULL,
	strCriteria NVARCHAR(100) NULL,
	dblTax NUMERIC(18, 8) NULL,
	PRIMARY KEY CLUSTERED ([intInventoryDetailId] ASC) WITH (IGNORE_DUP_KEY = OFF),
	UNIQUE NONCLUSTERED ([intInventoryDetailId] ASC, [intTaxCodeId] ASC)
)
