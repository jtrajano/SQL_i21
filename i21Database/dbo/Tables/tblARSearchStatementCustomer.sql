CREATE TABLE [dbo].[tblARSearchStatementCustomer] (
	[intEntityCustomerId]	INT NOT NULL,
	[strCustomerNumber]		VARCHAR(MAX)	COLLATE Latin1_General_CI_AS,
	[strCustomerName]		VARCHAR(MAX)	COLLATE Latin1_General_CI_AS,
	[dblARBalance]			NUMERIC(18,6),
	[strTransactionId]		VARCHAR(MAX)	COLLATE Latin1_General_CI_AS,
	[strTransactionDate]	VARCHAR(MAX)	COLLATE Latin1_General_CI_AS,
	[dblTotalAmount]		NUMERIC(18,6),
	[intConcurrencyId]		[int] NOT NULL	 DEFAULT 0
);



