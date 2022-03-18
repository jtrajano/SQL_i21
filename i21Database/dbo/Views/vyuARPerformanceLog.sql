CREATE VIEW dbo.vyuARPerformanceLog
AS
SELECT intPerformanceLogId	= PL.intPerformanceLogId
	 , strScreenName		= PL.strScreenName
	 , strProcedureName		= PL.strProcedureName
	 , strBuildNumber		= PL.strBuildNumber
	 , dtmStartDateTime		= dtmStartDateTime
	 , dtmEndDateTime		= dtmEndDateTime
	 , strTimeElapse		= CONVERT(NVARCHAR(200), CAST((dtmEndDateTime - dtmStartDateTime) AS TIME(0)))
	 , strRequestId			= PL.strRequestId
	 , intUserId			= PL.intUserId
	 , strUserName			= LTRIM(RTRIM(E.strName))
FROM tblARPerformanceLog PL
LEFT JOIN tblEMEntity E ON PL.intUserId = E.intEntityId
WHERE PL.dtmEndDateTime IS NOT NULL
  AND PL.dtmStartDateTime IS NOT NULL