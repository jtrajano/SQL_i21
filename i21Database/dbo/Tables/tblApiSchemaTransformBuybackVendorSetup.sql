CREATE TABLE [dbo].[tblApiSchemaTransformBuybackVendorSetup] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strVendor NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, -- The buyback vendor to setup.
	strBuybackExportFileType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup export file type.
	strBuybackExportFilePath NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup export file path.
	strCompany1Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup company 1 ID.
	strCompany2Id NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup company 2 ID.
	strReimbursementType NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup reimbursement type.
	strGLAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup account ID.
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup location.
	strVendorCustomerLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup vendor location.
	strVendorShipTo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, -- The buyback vendor setup location ship to ID.
	strVendorSoldTo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL -- The buyback vendor setup location sold to ID.
)