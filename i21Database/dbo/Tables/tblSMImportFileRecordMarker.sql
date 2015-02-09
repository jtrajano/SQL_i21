CREATE TABLE [dbo].[tblSMImportFileRecordMarker]
(
	[intImportFileRecordMarkerId] INT NOT NULL IDENTITY,
	[intImportFileHeaderId] INT NULL DEFAULT 0,
	[strRecordMarker] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intRowsToSkip] INT NULL DEFAULT ((0)), 
	[intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileRecordMarker] PRIMARY KEY ([intImportFileRecordMarkerId]),
	CONSTRAINT [FK_tblSMImportFileRecordMarker_tblSMImportHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId]) 
)
