﻿CREATE TABLE [dbo].[tblRKM2MBasisImport]
(
	[intM2MBasisImportId] INT IDENTITY(1,1) NOT NULL,
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT,
	[strFutMarketName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strLocation] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strMarketZone] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strOriginPort] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strDestinationPort] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,	
	[strCropYear] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strStorageLocation] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strStorageUnit] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strPeriodTo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strContractType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strProductType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strGrade] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strRegion] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strProductLine] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strClass] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCertification] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strMTMPoint] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strContractInventory] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasure] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblCash] NUMERIC(18, 6) NULL, 
	[dblBasis] NUMERIC(18, 6) NULL, 
	[dblRatio] NUMERIC(18, 6) NULL, 
	CONSTRAINT [PK_tblRKM2MBasisImport_intM2MBasisImportId] PRIMARY KEY ([intM2MBasisImportId])	
)
