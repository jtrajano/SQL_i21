CREATE TABLE [dbo].[tblSMImportFileTable]
(
	[intImportFileTableId] INT NOT NULL IDENTITY,
	[strImportFileTable] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strImportFileForeignKeyTable] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileTable] PRIMARY KEY ([intImportFileTableId])
)
