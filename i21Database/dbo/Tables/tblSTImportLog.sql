
CREATE TABLE [dbo].[tblSTImportLog]
(
	[intImportLogId] INT IDENTITY(1, 1) NOT NULL,
	[strDescription] NVARCHAR(4000) COLLATE Latin1_General_CI_AS NULL,
	[intTotalRows] INT NULL,
	[strUniqueId] UNIQUEIDENTIFIER NULL,
	[intRowsImported] INT NULL,
	[intRowsUpdated] INT NULL,
	[intTotalErrors] INT NULL,
	[intTotalWarnings] INT NULL,
	[dblTimeSpentInSeconds] NUMERIC(18, 6) NULL,
	[intUserEntityId] INT NULL,
	[strType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strFileType] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strFileName] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateImported] DATETIME NULL,
	[ysnAllowDuplicates] BIT NULL,
	[ysnAllowOverwriteOnImport] BIT NULL,
	[ysnContinueOnFailedImports] BIT NULL,
	[intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTImportLog] PRIMARY KEY NONCLUSTERED ([intImportLogId])
)
GO