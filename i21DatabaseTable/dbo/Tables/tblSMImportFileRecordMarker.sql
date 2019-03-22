CREATE TABLE [dbo].[tblSMImportFileRecordMarker]
(
	[intImportFileRecordMarkerId] INT NOT NULL IDENTITY,
	[intImportFileHeaderId] INT NULL DEFAULT 0,
	[strRecordMarker] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intRowsToSkip] INT NULL DEFAULT ((0)), 
	[intPosition] INT NULL, 
	[strCondition] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intSequence] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[strFormat] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[intRounding] INT NULL ,
    CONSTRAINT [PK_tblSMImportFileRecordMarker] PRIMARY KEY ([intImportFileRecordMarkerId]),
	CONSTRAINT [FK_tblSMImportFileRecordMarker_tblSMImportHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId]) ON DELETE CASCADE
)
