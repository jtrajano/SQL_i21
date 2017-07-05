--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployeeEarning]
AS
SELECT TOP 0
	intYear				= CAST(0 AS INT)
	,intQuarter			= CAST(0 AS INT)
	,strEmployeeNo		= CAST('' AS NVARCHAR(200))
	,strEarningCode		= CAST('' AS NVARCHAR(200))
	,strStateId			= CAST('' AS NVARCHAR(200))
	,strCheckLiteral	= CAST('' AS NVARCHAR(200))
	,dblRegHours		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblRegEarning		= CAST(0.000000 AS NUMERIC(18, 6))
	,dtmLastCheckDate	= CAST(NULL AS DATETIME)
	,strEarningClass	= CAST('' AS NVARCHAR(200))
	,strMemoType		= CAST('' AS NVARCHAR(200))
	,strUserId			= CAST('' AS NVARCHAR(200))
	,dtmUserRevision	= CAST(NULL AS DATETIME)
	,intIdentityKey		= CAST(-999 AS INT)