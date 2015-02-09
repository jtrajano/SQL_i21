CREATE TABLE [dbo].[tblSMImportFileColumnDetail]
(
	[intImportFileColumnDetailId] INT NOT NULL IDENTITY,
	[intImportFileHeaderId] INT NOT NULL DEFAULT 0,
	[intImportFileRecordMarkerId] INT NULL DEFAULT 0,
	[intImportFileTableId] INT NOT NULL DEFAULT 0,
	[strColumnName] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDataType]   nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intPosition]  INT NULL DEFAULT ((0)), 
	[strDefaultValue]   nvarchar(max) COLLATE Latin1_General_CI_AS NOT NULL,
    [intLength]  INT NULL DEFAULT ((0)), 
	[intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileColumnDetail] PRIMARY KEY ([intImportFileColumnDetailId]),
	CONSTRAINT [FK_tblSMImportFileColumnDetail_tblSMImportFileHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId]) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblSMImportFileColumnDetail_tblSMImportFileRecordMarker_intImportFileRecordMarkerId] FOREIGN KEY ([intImportFileRecordMarkerId]) REFERENCES [dbo].[tblSMImportFileRecordMarker] ([intImportFileRecordMarkerId]) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblSMImportFileColumnDetail_tblSMImportFileTable_intImportFileTableId] FOREIGN KEY ([intImportFileTableId]) REFERENCES [dbo].[tblSMImportFileTable] ([intImportFileTableId]) ON DELETE CASCADE, 
)
