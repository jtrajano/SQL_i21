CREATE TABLE [dbo].[tblCFImportTransactionPriceType](
	[strTransactionPriceId] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxOriginalAmount] numeric(18, 6) NULL,
	[dblTaxCalculatedAmount] numeric(18, 6) NULL,
	[intTransactionId] int NULL,
	-- [strGuid] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strGUID] nvarchar(max) COLLATE Latin1_General_CI_AS NULL
)