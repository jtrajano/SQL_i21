CREATE TABLE [dbo].[tblRKM2MBasisImport]
(
	[intM2MBasisImportId] INT IDENTITY(1,1) NOT NULL,
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT,
	[strFutMarketName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblBasis] NUMERIC(18, 6) NULL, 
	[strUnitMeasure] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarketZone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPeriodTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,

	CONSTRAINT [PK_tblRKM2MBasisImport_intM2MBasisImportId] PRIMARY KEY ([intM2MBasisImportId])	
)
