CREATE TYPE [dbo].[TFReportOR7351334MSub] AS TABLE
(
	intId INT NOT NULL,
	strLine NVARCHAR(1000),
	strFacilityNumber NVARCHAR(200),
	strProductCode NVARCHAR(100),
	strData NVARCHAR(200),
	dtmBeginDate DATETIME,
	dtmEndDate DATETIME
)
