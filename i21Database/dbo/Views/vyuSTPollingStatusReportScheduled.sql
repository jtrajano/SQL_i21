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
stcpew.strMessage
FROM dbo.tblSTStore AS sts 
JOIN dbo.tblSTCheckoutProcess AS stcp 
	ON stcp.intStoreId = sts.intStoreId
JOIN dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
	ON stcp.intCheckoutProcessId = stcpew.intCheckoutProcessId 
JOIN dbo.tblSTCheckoutHeader CH
	ON stcpew.intCheckoutId = CH.intCheckoutId
WHERE 
FORMAT(stcp.dtmCheckoutProcessDate, 'd','us') = FORMAT(GETDATE(), 'd','us')
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
UNION
SELECT a.intStoreId, 0 as intCheckoutProcessId, '' AS strGuid, FORMAT(GETDATE(), 'd','us') as strReportDate, GETDATE() AS dtmCheckoutProcessDate, GETDATE() - 1 AS dtmCheckoutDate, a.intStoreNo, a.strDescription, 'Store did not automatically run Today.'
FROM tblSTStore a
WHERE 
a.intStoreId NOT IN (SELECT intStoreId FROM tblSTCheckoutProcess WHERE FORMAT(dtmCheckoutProcessDate, 'd','us') = FORMAT(GETDATE(), 'd','us')) 
AND 
a.ysnConsignmentStore = 1