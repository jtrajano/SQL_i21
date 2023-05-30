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