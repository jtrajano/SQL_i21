CREATE VIEW dbo.vyuARPerformanceLog
AS
SELECT intPerformanceLogId	= MIN(PL.intPerformanceLogId)
	 , strScreenName		= PL.strScreenName
	 , strProcedureName		= PL.strProcedureName
	 , strBuildNumber		= PL.strBuildNumber
	 , dtmStartDateTime		= MIN(dtmStartDateTime)
	 , dtmEndDateTime		= MAX(dtmEndDateTime)
	 , strTimeElapse		= CONVERT(NVARCHAR(200), CAST((MAX(dtmEndDateTime)-MIN(dtmStartDateTime)) AS TIME(0)))
	 , intUserId			= PL.intUserId
	 , strUserName			= LTRIM(RTRIM(E.strName))
FROM tblARPerformanceLog PL
LEFT JOIN tblEMEntity E ON PL.intUserId = E.intEntityId
WHERE PL.dtmEndDateTime IS NOT NULL
  AND PL.dtmStartDateTime IS NOT NULL
GROUP BY PL.strScreenName, PL.strProcedureName, PL.strBuildNumber, PL.intUserId, CAST(CONVERT(CHAR(16), PL.dtmStartDateTime,20) AS DATETIME), CAST(CONVERT(CHAR(16), PL.dtmEndDateTime,20) AS DATETIME), E.strName