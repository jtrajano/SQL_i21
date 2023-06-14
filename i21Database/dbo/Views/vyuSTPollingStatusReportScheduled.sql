CREATE VIEW [dbo].[vyuSTPollingStatusReportScheduled]  
AS
SELECT DISTINCT
sts.intStoreId,
stcp.intCheckoutProcessId,
stcpew.intCheckoutProcessErrorWarningId,
stcp.strGuid, 
FORMAT(GETDATE(), 'd','us') AS strActualReportDate,
CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportTime,
FORMAT(GETDATE(), 'd','us') + ' ' + CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportDateTime,
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') AS strReportDate,
stcp.dtmCheckoutProcessDate,
ISNULL(CH.dtmCheckoutDate, stcp.dtmCheckoutProcessDate) AS dtmCheckoutDate,
sts.intStoreNo, 
CAST(sts.intStoreNo AS VARCHAR(20)) + ' - ' + sts.strDescription AS strDescription, 
ISNULL(stcpew.strMessage, 
'Store did not automatically run for today. It is stuck on ' +
FORMAT((
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = sts.intStoreId
			GROUP BY stcpIn.intStoreId
		)
), 'd','us') + '. ' +
(SELECT cpewOutMsg.strMessage
FROM tblSTCheckoutProcessErrorWarning cpewOutMsg
WHERE cpewOutMsg.intCheckoutProcessErrorWarningId =
(
	SELECT TOP 1 MAX(intCheckoutProcessErrorWarningId) 
	FROM tblSTCheckoutProcessErrorWarning cpewInMsg
	JOIN tblSTCheckoutProcess cpInMsg
		ON cpewInMsg.intCheckoutProcessId = cpInMsg.intCheckoutProcessId
	WHERE cpInMsg.intStoreId = sts.intStoreId
	GROUP BY cpInMsg.intStoreId
)))
AS strMessage
FROM dbo.tblSTStore AS sts 
JOIN dbo.tblSTCheckoutProcess AS stcp 
	ON stcp.intStoreId = sts.intStoreId
JOIN dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
	ON stcp.intCheckoutProcessId = stcpew.intCheckoutProcessId 
JOIN dbo.tblSTCheckoutHeader CH
	ON stcpew.intCheckoutId = CH.intCheckoutId
WHERE 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') = FORMAT(GETDATE(), 'd','us')
AND CH.dtmCheckoutDate IS NOT NULL
UNION
SELECT a.intStoreId, 0 as intCheckoutProcessId, 0 as intCheckoutProcessErrorWarningId, '' AS strGuid, 
FORMAT(GETDATE(), 'd','us') AS strActualReportDate,
CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportTime,
FORMAT(GETDATE(), 'd','us') + ' ' + CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportDateTime,
FORMAT((
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
), 'd','us') as strReportDate, 
(
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
) AS dtmCheckoutProcessDate, 
(
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
) AS dtmCheckoutDate, a.intStoreNo, 
CAST(a.intStoreNo AS VARCHAR(20)) + ' - ' + a.strDescription AS strDescription, 
'Store did not automatically run for today. It is stuck on ' +
FORMAT((
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
), 'd','us') + '. ' +
(SELECT cpewOutMsg.strMessage
FROM tblSTCheckoutProcessErrorWarning cpewOutMsg
WHERE cpewOutMsg.intCheckoutProcessErrorWarningId =
(
	SELECT MAX(intCheckoutProcessErrorWarningId) 
	FROM tblSTCheckoutProcessErrorWarning cpewInMsg
	JOIN tblSTCheckoutProcess cpInMsg
		ON cpewInMsg.intCheckoutProcessId = cpInMsg.intCheckoutProcessId
	WHERE cpInMsg.intStoreId = a.intStoreId
	GROUP BY cpInMsg.intStoreId
))
AS strMessage
FROM tblSTStore a
WHERE 
a.intStoreId NOT IN 
(
	SELECT intStoreId
	FROM tblSTCheckoutProcess
	WHERE 
	FORMAT(dtmCheckoutProcessDate, 'd','us') = FORMAT(GETDATE(), 'd','us')
) 
AND 
a.intStoreId IN 
(
	SELECT intStoreId
	FROM tblSTCheckoutHeader
	WHERE intStoreId = a.intStoreId
)
AND
a.ysnConsignmentStore = 1
UNION
SELECT a.intStoreId, 0 as intCheckoutProcessId, 0 as intCheckoutProcessErrorWarningId, '' AS strGuid, 
FORMAT(GETDATE(), 'd','us') AS strActualReportDate,
CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportTime,
FORMAT(GETDATE(), 'd','us') + ' ' + CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportDateTime,
ISNULL(FORMAT((
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
), 'd','us'), FORMAT(GETDATE(), 'd','us')) as strReportDate, 
ISNULL((
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
),FORMAT(GETDATE(), 'd','us')) AS dtmCheckoutProcessDate, 
ISNULL((
	SELECT MAX(dtmCheckoutDate)
	FROM tblSTCheckoutHeader chIn
	JOIN tblSTCheckoutProcessErrorWarning ewIn
		ON chIn.intCheckoutId = ewIn.intCheckoutId
	JOIN tblSTCheckoutProcess cpIn
		ON ewIn.intCheckoutProcessId = cpIn.intCheckoutProcessId
	WHERE cpIn.intCheckoutProcessId =
		(
			SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
			FROM tblSTCheckoutProcess stcpIn
			JOIN tblSTCheckoutProcessErrorWarning stcpewIn
				ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
			WHERE stcpewIn.strMessageType = 'S'
			AND stcpIn.intStoreId = a.intStoreId
			GROUP BY stcpIn.intStoreId
		)
), FORMAT(GETDATE(), 'd','us')) AS dtmCheckoutDate, a.intStoreNo, 
CAST(a.intStoreNo AS VARCHAR(20)) + ' - ' + a.strDescription AS strDescription, 
'Store did not automatically run for today. No End of Day record found. '
AS strMessage
FROM tblSTStore a
WHERE 
a.intStoreId NOT IN 
(
	SELECT intStoreId
	FROM tblSTCheckoutHeader
	WHERE intStoreId = a.intStoreId
)