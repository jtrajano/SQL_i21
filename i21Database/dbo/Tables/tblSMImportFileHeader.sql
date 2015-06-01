CREATE TABLE [dbo].[tblSMImportFileHeader]
(
	[intImportFileHeaderId] INT NOT NULL IDENTITY,
	[strLayoutTitle] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileType] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFieldDelimiter] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strXMLType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL, 
	[strXMLInitiater] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSMImportFileHeader] PRIMARY KEY ([intImportFileHeaderId]),
	CONSTRAINT [AK_tblSMImportFileHeader] UNIQUE ([strLayoutTitle])	 
)
