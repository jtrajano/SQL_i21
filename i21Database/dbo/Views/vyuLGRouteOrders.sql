CREATE VIEW vyuLGRouteOrders
AS
SELECT 
	Route.intRouteOrderId
	,Route.intRouteId
	,Route.intDispatchID
	,Route.intLoadDetailId
	,Route.intSequence
	,Route.dblToLatitude
	,Route.dblToLongitude
	,Route.strToAddress
	,Route.strToCity
	,Route.strToState
	,Route.strToZipCode
	,Route.strToCountry
	,strOrderNumber =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strOrderNumber ELSE LD.strLoadNumber END
	,strLocationName =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strCompanyLocationName ELSE LD.strSLocationName END 
	,dtmScheduledDate =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.dtmRequestedDate ELSE LD.dtmScheduledDate END
	,strEntityName =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strCustomerName ELSE LD.strCustomer END
	,strDestination =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strSiteAddress + ', ' + TMO.strSiteCity + ', ' + TMO.strSiteState + ' ' + TMO.strSiteZipCode ELSE LD.strShipToAddress + ', ' + LD.strShipToCity + ', ' + LD.strShipToState + ' ' + LD.strShipToZipCode  END
	,strOrderStatus =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strOrderStatus ELSE LGL.strShipmentStatus END
	,strDriver =				CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strDriverName ELSE LD.strDriver END
	,strItemNo =				CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strProduct ELSE LD.strItemNo END
	,dblQuantity =				CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.dblQuantity ELSE LD.dblQuantity END
	,strCustomerReference =		CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN '' ELSE LD.strCustomerReference END
	,strOrderComments =			CASE WHEN IsNull(Route.intDispatchID, 0) <> 0 THEN TMO.strComments ELSE LD.strComments END
FROM tblLGRouteOrder Route
LEFT JOIN vyuTMGeneratedCallEntry TMO ON TMO.intDispatchId = Route.intDispatchID
LEFT JOIN vyuLGLoadDetailView LD ON LD.intLoadDetailId = Route.intLoadDetailId
LEFT JOIN vyuLGLoadView LGL ON LGL.intLoadId = LD.intLoadId


