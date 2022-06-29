CREATE VIEW [dbo].[vyuSTPollingStatusReport]  
AS  

SELECT DISTINCT 
stcp.intStoreId, 
stcpew.intCheckoutProcessId, 
stcpew.intCheckoutProcessErrorWarningId, 
stcp.intCheckoutId, 
stcp.strGuid, 
stcp.dtmCheckoutProcessDate, 
stcp.dtmCheckoutProcessDate + 1 AS dtmCurrentBusinessDay, 
stcp.dtmCheckoutProcessDate AS strCheckoutCloseDate, 
sts.intStoreNo, 
sts.strDescription, 
stcpew.strMessageType, 
stcpew.strMessage, 
0 AS intProcessedStore, 
0 AS intStoreWithError, 
0 AS rn, 
'' AS strReportFilter
FROM dbo.tblSTCheckoutProcessErrorWarning AS stcpew 
INNER JOIN dbo.tblSTCheckoutProcess AS stcp ON stcpew.intCheckoutProcessId = stcp.intCheckoutProcessId 
INNER JOIN dbo.tblSTStore AS sts ON stcp.intStoreId = sts.intStoreId
GROUP BY stcp.intStoreId, stcpew.intCheckoutProcessId, stcpew.intCheckoutProcessErrorWarningId, stcp.intCheckoutId, 
stcp.strGuid, stcp.dtmCheckoutProcessDate, sts.intStoreNo, sts.strDescription, stcpew.strMessageType, stcpew.strMessage