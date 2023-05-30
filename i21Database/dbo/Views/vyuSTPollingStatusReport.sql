CREATE VIEW [dbo].[vyuSTPollingStatusReport]  
AS  
SELECT DISTINCT 
stcp.intStoreId, 
stcpew.intCheckoutProcessId, 
stcpew.intCheckoutProcessErrorWarningId, 
stcpew.intCheckoutId, 
stcp.strGuid, 
FORMAT(GETDATE(), 'd','us') AS strActualReportDate,
CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportTime,
FORMAT(GETDATE(), 'd','us') + ' ' + CONVERT(varchar(15),CONVERT(TIME, GETDATE()),100) AS strActualReportDateTime,
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') AS strReportDate,
(
	SELECT COUNT('') FROM (SELECT DISTINCT  intStoreId 
	FROM tblSTCheckoutProcess 
	WHERE FORMAT(dtmCheckoutProcessDate, 'd','us') = FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') 
	GROUP BY intStoreId) a
) AS intProcessedStore,

(
	SELECT COUNT('') FROM (SELECT DISTINCT intStoreId 
	FROM tblSTCheckoutProcess
	WHERE strGuid = stcp.strGuid
	GROUP BY intStoreId) a
) AS intProcessedStorePerGuid,

(
	SELECT COUNT('') FROM (SELECT DISTINCT chIn.dtmCheckoutDate  
	FROM tblSTCheckoutProcess cpIn
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cpIn.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON spew.intCheckoutId = chIn.intCheckoutId
	WHERE FORMAT(chIn.dtmCheckoutDate, 'd','us') = FORMAT(CH.dtmCheckoutDate, 'd','us') 
	GROUP BY chIn.dtmCheckoutDate) a
) AS intProcessedStorePerCheckoutDate,

(
	SELECT COUNT('') FROM (SELECT DISTINCT cpIn.intCheckoutId 
	FROM tblSTCheckoutProcess cpIn
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cpIn.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON spew.intCheckoutId = chIn.intCheckoutId
	WHERE chIn.intCheckoutId = stcpew.intCheckoutId
	GROUP BY cpIn.intCheckoutId) a
) AS intProcessedStorePerCheckout,

(
	SELECT COUNT('') FROM (SELECT DISTINCT cpIn.intStoreId 
	FROM tblSTCheckoutProcess cpIn
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cpIn.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON spew.intCheckoutId = chIn.intCheckoutId
	WHERE FORMAT(chIn.dtmCheckoutDate, 'd','us') = FORMAT(CH.dtmCheckoutDate, 'd','us') 
	AND cpIn.intStoreId = stcp.intStoreId
	GROUP BY cpIn.intStoreId) a
) AS intProcessedStorePerCheckoutDateAndStore,

(
	SELECT COUNT('') FROM (SELECT DISTINCT cpIn.intStoreId 
	FROM tblSTCheckoutProcess cpIn
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cpIn.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON spew.intCheckoutId = chIn.intCheckoutId
	WHERE FORMAT(cpIn.dtmCheckoutProcessDate, 'd','us') = FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') 
	AND cpIn.intStoreId = stcp.intStoreId
	GROUP BY cpIn.intStoreId) a
) AS intProcessedStorePerProcessedDatePerStore,

(
	SELECT COUNT('') FROM (SELECT DISTINCT  intStoreId 
	FROM tblSTCheckoutProcess cp
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cp.intCheckoutProcessId = spew.intCheckoutProcessId
	WHERE FORMAT(dtmCheckoutProcessDate, 'd','us') = FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') 
	AND (spew.strMessageType = 'F' OR spew.strMessageType = 'S')
	GROUP BY intStoreId) a
) AS intStoreWithError,

(
	SELECT COUNT('') FROM (SELECT DISTINCT  intStoreId 
	FROM tblSTCheckoutProcess cp
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cp.intCheckoutProcessId = spew.intCheckoutProcessId
	WHERE cp.strGuid = stcp.strGuid 
	AND (spew.strMessageType = 'F' OR spew.strMessageType = 'S')
	GROUP BY intStoreId) a
) AS intStoreWithErrorPerGuid,

