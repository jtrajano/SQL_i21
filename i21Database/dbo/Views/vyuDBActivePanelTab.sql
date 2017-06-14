CREATE VIEW [dbo].[vyuDBActivePanelTab]
	AS 
SELECT  
	A.intPanelTabId, 
	A.intUserId, 
	A.intSort, 
	A.intColumnCount,
	A.strTabName,
	COUNT(B.intPanelId) intTotalPanels
FROM tblDBPanelTab A
LEFT JOIN tblDBPanelUser B ON B.intPanelTabId = A.intPanelTabId
LEFT JOIN tblDBPanelAccess C ON A.intUserId = C.intUserId AND C.intPanelId = B.intPanelId
WHERE A.intUserId = 1
GROUP BY A.intPanelTabId, A.intUserId, A.intSort, A.intColumnCount, A.strTabName

