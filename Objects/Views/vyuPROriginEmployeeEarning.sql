--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployeeEarning]
AS
SELECT TOP 0
	intYear				= CAST(0 AS INT)
	,intQuarter			= CAST(0 AS INT)
	,strEmployeeNo		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strLastName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strFirstName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strMiddleName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strEarningCode		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strStateId			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckLiteral	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dblRegHours		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblRegEarning		= CAST(0.000000 AS NUMERIC(18, 6))
	,dtmLastCheckDate	= CAST(NULL AS DATETIME)
	,strEarningClass	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strMemoType		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strUserId			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dtmUserRevision	= CAST(NULL AS DATETIME)
	,intIdentityKey		= CAST(-999 AS INT)