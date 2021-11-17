CREATE TABLE [dbo].[tblApiSchemaTransformVendorSetup] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, -- The vendor to setup.
	strExportFileType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor setup export file type.
	strExportFilePath NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, -- The vendor setup export file path.
	strCompany1Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor setup company 1 ID.
	strCompany2Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor setup company 2 ID.
	strCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor customer cross reference.
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor item cross reference.
	strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor unit measure cross reference.
	strEquipmentType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The vendor unit measure cross reference equipment type.
	strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL -- The vendor category cross reference.
)