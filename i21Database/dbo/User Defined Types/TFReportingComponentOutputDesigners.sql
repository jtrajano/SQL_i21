CREATE TYPE [dbo].[TFReportingComponentOutputDesigners] AS TABLE (
	intScheduleColumnId INT NOT NULL
	, strFormCode NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
    , strScheduleCode NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL
    , strType NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, strColumn NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strCaption NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strFormat NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strFooter NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, intWidth INT NULL
	, intMasterId INT NULL
)