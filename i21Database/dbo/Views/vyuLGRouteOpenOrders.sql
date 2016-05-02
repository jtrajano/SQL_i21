CREATE VIEW vyuLGRouteOpenOrders
AS

SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intSourceType)) as intKeyColumn,*  FROM (
SELECT 
	intSourceType = 1
	,intOrderId = TMO.intDispatchId
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
	,strEntityAddress = TMO.strSiteAddress
	,strEntityCity = TMO.strSiteCity
	,strEntityZipCode = TMO.strSiteZipCode
	,strEntityState = TMO.strSiteState
	,strEntityCountry = TMO.strSiteCountry
	,strDestination = TMO.strSiteAddress + ', ' + TMO.strSiteCity + ', ' + TMO.strSiteState + ' ' + TMO.strSiteZipCode 
	,dblToLongitude = TMO.dblLongitude
	,dblToLatitude = TMO.dblLatitude
	,strOrderStatus = TMO.strOrderStatus
	,strDriver = TMO.strDriverName
	,strItemNo = TMO.strProduct
	,dblQuantity = TMO.dblQuantity
	,strCustomerReference = ''
	,strOrderComments = TMO.strComments

FROM vyuTMGeneratedCallEntry TMO 
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = TMO.intCompanyLocationId

UNION ALL

SELECT
	intSourceType = 2
	,intOrderId = LGLD.intLoadDetailId
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
	,strEntityAddress = LGLD.strShipToAddress
	,strEntityCity = LGLD.strShipToCity
	,strEntityZipCode = LGLD.strShipToZipCode
	,strEntityState = LGLD.strShipToState
	,strEntityCountry = LGLD.strShipToCountry
	,strDestination = LGLD.strShipToAddress + ', ' + LGLD.strShipToCity + ', ' + LGLD.strShipToState + ' ' + LGLD.strShipToZipCode 
	,dblToLongitude = 0.0
	,dblToLatitude = 0.0
	,strOrderStatus = LGL.strShipmentStatus
	,strDriver = LGL.strDriver
	,strItemNo = LGLD.strItemNo
	,dblQuantity = LGLD.dblQuantity
	,strCustomerReference = LGLD.strCustomerReference
	,strOrderComments = LGLD.strComments

FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intSCompanyLocationId
WHERE LGL.intPurchaseSale = 2 AND LGL.intShipmentStatus = 1
) t1
