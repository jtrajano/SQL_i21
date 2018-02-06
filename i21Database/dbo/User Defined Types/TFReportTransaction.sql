CREATE TYPE [dbo].[TFReportTransaction] AS TABLE
(
	strFormCode NVARCHAR(100),
	strScheduleCode NVARCHAR(100),
	strType NVARCHAR(100),
	strProductCode NVARCHAR(100),
	dblReceived NUMERIC(18, 6)
)
