CREATE TABLE [dbo].[tblSMImportFileTable]
(
	[intImportFileTableId] INT NOT NULL IDENTITY,
	[intImportFileHeaderId] INT NULL DEFAULT 0,
	[strImportFileTable] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strImportFileForeignKeyTable] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileTable] PRIMARY KEY ([intImportFileTableId]),
	CONSTRAINT [FK_tblSMImportFileTable_tblSMImportHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId]) ON DELETE CASCADE
)
