CREATE VIEW dbo.vyuARPerformanceLog
AS
SELECT intPerformanceLogId	= PL.intPerformanceLogId
	 , strScreenName		= PL.strScreenName
	 , strProcedureName		= PL.strProcedureName
	 , strBuildNumber		= PL.strBuildNumber
	 , dtmStartDateTime		= PL.dtmStartDateTime
	 , dtmEndDateTime		= PL.dtmEndDateTime 
	 , strTimeElapse		= CONVERT(NVARCHAR(200), CAST((PL.dtmEndDateTime-PL.dtmStartDateTime) AS TIME(0)))
	 , intUserId			= PL.intUserId
	 , strUserName			= LTRIM(RTRIM(E.strName))
FROM tblARPerformanceLog PL
LEFT JOIN tblEMEntity E ON PL.intUserId = E.intEntityId
WHERE PL.dtmEndDateTime IS NOT NULL
  AND PL.dtmStartDateTime IS NOT NULL