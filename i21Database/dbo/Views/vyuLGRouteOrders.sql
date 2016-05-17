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
	,Rte.intSequence
	,Rte.dblToLatitude
	,Rte.dblToLongitude
	,Rte.strToAddress
	,Rte.strToCity
	,Rte.strToState
	,Rte.strToZipCode
	,Rte.strToCountry
	,Rte.dblBalance
	,strOrderNumber =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.strOrderNumber ELSE LD.strLoadNumber END
	,dtmScheduledDate =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.dtmRequestedDate ELSE LD.dtmScheduledDate END
	,strEntityName =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.strCustomerName ELSE LD.strCustomer END
	,strOrderStatus =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.strOrderStatus ELSE LGL.strShipmentStatus END
	,strItemNo =				CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.strProduct ELSE LD.strItemNo END
	,dblQuantity =				CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.dblQuantity ELSE LD.dblQuantity END
	,strCustomerReference =		CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN '' ELSE LD.strCustomerReference END
	,strOrderComments =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN TMO.strComments ELSE LD.strComments END
	,Rte.strLocationType
	,strDestination =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN 
									TMO.strSiteAddress + ', ' + TMO.strSiteCity + ', ' + TMO.strSiteState + ' ' + TMO.strSiteZipCode 
								ELSE 
									CASE WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 THEN
										LD.strShipToAddress + ', ' + LD.strShipToCity + ', ' + LD.strShipToState + ' ' + LD.strShipToZipCode
									ELSE
										CASE WHEN IsNull(Rte.intCompanyLocationSubLocationId, 0) <> 0 THEN
											SubCompLoc.strAddress + ', ' + SubCompLoc.strCity + ', ' + SubCompLoc.strState + ' ' + SubCompLoc.strZipCode
										ELSE
											CASE WHEN IsNull(Rte.intCompanyLocationId, 0) <> 0 THEN
												CompLoc.strAddress + ', ' + CompLoc.strCity + ', ' + CompLoc.strStateProvince + ' ' + CompLoc.strZipPostalCode
											ELSE
												''
											END
										END 
									END
								END
	,strLocationName =			CASE WHEN IsNull(Rte.intDispatchID, 0) <> 0 THEN 
									TMO.strCompanyLocationName 
								ELSE 
									CASE WHEN IsNull(Rte.intLoadDetailId, 0) <> 0 THEN 
										LD.strSLocationName
									ELSE
										CASE WHEN IsNull(Rte.intCompanyLocationId, 0) <> 0 THEN
											CompLoc.strLocationName
										ELSE
											''
										END
									END
								END 
	,strSubLocation	=			CASE WHEN IsNull(Rte.intCompanyLocationSubLocationId, 0) <> 0 THEN 
									SubCompLoc.strSubLocationName
								ELSE 
									''
								END
FROM tblLGRouteOrder Rte
JOIN vyuLGRoute R ON R.intRouteId = Rte.intRouteId
LEFT JOIN vyuTMGeneratedCallEntry TMO ON TMO.intDispatchId = Rte.intDispatchID
LEFT JOIN vyuLGLoadDetailView LD ON LD.intLoadDetailId = Rte.intLoadDetailId
LEFT JOIN vyuLGLoadView LGL ON LGL.intLoadId = LD.intLoadId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = Rte.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubCompLoc ON SubCompLoc.intCompanyLocationSubLocationId = Rte.intCompanyLocationSubLocationId



