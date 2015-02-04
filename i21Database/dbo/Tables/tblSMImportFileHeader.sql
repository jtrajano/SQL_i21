CREATE TABLE [dbo].[tblSMImportFileHeader]
(
	[intImportFileHeaderId] INT NOT NULL IDENTITY,
	[intImportFileTableId] INT NOT NULL DEFAULT 0,	
	[intImportFileColumnDetailId] INT NOT NULL DEFAULT 0,
	[intImportFileRecordMarkerId] INT NULL DEFAULT 0,
	[strLayoutTitle] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFieldDelimiter] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileHeader] PRIMARY KEY ([intImportFileHeaderId]),
	CONSTRAINT [AK_tblSMImportFileHeader] UNIQUE ([strLayoutTitle]),
	CONSTRAINT [FK_tblSMImportFileHeader_tblSMImportFileTable_intImportFileTableId] FOREIGN KEY ([intImportFileTableId]) REFERENCES [dbo].[tblSMImportFileTable] ([intImportFileTableId]), 
	CONSTRAINT [FK_tblSMImportFileHeader_tblSMImportFileColumnDetail_intImportFileColumnDetailId] FOREIGN KEY ([intImportFileColumnDetailId]) REFERENCES [dbo].[tblSMImportFileColumnDetail] ([intImportFileColumnDetailId]),
	CONSTRAINT [FK_tblSMImportFileHeader_tblSMImportFileRecordMarker_intImportFileRecordMarkerId] FOREIGN KEY ([intImportFileRecordMarkerId]) REFERENCES [dbo].[tblSMImportFileRecordMarker] ([intImportFileRecordMarkerId])  
)
