CREATE TABLE [dbo].[tblSMXMLTagAttribute]
(
	[intTagAttributeId] INT NOT NULL ,
	[intImportFileColumnDetailId] INT NOT NULL, 
	[intSequence] INT NULL,
	[strTagAttribute] nvarchar(200) NOT NULL,
	[strTable] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strColumnName] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDefaultValue]   nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSMXMLTagAttribute_intTagAttributeId] PRIMARY KEY ([intTagAttributeId]),
	CONSTRAINT [FK_tblSMXMLTagAttribute_tblSMImportFileColumnDetail_intImportFileColumnDetailId] FOREIGN KEY ([intImportFileColumnDetailId]) REFERENCES [tblSMImportFileColumnDetail]([intImportFileColumnDetailId]) ON DELETE CASCADE
)
