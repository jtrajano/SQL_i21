CREATE TABLE [dbo].[tblPATImportOriginFlag](
	[intImportOriginLogId] INT NOT NULL,
	[strImportType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnIsImported] BIT NOT NULL DEFAULT((0)),
	[intImportCount] INT NOT NULL DEFAULT((0)),
	CONSTRAINT [PK_tblPATImportOriginLog] PRIMARY KEY ([intImportOriginLogId])
)