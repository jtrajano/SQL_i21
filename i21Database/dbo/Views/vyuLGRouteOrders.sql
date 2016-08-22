CREATE VIEW vyuLGRouteOrders
AS
SELECT 
 Rte.intRouteOrderId
 ,Rte.intRouteId
 ,R.strRouteNumber
 ,R.strDriver
 ,R.dtmDispatchedDate
 ,R.dblTruckCapacity
 ,R.strComments
 ,R.strFromLocation
 ,R.strFromSubLocation
 ,Rte.intDispatchID
 ,Rte.intLoadDetailId
 ,Rte.intCustomerID
 ,Rte.intSiteID
 ,Rte.intEntityLocationId
 ,Rte.intEntityTypeId
 ,Rte.intSequence
 ,Rte.dblToLatitude
 ,Rte.dblToLongitude
 ,Rte.strToAddress
 ,Rte.strToCity
 ,Rte.strToState
 ,Rte.strToZipCode
 ,Rte.strToCountry
 ,Rte.dblBalance
 ,strOrderNumber =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.strOrderNumber 
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.strLoadNumber 
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery'
          THEN TMH.strOrderNumber
         END Collate Latin1_General_CI_AS

 ,dtmScheduledDate =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.dtmRequestedDate 
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.dtmScheduledDate
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery' 
          THEN TMH.dtmRequestedDate
         END 

 ,strEntityName =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.strCustomerName 
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.strCustomer
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery'
          THEN TMH.strCustomerName
         WHEN IsNull(Rte.intCustomerID, 0) <> 0 
          THEN TMSite.strCustomerName
         WHEN IsNull(Rte.intEntityLocationId, 0) <> 0
          THEN EN.strName
         END Collate Latin1_General_CI_AS
 
 ,strOrderStatus =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.strOrderStatus
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LGL.strShipmentStatus
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery'
          THEN TMH.strOrderStatus
         END Collate Latin1_General_CI_AS
 
 ,strItemNo =    CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.strProduct
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.strItemNo
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery'
          THEN TMH.strProduct
         END Collate Latin1_General_CI_AS
 
 ,dblQuantity =    CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.dblQuantity
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.dblQuantity
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery' 
          THEN TMH.dblQuantity
         END
 
 ,strCustomerReference =  CASE WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 THEN LD.strCustomerReference ELSE '' END
 ,strOrderComments =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.strComments
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.strComments
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery'
          THEN TMH.strComments
         END Collate Latin1_General_CI_AS
 
 ,Rte.strLocationType
 ,strDestination =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.strSiteAddress + ', ' + TMO.strSiteCity + ', ' + TMO.strSiteState + ' ' + TMO.strSiteZipCode 
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 
          THEN LD.strShipToAddress + ', ' + LD.strShipToCity + ', ' + LD.strShipToState + ' ' + LD.strShipToZipCode
         WHEN IsNull(Rte.intCompanyLocationSubLocationId, 0) <> 0 
          THEN SubCompLoc.strAddress + ', ' + SubCompLoc.strCity + ', ' + SubCompLoc.strState + ' ' + SubCompLoc.strZipCode
         WHEN IsNull(Rte.intCompanyLocationId, 0) <> 0 
          THEN CompLoc.strAddress + ', ' + CompLoc.strCity + ', ' + CompLoc.strStateProvince + ' ' + CompLoc.strZipPostalCode
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery' 
          THEN TMH.strSiteAddress + ', ' + TMH.strSiteCity + ', ' + TMH.strSiteState + ' ' + TMH.strSiteZipCode 
         WHEN IsNull(Rte.intCustomerID, 0) <> 0 
          THEN TMSite.strSiteAddress + ', ' + TMSite.strSiteCity + ', ' + TMSite.strSiteState + ' ' + TMSite.strSiteZip
         WHEN IsNull(Rte.intEntityLocationId, 0) <> 0 
          THEN EL.strAddress + ', ' + EL.strCity + ', ' + EL.strState + ' ' + EL.strZipCode 
        END Collate Latin1_General_CI_AS
 ,strLocationName =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0
          THEN TMO.strCompanyLocationName
         WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 THEN
          LD.strSLocationName
         WHEN IsNull(Rte.intCompanyLocationId, 0) <> 0 THEN
           CompLoc.strLocationName
         WHEN IsNull(Rte.intDispatchID, 0) <> 0 AND Rte.strLocationType = 'Delivery'
          THEN TMH.strCompanyLocationName
        END Collate Latin1_General_CI_AS
 ,strSubLocation =   CASE WHEN IsNull(Rte.intCompanyLocationSubLocationId, 0) <> 0 THEN 
         SubCompLoc.strSubLocationName
        ELSE 
         ''
        END
 ,intLoadId = LD.intLoadId
 ,strEntityType = ET.strType
 ,ysnLeakCheckRequired =   CASE WHEN IsNull(TMO.intDispatchId, 0) <> 0 
          THEN TMO.ysnLeakCheckRequired 
         WHEN IsNull(TMH.intDispatchId, 0) <> 0 AND Rte.strLocationType = 'Delivery' 
          THEN TMH.ysnLeakCheckRequired
		 ELSE
			Cast (0 as Bit)	
         END
FROM tblLGRouteOrder Rte
JOIN vyuLGRoute R ON R.intRouteId = Rte.intRouteId
LEFT JOIN vyuTMGeneratedCallEntry TMO ON TMO.intDispatchId = Rte.intDispatchID
LEFT JOIN vyuTMDeliveryHistoryCallEntry TMH ON TMH.intDispatchId = Rte.intDispatchID
LEFT JOIN vyuLGLoadDetailView LD ON LD.intLoadDetailId = Rte.intLoadDetailId
LEFT JOIN vyuLGLoadView LGL ON LGL.intLoadId = LD.intLoadId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = Rte.intEntityLocationId
LEFT JOIN tblEMEntityType ET ON ET.intEntityTypeId = Rte.intEntityTypeId
LEFT JOIN tblEMEntity EN ON EN.intEntityId = EL.intEntityId
LEFT JOIN vyuTMCustomerConsumptionSiteInfo TMSite ON TMSite.intCustomerId = Rte.intCustomerID and TMSite.intSiteId = Rte.intSiteID
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = Rte.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubCompLoc ON SubCompLoc.intCompanyLocationSubLocationId = Rte.intCompanyLocationSubLocationId