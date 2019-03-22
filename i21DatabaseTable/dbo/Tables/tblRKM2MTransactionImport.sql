CREATE TABLE [dbo].[tblRKM2MTransactionImport]
(
	[intM2MTransactionImportId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] int,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] nvarchar(40) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] nvarchar(40) COLLATE Latin1_General_CI_AS NULL,
	[dblBasis] NUMERIC(18, 6) NULL, 
	[strUnitMeasure] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,

	CONSTRAINT [PK_tblRKM2MTransactionImport_intM2MTransactionImportId] PRIMARY KEY (intM2MTransactionImportId)	
)
