CREATE VIEW [dbo].[vyuTMInventiryReport]
AS  
	SELECT 
		intInventoryHistoryId = IH.intInventoryHistoryId
		,strCustomerNumber = C.strEntityNo
		,strCustomerName = C.strName
		,intSiteNumber = A.intSiteNumber
		,strProduct = T.strDescription
		,dtmLastInventoryTime = IH.dtmLastInventoryTime
		,dblGrossVolume = 0
		,dblNetVolume = 0
		,dblUllage = TM.dblUllage
		,dblTotalCapacity = A.dblTotalCapacity
		,intFullPercent = 0
		,dblWaterHeight = TM.dblWaterHeight
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B	
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblTMInventoryHistory IH
		ON A.intSiteID = IH.intSiteId
	LEFT JOIN tblICItem T
		ON A.intProduct = T.intItemId 
	LEFT JOIN tblTMTankMonitor TM
		ON TM.intSiteId = A.intSiteID

	
GO