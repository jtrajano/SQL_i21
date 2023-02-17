CREATE VIEW [dbo].[vyuTMInventiryReport]
AS  
	SELECT 
		intInventoryHistoryId = IH.intInventoryHistoryId
		,strCustomerNumber = C.strEntityNo
		,strCustomerName = C.strName
		,IH.intSiteId
		,intSiteNumber = A.intSiteNumber
		,strProduct = T.strDescription
		,dtmLastInventoryTime = IH.dtmLastInventoryTime
		,dblGrossVolume = TM.dblFuelVolume
		,dblNetVolume = TM.dblTempCompensatedVolume
		,dblUllage = TM.dblUllage
		,dblTotalCapacity = A.dblTotalCapacity
		,dblFullPercent = (TM.dblFuelVolume/A.dblTotalCapacity)
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
	LEFT JOIN tblTMTankReading TM
		ON TM.intSiteId = A.intSiteID

	
GO