CREATE TABLE [dbo].[tblRKM2MTransactionImport]
(
	[intM2MTransactionImportId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] int,
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFutMarketName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarketZone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPeriodTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblBasis] NUMERIC(18, 6) NULL, 
	[strUnitMeasure] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblRKM2MTransactionImport_intM2MTransactionImportId] PRIMARY KEY (intM2MTransactionImportId)	
)
