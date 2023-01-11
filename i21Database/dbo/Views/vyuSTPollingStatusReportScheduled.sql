CREATE VIEW [dbo].[vyuSTPollingStatusReportScheduled]  
AS
SELECT DISTINCT
sts.intStoreId,
stcp.intCheckoutProcessId,
stcp.strGuid, 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') AS strReportDate,
stcp.dtmCheckoutProcessDate,
ISNULL(CH.dtmCheckoutDate, stcp.dtmCheckoutProcessDate) AS dtmCheckoutDate,
sts.intStoreNo, 
sts.strDescription, 
ISNULL(stcpew.strMessage, 
'Store did not automatically run for today, which was stucked on ' +
FORMAT(
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
					AND stcpIn.intStoreId = sts.intStoreId
					GROUP BY stcpIn.intStoreId
				)
		), 'd','us') + ' and invariably encountered an error on stop condition which prevented it from processing.'
) AS strMessage
FROM dbo.tblSTStore AS sts 
FULL OUTER JOIN dbo.tblSTCheckoutProcess AS stcp 
	ON stcp.intStoreId = sts.intStoreId
FULL OUTER  JOIN dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
	ON stcp.intCheckoutProcessId = stcpew.intCheckoutProcessId 
FULL OUTER  JOIN dbo.tblSTCheckoutHeader CH
	ON stcpew.intCheckoutId = CH.intCheckoutId
WHERE 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') = FORMAT(GETDATE(), 'd','us')
--AND stcpew.strMessageType <> 'F'
GROUP BY
sts.intStoreId,
stcp.intCheckoutProcessId,
stcp.strGuid, 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us'),
stcp.dtmCheckoutProcessDate,
CH.dtmCheckoutDate,
sts.intStoreNo, 
sts.strDescription,
stcpew.strMessage
--HAVING CH.dtmCheckoutDate IS NOT NULL
UNION
SELECT a.intStoreId, 0 as intCheckoutProcessId, '' AS strGuid, 
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
), 'd','us') as strReportDate, GETDATE() AS dtmCheckoutProcessDate, GETDATE() - 1 AS dtmCheckoutDate, a.intStoreNo, a.strDescription, 'Store did not automatically run for today, which was stucked on ' +
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
), 'd','us') + ' and invariably encountered an error on stop condition which prevented it from processing.' AS strMessage
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
a.ysnConsignmentStore = 1
UNION
SELECT DISTINCT
sts.intStoreId,
stcp.intCheckoutProcessId,
stcp.strGuid, 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') AS strReportDate,
stcp.dtmCheckoutProcessDate,
ISNULL(CH.dtmCheckoutDate, stcp.dtmCheckoutProcessDate) AS dtmCheckoutDate,
sts.intStoreNo, 
sts.strDescription, 
ISNULL(stcpew.strMessage, 
'Store did not automatically run for today, which was stucked on ' +
FORMAT(
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
				AND stcpIn.intStoreId = sts.intStoreId
				GROUP BY stcpIn.intStoreId
			)
	), 'd','us') + ' and invariably encountered an error on stop condition which prevented it from processing.'
) AS strMessage
FROM dbo.tblSTStore AS sts 
FULL OUTER JOIN dbo.tblSTCheckoutProcess AS stcp 
	ON stcp.intStoreId = sts.intStoreId
FULL OUTER  JOIN dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
	ON stcp.intCheckoutProcessId = stcpew.intCheckoutProcessId 
FULL OUTER  JOIN dbo.tblSTCheckoutHeader CH
	ON stcpew.intCheckoutId = CH.intCheckoutId
WHERE 
stcp.intCheckoutProcessId IN
(
	SELECT DISTINCT MAX(stcpIn.intCheckoutProcessId)
	FROM tblSTCheckoutProcess stcpIn
	JOIN tblSTCheckoutProcessErrorWarning stcpewIn
		ON stcpIn.intCheckoutProcessId = stcpewIn.intCheckoutProcessId
	WHERE stcpewIn.strMessageType = 'S' --OR stcpewIn.strMessageType = 'F'
	GROUP BY stcpIn.intStoreId
)
AND
sts.intStoreId NOT IN 
(
	SELECT intStoreId
	FROM tblSTCheckoutProcess
	WHERE 
	FORMAT(dtmCheckoutProcessDate, 'd','us') = FORMAT(GETDATE(), 'd','us')
) 
AND
sts.ysnConsignmentStore = 1
GROUP BY
sts.intStoreId,
stcp.intCheckoutProcessId,
stcp.strGuid, 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us'),
stcp.dtmCheckoutProcessDate,
CH.dtmCheckoutDate,
sts.intStoreNo, 
sts.strDescription,
stcpew.strMessage
HAVING CH.dtmCheckoutDate IS NOT NULL