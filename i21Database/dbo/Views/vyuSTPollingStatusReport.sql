﻿CREATE VIEW [dbo].[vyuSTPollingStatusReport]  
AS  

SELECT DISTINCT 
stcp.intStoreId, 
stcpew.intCheckoutProcessId, 
stcpew.intCheckoutProcessErrorWarningId, 
stcp.intCheckoutId, 
stcp.strGuid, 
stcp.dtmCheckoutProcessDate, 
CAST((CASE WHEN CH.strCheckoutCloseDate IS NULL THEN DATEADD(DAY, 1, stcp.dtmCheckoutProcessDate) ELSE DATEADD(DAY, 1, CH.strCheckoutCloseDate) END) AS DATETIME) AS dtmCurrentBusinessDay, 
CAST((CASE WHEN CH.strCheckoutCloseDate IS NULL THEN stcp.dtmCheckoutProcessDate ELSE CAST(CH.strCheckoutCloseDate AS VARCHAR(50)) END) AS VARCHAR(50)) AS strCheckoutCloseDate, 
ISNULL(CH.dtmCheckoutDate, CH.dtmCountDate) AS dtmCheckoutDate,
sts.intStoreNo, 
sts.strDescription, 
stcpew.strMessageType, 
stcpew.strMessage, 
0 AS intProcessedStore, 
0 AS intStoreWithError, 
0 AS rn, 
'' COLLATE Latin1_General_CI_AS AS strReportFilter
FROM dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
INNER JOIN dbo.tblSTCheckoutProcess AS stcp 
	ON stcpew.intCheckoutProcessId = stcp.intCheckoutProcessId 
INNER JOIN dbo.tblSTStore AS sts 
	ON stcp.intStoreId = sts.intStoreId
LEFT OUTER JOIN dbo.tblSTCheckoutHeader CH
	ON stcp.intCheckoutId = CH.intCheckoutId
GROUP BY stcp.intStoreId, stcpew.intCheckoutProcessId, stcpew.intCheckoutProcessErrorWarningId, stcp.intCheckoutId, 
stcp.strGuid, stcp.dtmCheckoutProcessDate, CH.dtmCheckoutDate, CH.dtmCountDate, sts.intStoreNo, sts.strDescription, stcpew.strMessageType, stcpew.strMessage, CH.strCheckoutCloseDate
HAVING CH.dtmCheckoutDate IS NOT NULL