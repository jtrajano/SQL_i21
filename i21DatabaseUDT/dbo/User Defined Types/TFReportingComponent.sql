CREATE TYPE [dbo].[TFReportingComponent] AS TABLE (
	intReportingComponentId INT NOT NULL
	, strFormCode NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strFormName NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strScheduleCode NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL
	, strScheduleName NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, strType NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, intComponentTypeId INT NULL
	, strNote NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
	, intSort INT NULL
	, strStoredProcedure NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intMasterId INT NULL
)