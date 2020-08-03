CREATE TYPE [dbo].[TFReportingComponentConfigurations] AS TABLE (
	intReportTemplateId INT NOT NULL
	, strTemplateItemId NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
	, strFormCode NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
    , strScheduleCode NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL
    , strType NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, strScheduleList NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	, strReportSection NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	, intReportItemSequence INT NULL
	, intTemplateItemNumber INT NOT NULL
	, strDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	, strConfiguration NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, ysnConfiguration BIT NULL
	, ysnUserDefinedValue BIT NOT NULL
	, strLastIndexOf NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL
	, strSegment NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, intMasterId INT NULL
	, intSort INT NULL
	, ysnOutputDesigner BIT NULL
	, strInputType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)