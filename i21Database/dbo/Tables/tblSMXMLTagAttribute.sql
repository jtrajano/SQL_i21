﻿CREATE TABLE [dbo].[tblSMXMLTagAttribute]
(
	[intTagAttributeId] INT IDENTITY(1,1) NOT NULL ,
	[intImportFileColumnDetailId] INT NOT NULL, 
	[intSequence] INT NULL,
	[strTagAttribute] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
	[strTable] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strColumnName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultValue]   nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] bit DEFAULT 1,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSMXMLTagAttribute_intTagAttributeId] PRIMARY KEY ([intTagAttributeId]),
	CONSTRAINT [FK_tblSMXMLTagAttribute_tblSMImportFileColumnDetail_intImportFileColumnDetailId] FOREIGN KEY ([intImportFileColumnDetailId]) REFERENCES [tblSMImportFileColumnDetail]([intImportFileColumnDetailId]) ON DELETE CASCADE,
	CONSTRAINT [AK_tblSMXMLTagAttribute_intImportFileColumnDetailId_intSequence] UNIQUE ([intImportFileColumnDetailId], [intSequence])
)
