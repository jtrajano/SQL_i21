--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployeeChangeHistory]
AS
SELECT TOP 0
	strEmployeeNo	= CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS 
	,strLastName	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strFirstName	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strMiddleName	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dtmDate		= CAST(NULL AS DATETIME)
	,dtmTime		= CAST(NULL AS DATETIME)
	,strFieldName	= CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS 
	,strOldData		= CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS 
	,strNewData		= CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS 
	,strUserId		= CAST('' AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS 
	,intIdentityKey	= CAST(-999 AS INT)