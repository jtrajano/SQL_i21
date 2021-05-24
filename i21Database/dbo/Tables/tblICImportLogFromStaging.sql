CREATE TABLE [dbo].[tblICImportLogFromStaging]
(
	[intImportLogFromStagingId] INT IDENTITY(1, 1) NOT NULL,
	[strUniqueId] UNIQUEIDENTIFIER NULL,
	[intRowsImported] INT NULL,
	[intRowsUpdated] INT NULL,
	[intRowsSkipped] INT NULL,
	[intTotalErrors] INT NULL,
	[intTotalWarnings] INT NULL
)
GO