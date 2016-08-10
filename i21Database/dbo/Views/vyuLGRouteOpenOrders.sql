CREATE VIEW vyuLGRouteOpenOrders
AS

SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intSourceType)) as intKeyColumn,*  FROM (
SELECT 
	intSourceType = 2
	,intOrderId = TMO.intDispatchId
	,intDispatchID = TMO.intDispatchId
	,intLoadDetailId = NULL
	,intSequence = -1
	,strOrderNumber = TMO.strOrderNumber
	,strLocationName = TMO.strCompanyLocationName
	,intLocationId = TMO.intCompanyLocationId
	,strLocationAddress = CompLoc.strAddress
	,strLocationCity = CompLoc.strCity
	,strLocationZipCode = CompLoc.strZipPostalCode
	,strLocationState = CompLoc.strStateProvince
	,strLocationCountry = CompLoc.strCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = TMO.dtmRequestedDate
	,strEntityName = TMO.strCustomerName
	,strToAddress = TMO.strSiteAddress
	,strToCity = TMO.strSiteCity
	,strToZipCode = TMO.strSiteZipCode
	,strToState = TMO.strSiteState
	,strToCountry = TMO.strSiteCountry
	,strDestination = TMO.strSiteAddress + ', ' + TMO.strSiteCity + ', ' + TMO.strSiteState + ' ' + TMO.strSiteZipCode 
	,dblToLongitude = TMO.dblLongitude
	,dblToLatitude = TMO.dblLatitude
	,strOrderStatus = TMO.strOrderStatus
	,strDriver = TMO.strDriverName
	,strItemNo = TMO.strProduct
	,dblQuantity = TMO.dblQuantity
	,strCustomerReference = ''
	,strOrderComments = TMO.strComments
	,strLocationType = 'Delivery'
	,intDaysPassed = DATEDIFF (day, TMO.dtmRequestedDate, GetDate())
	,strOrderType = 'Outbound'
	,intPriority = TMO.intPriority

FROM vyuTMGeneratedCallEntry TMO 
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = TMO.intCompanyLocationId
WHERE TMO.strOrderStatus <> 'Delivered' AND TMO.strOrderStatus <> 'Routed'

UNION ALL

SELECT
	intSourceType = 1
	,intOrderId = LGLD.intLoadDetailId
	,intDispatchID = NULL
	,intLoadDetailId = LGLD.intLoadDetailId
	,intSequence = -1
	,strOrderNumber = LGLD.strLoadNumber
	,strLocationName = LGLD.strSLocationName
	,intLocationId = LGLD.intSCompanyLocationId
	,strLocationAddress = LGLD.strSLocationAddress
	,strLocationCity = LGLD.strSLocationCity
	,strLocationZipCode = LGLD.strSLocationZipCode
	,strLocationState = LGLD.strSLocationState
	,strLocationCountry = LGLD.strSLocationCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = LGL.dtmScheduledDate
	,strEntityName = LGLD.strCustomer
	,strToAddress = LGLD.strShipToAddress
	,strToCity = LGLD.strShipToCity
	,strToZipCode = LGLD.strShipToZipCode
	,strToState = LGLD.strShipToState
	,strToCountry = LGLD.strShipToCountry
	,strDestination = LGLD.strShipToAddress + ', ' + LGLD.strShipToCity + ', ' + LGLD.strShipToState + ' ' + LGLD.strShipToZipCode 
	,dblToLongitude = EML.dblLongitude
	,dblToLatitude = EML.dblLatitude
	,strOrderStatus = LGL.strShipmentStatus
	,strDriver = LGL.strDriver
	,strItemNo = LGLD.strItemNo
	,dblQuantity = LGLD.dblQuantity
	,strCustomerReference = LGLD.strCustomerReference
	,strOrderComments = LGLD.strComments
	,strLocationType = 'Delivery'
	,intDaysPassed = DATEDIFF (day, LGL.dtmScheduledDate, GetDate())
	,strOrderType = 'Outbound'
	,intPriority = -1

FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intSCompanyLocationId
JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = LGLD.intCustomerEntityLocationId
WHERE LGL.intPurchaseSale = 2 AND LGL.intShipmentStatus = 1 AND IsNull(LGLD.intLoadDetailId, 0) NOT IN (SELECT IsNull(intLoadDetailId, 0) FROM tblLGRouteOrder)

UNION ALL

SELECT
	intSourceType = 3
	,intOrderId = LGLD.intLoadDetailId
	,intDispatchID = NULL
	,intLoadDetailId = LGLD.intLoadDetailId
	,intSequence = -1
	,strOrderNumber = LGLD.strLoadNumber
	,strLocationName = LGLD.strPLocationName
	,intLocationId = LGLD.intPCompanyLocationId
	,strLocationAddress = LGLD.strPLocationAddress
	,strLocationCity = LGLD.strPLocationCity
	,strLocationZipCode = LGLD.strPLocationZipCode
	,strLocationState = LGLD.strPLocationState
	,strLocationCountry = LGLD.strPLocationCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = LGL.dtmScheduledDate
	,strEntityName = LGLD.strVendor
	,strToAddress = LGLD.strShipFromAddress
	,strToCity = LGLD.strShipFromCity
	,strToZipCode = LGLD.strShipFromZipCode
	,strToState = LGLD.strShipFromState
	,strToCountry = LGLD.strShipFromCountry
	,strDestination = LGLD.strShipFromAddress + ', ' + LGLD.strShipFromCity + ', ' + LGLD.strShipFromState + ' ' + LGLD.strShipFromZipCode 
	,dblToLongitude = EML.dblLongitude
	,dblToLatitude = EML.dblLatitude
	,strOrderStatus = LGL.strShipmentStatus
	,strDriver = LGL.strDriver
	,strItemNo = LGLD.strItemNo
	,dblQuantity = LGLD.dblQuantity
	,strCustomerReference = LGLD.strCustomerReference
	,strOrderComments = LGLD.strComments
	,strLocationType = 'Delivery'
	,intDaysPassed = DATEDIFF (day, LGL.dtmScheduledDate, GetDate())
	,strOrderType = 'Inbound'
	,intPriority = -1

FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intPCompanyLocationId
JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = LGLD.intVendorEntityLocationId
WHERE LGL.intPurchaseSale = 1 AND LGL.intShipmentStatus = 1 AND IsNull(LGLD.intLoadDetailId, 0) NOT IN (SELECT IsNull(intLoadDetailId, 0) FROM tblLGRouteOrder)
) t1