(
	SELECT COUNT('') FROM (SELECT DISTINCT chIn.dtmCheckoutDate, cp.intStoreId 
	FROM tblSTCheckoutProcess cp
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cp.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON spew.intCheckoutId = chIn.intCheckoutId
	WHERE FORMAT(chIn.dtmCheckoutDate, 'd','us') = FORMAT(CH.dtmCheckoutDate, 'd','us') 
	AND (spew.strMessageType = 'F' OR spew.strMessageType = 'S')
	GROUP BY chIn.dtmCheckoutDate, cp.intStoreId) a
) AS intStoreWithErrorPerCheckoutDate,

(
	SELECT COUNT('') FROM (SELECT DISTINCT cp.intStoreId 
	FROM tblSTCheckoutProcess cp
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cp.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON cp.intCheckoutId = chIn.intCheckoutId
	WHERE FORMAT(chIn.dtmCheckoutDate, 'd','us') = FORMAT(CH.dtmCheckoutDate, 'd','us') 
	AND cp.intStoreId = stcp.intStoreId
	AND (spew.strMessageType = 'F' OR spew.strMessageType = 'S')
	GROUP BY cp.intStoreId) a
) AS intStoreWithErrorPerCheckoutDatePerStore,

(
	SELECT COUNT('') FROM (SELECT DISTINCT cp.intStoreId 
	FROM tblSTCheckoutProcess cp
	JOIN tblSTCheckoutProcessErrorWarning spew
		ON cp.intCheckoutProcessId = spew.intCheckoutProcessId
	JOIN tblSTCheckoutHeader chIn
		ON spew.intCheckoutId = chIn.intCheckoutId
	WHERE FORMAT(cp.dtmCheckoutProcessDate, 'd','us') = FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') 
	AND cp.intStoreId = stcp.intStoreId
	AND (spew.strMessageType = 'F' OR spew.strMessageType = 'S')
	GROUP BY cp.intStoreId) a
) AS intStoreWithErrorPerProcessDatePerStore,

stcp.dtmCheckoutProcessDate, 
CAST((CASE WHEN CH.strCheckoutCloseDate IS NULL THEN DATEADD(DAY, 1, stcp.dtmCheckoutProcessDate) ELSE DATEADD(DAY, 1, CH.strCheckoutCloseDate) END) AS DATETIME) AS dtmCurrentBusinessDay, 
CAST((CASE WHEN CH.strCheckoutCloseDate IS NULL THEN stcp.dtmCheckoutProcessDate ELSE CAST(CH.strCheckoutCloseDate AS VARCHAR(50)) END) AS VARCHAR(50)) AS strCheckoutCloseDate, 
ISNULL(CH.dtmCheckoutDate, CH.dtmCountDate) AS dtmCheckoutDate,
sts.intStoreNo, 
CAST(sts.intStoreNo AS VARCHAR(20)) + ' - ' + sts.strDescription AS strDescription, 
stcpew.strMessageType, 
stcpew.strMessage,
CASE
	WHEN stcp.strGuid = (SELECT TOP 1 strGuid FROM tblSTCheckoutProcess x WHERE x.intStoreId = stcp.intStoreId ORDER BY x.dtmCheckoutProcessDate DESC)
	THEN 1
	ELSE 0
	END ysnLatestGuid
FROM dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
INNER JOIN dbo.tblSTCheckoutProcess AS stcp 
	ON stcpew.intCheckoutProcessId = stcp.intCheckoutProcessId 
INNER JOIN dbo.tblSTStore AS sts 
	ON stcp.intStoreId = sts.intStoreId
LEFT JOIN dbo.tblSTCheckoutHeader CH
	ON stcpew.intCheckoutId = CH.intCheckoutId