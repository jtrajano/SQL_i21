CREATE TYPE [dbo].[TFReportTransaction] AS TABLE
(
	strFormCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strScheduleCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strType NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strProductCode NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblReceived NUMERIC(18, 6)
)
