CREATE TABLE [dbo].[tblQMTestImport]
(
	[intImportId] INT NOT NULL IDENTITY, 
	strTestName NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	strAnalysisTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTestMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strIndustryStandards NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strSensComments NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	ysnActive BIT NOT NULL CONSTRAINT [DF_tblQMTestImport_ysnActive] DEFAULT 1,

	strPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS,

	[ysnProcessed] BIT NOT NULL CONSTRAINT [DF_tblQMTestImport_ysnProcessed] DEFAULT 0, 
	[strErrorMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 

	CONSTRAINT [PK_tblQMTestImport] PRIMARY KEY ([intImportId])
)