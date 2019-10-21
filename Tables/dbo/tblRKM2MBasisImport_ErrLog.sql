CREATE TABLE [dbo].[tblRKM2MBasisImport_ErrLog]
(
	[intBasisImportErrId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT,
	[strFutMarketName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblBasis] NUMERIC(18, 6) NULL, 
	[strUnitMeasure] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMarketZone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPeriodTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

	CONSTRAINT [PK_tblRKM2MBasisImport_ErrLog_intBasisImportErrId] PRIMARY KEY ([intBasisImportErrId]),	
)
