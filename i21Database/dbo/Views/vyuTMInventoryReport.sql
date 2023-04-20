CREATE VIEW vyuTMInventoryReport
AS
		SELECT distinct
			strSiteNumber = '0000' + CAST(A.intSiteNumber AS varchar(10)) 
			,strProduct = T.strItemNo
			,strLocation= case when EL.strLocationName is null then location.strLocationName else EL.strLocationName end
			,dblFullPercentForOrder = (dblGrossVolume.dblFuelVolume/dblTotalCapacity.dblTotalCapacity) * 100
			,dtmLastInventoryTime = dtmLastInventoryTime.dtmDateTime
			,dblGrossVolume = dblGrossVolume.dblFuelVolume
			,dblNetVolume = dblNetVolume.dblTempCompensatedVolume
			,dblUllage = dblUllage.dblUllage
			,dblTotalCapacity = dblTotalCapacity.dblTotalCapacity
			,dblWaterHeight = dblWaterHeight.dblWaterHeight
		FROM tblTMSite A
		INNER JOIN tblTMCustomer B	
			ON A.intCustomerID = B.intCustomerID
		INNER JOIN tblEMEntity C
			ON B.intCustomerNumber = C.intEntityId
		LEFT JOIN tblICItem T
			ON A.intProduct = T.intItemId 
		INNER JOIN tblTMTankReading TM
			ON TM.intSiteId = A.intSiteID
		LEFT JOIN (tblEMEntityLocationConsumptionSite LCS JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LCS.intEntityLocationId) ON LCS.intSiteID = A.intSiteID	
		LEFT JOIN tblSMCompanyLocation location ON location.intCompanyLocationId = A.intLocationId
		OUTER APPLY(
			SELECT top 1  TM.dtmDateTime FROM tblTMSite S INNER JOIN tblTMTankReading TM ON TM.intSiteId = S.intSiteID where TM.intSiteId = A.intSiteID order by TM.intTankReadingId desc
		)dtmLastInventoryTime
		OUTER APPLY(
			SELECT top 1 TM.dblFuelVolume FROM tblTMSite S INNER JOIN tblTMTankReading TM ON TM.intSiteId = S.intSiteID where TM.intSiteId = A.intSiteID order by TM.intTankReadingId desc
		)dblGrossVolume
		OUTER APPLY(
			SELECT top 1 TM.dblTempCompensatedVolume FROM tblTMSite S INNER JOIN tblTMTankReading TM ON TM.intSiteId = S.intSiteID where TM.intSiteId = A.intSiteID order by TM.intTankReadingId desc
		)dblNetVolume
		OUTER APPLY(
			SELECT top 1 TM.dblUllage FROM tblTMSite S INNER JOIN tblTMTankReading TM ON TM.intSiteId = S.intSiteID where TM.intSiteId = A.intSiteID order by TM.intTankReadingId desc
		)dblUllage
		OUTER APPLY(
			SELECT top 1 A.dblTotalCapacity FROM tblTMSite S INNER JOIN tblTMTankReading TM ON TM.intSiteId = S.intSiteID where TM.intSiteId = A.intSiteID order by TM.intTankReadingId desc
		)dblTotalCapacity
		OUTER APPLY(
			SELECT top 1 TM.dblWaterHeight FROM tblTMSite S INNER JOIN tblTMTankReading TM ON TM.intSiteId = S.intSiteID where TM.intSiteId = A.intSiteID order by TM.intTankReadingId desc
		)dblWaterHeight
