CREATE TYPE [dbo].[ServiceChargeTableType] AS TABLE
(
	intServiceChargeId  INT             IDENTITY (1, 1) NOT NULL,
	intInvoiceId		INT NULL,
	intEntityCustomerId INT NOT NULL,
	strInvoiceNumber	NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL,	
	dblAmountDue		NUMERIC(18,6) NULL,
	dblTotalAmount   	NUMERIC(18,6) NULL
)