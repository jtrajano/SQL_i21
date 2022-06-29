
CREATE TABLE [dbo].[tblCFImportTransactionCFNTaxDetailStagingTable](
	[intRowId] int IDENTITY(1,1) NOT NULL,
	[intRecordId] int NULL,
	[strTaxCode] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxValue] numeric(18, 6) NULL,
	[strGUID] nvarchar(max) COLLATE Latin1_General_CI_AS NULL
) 