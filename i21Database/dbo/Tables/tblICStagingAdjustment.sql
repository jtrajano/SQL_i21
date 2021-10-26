CREATE TABLE tblICStagingAdjustment(
	  intStagingAdjustmentId INT IDENTITY(1, 1)
	, intLocationId INT NULL -- Normally used when this field is included in export
	, intAdjustmentId INT NULL -- Normally used when this field is included in export
	, strAdjustmentNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL -- Used in export but required to have an initial value in import for grouping details
	, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, dtmDate DATETIME NOT NULL
	, intAdjustmentType INT NOT NULL
	, strDescription NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL
	, [strIntegrationDocNo] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
	, LineNumber INT NULL
	, LinePosition INT NULL
	, guiApiUniqueId UNIQUEIDENTIFIER NULL
	, CONSTRAINT PK_tblICStagingAdjustment_intStagingAdjustmentId PRIMARY KEY(intStagingAdjustmentId)
)