CREATE VIEW [dbo].[vyuSTPollingStatusReport]  
AS  
SELECT DISTINCT 
stch.intStoreId, 
stcpew.intCheckoutProcessId, 
stcpew.intCheckoutProcessErrorWarningId, 
stcp.intCheckoutId, 
stcp.strGuid, 
stcp.dtmCheckoutProcessDate, 
stcp.dtmCheckoutProcessDate + 1 AS dtmCurrentBusinessDay, 
stch.strCheckoutCloseDate, 
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
INNER JOIN dbo.tblSTCheckoutHeader AS stch ON stcp.intCheckoutId = stch.intCheckoutId 
INNER JOIN dbo.tblSTStore AS sts ON stch.intStoreId = sts.intStoreId
GROUP BY stch.intStoreId, stcpew.intCheckoutProcessId, stcpew.intCheckoutProcessErrorWarningId, stcp.intCheckoutId, stcp.strGuid, 
stcp.dtmCheckoutProcessDate, stch.strCheckoutCloseDate, sts.intStoreNo, sts.strDescription, stcpew.strMessageType, stcpew.strMessage