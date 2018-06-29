CREATE VIEW [dbo].[vyuDBActivePanel]
	AS 
SELECT A.intPanelUserId,
	A.intPanelId, 
	A.intPanelTabId,
	A.intSort, 
	A.intUserId, 
	C.intRowsVisible, 
	C.intChartZoom, 
	C.intChartHeight, 
	C.intSourcePanelId, 
	C.intConnectionId, 
	C.intDrillDownPanel, 
	C.strPanelName, 
	C.strStyle, 
	C.strConfigurator,
	C.strGroupFields,
	C.strSortValue,
	C.ysnAutoRefresh,
	C.intAutoRefreshInterval,
	C.intGridLayoutId
FROM tblDBPanelUser A
INNER JOIN tblDBPanelAccess B ON B.intPanelId = A.intPanelId
INNER JOIN tblDBPanel C ON C.intPanelId = A.intPanelId
WHERE B.ysnShow = 1
