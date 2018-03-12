CREATE TYPE [dbo].[TFReportOR7351334MSub] AS TABLE
(
	strFacilityNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	strOperationType NVARCHAR(1000) COLLATE Latin1_General_CI_AS,
	strProductCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	dblBeginInventory NUMERIC(18, 6),
	dblPurchase NUMERIC (18, 6),
	dblEndInventory NUMERIC(18, 6),
	dblAvailable NUMERIC(18, 6),
	dblHandled NUMERIC (18, 6),
	dtmBeginDate DATETIME NOT NULL,
	dtmEndDate DATETIME NOT NULL
)
