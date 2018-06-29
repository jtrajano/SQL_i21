CREATE TABLE [dbo].[tblEMEntityImportSchemaCSV]
(
	[intEntityImportSchemaCSV]		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	[strObject]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	[strProperty]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCSVProp]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intIndex]						INT NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT(0)
)
