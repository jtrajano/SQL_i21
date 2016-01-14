CREATE TABLE [dbo].[tblEntityImportSchemaCSV]
(
	[intEntityImportSchemaCSV]		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	[strObject]						NVARCHAR(200) NOT NULL,
	[strProperty]					NVARCHAR(100) NOT NULL,
	[strCSVProp]					NVARCHAR(100) NOT NULL,
	[intIndex]						INT NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT(0)
)
