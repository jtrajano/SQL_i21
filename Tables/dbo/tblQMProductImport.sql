CREATE TABLE [dbo].[tblQMProductImport]
(
	[intImportId] INT NOT NULL IDENTITY, 

	strProductTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strProductValue NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strNote NVARCHAR(500) COLLATE Latin1_General_CI_AS, 
	strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnActive BIT NOT NULL CONSTRAINT [DF_tblQMProductImport_ysnActive] DEFAULT 1,
	strApprovalLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strRejectionLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strBondedApprovalLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strBondedRejectionLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	strSampleTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTestName NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblQMProductImport_ysnProcessed] DEFAULT 0,
	[strErrorMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblQMProductImport] PRIMARY KEY ([intImportId])
)