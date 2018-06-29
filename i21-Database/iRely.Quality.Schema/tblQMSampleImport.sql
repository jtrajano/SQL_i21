CREATE TABLE [dbo].[tblQMSampleImport]
(
	intSampleImportId INT IDENTITY(1,1) NOT NULL,
	intConcurrencyId INT NULL CONSTRAINT DF_tblQMSampleImport_intConcurrencyId DEFAULT 0, 
	dtmSampleReceivedDate NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSampleNumber NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strItemNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSampleTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strVendorName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strContainerNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strSampleNote NVARCHAR(512) COLLATE Latin1_General_CI_AS,
	strHeaderComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strWarehouse NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblSequenceQuantity NUMERIC(18, 6),
	strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSampleStatus NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPropertyValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strResult NVARCHAR(20) COLLATE Latin1_General_CI_AS,

	intCreatedUserId INT,
	dtmCreated DATETIME NULL CONSTRAINT DF_tblQMSampleImport_dtmCreated DEFAULT GETDATE()
)