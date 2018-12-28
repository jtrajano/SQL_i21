CREATE TABLE [dbo].[tblQMPropertyImport]
(
	[intImportId] INT NOT NULL IDENTITY, 
	strPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	strDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS, 
	strAnalysisTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDataTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strListName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intDecimalPlaces INT, 
	strIsMandatory NVARCHAR(20) COLLATE Latin1_General_CI_AS DEFAULT 'No', 
	ysnActive BIT NOT NULL CONSTRAINT [DF_tblQMPropertyImport_ysnActive] DEFAULT 1, 
	ysnNotify BIT CONSTRAINT [DF_tblQMPropertyImport_ysnNotify] DEFAULT 0,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	dtmValidFrom DATETIME NOT NULL, 
    dtmValidTo DATETIME NOT NULL, 
	dblMinValue NUMERIC(18, 6),
	dblMaxValue NUMERIC(18, 6),
	strPropertyRangeText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblQMPropertyImport_strPropertyRangeText] DEFAULT '', 
	strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblQMPropertyImport_ysnProcessed] DEFAULT 0, 
	[strErrorMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 

	CONSTRAINT [PK_tblQMPropertyImport] PRIMARY KEY ([intImportId])
)