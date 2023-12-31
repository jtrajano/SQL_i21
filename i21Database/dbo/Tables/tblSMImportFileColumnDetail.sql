﻿CREATE TABLE [dbo].[tblSMImportFileColumnDetail]
(
	[intImportFileColumnDetailId] INT NOT NULL IDENTITY,
	[intImportFileHeaderId] INT NOT NULL DEFAULT 0,
	[intImportFileRecordMarkerId] INT NULL DEFAULT 0,
	--[intImportFileTableId] INT NOT NULL DEFAULT 0,
	[intLevel]  INT NULL DEFAULT ((0)), 
	[intPosition]  INT NULL DEFAULT ((0)), 
	[strXMLTag] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTable] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strColumnName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strDataType]   nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [intLength]  INT NULL DEFAULT ((0)), 
	[strDefaultValue]   nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] bit DEFAULT 1,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileColumnDetail] PRIMARY KEY ([intImportFileColumnDetailId]),
	CONSTRAINT [FK_tblSMImportFileColumnDetail_tblSMImportFileHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId]) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblSMImportFileColumnDetail_tblSMImportFileRecordMarker_intImportFileRecordMarkerId] FOREIGN KEY ([intImportFileRecordMarkerId]) REFERENCES [dbo].[tblSMImportFileRecordMarker] ([intImportFileRecordMarkerId]),  
	CONSTRAINT [AK_tblSMImportFileColumnDetail_intImportFileHeaderId_intLevel] UNIQUE ([intImportFileHeaderId], [intLevel])
	--CONSTRAINT [FK_tblSMImportFileColumnDetail_tblSMImportFileTable_intImportFileTableId] FOREIGN KEY ([intImportFileTableId]) REFERENCES [dbo].[tblSMImportFileTable] ([intImportFileTableId]), 
)
