CREATE VIEW vyuLGRouteOpenOrders
AS

SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intSourceType)) as intKeyColumn,*  FROM (
SELECT 
	intSourceType = 1
	,intOrderId = TMO.intDispatchId
	,strOrderNumber = TMO.strOrderNumber
	,strLocationName = TMO.strLocation
	,intLocationId = TMO.intLocationId
	,strLocationAddress = CompLoc.strAddress
	,strLocationCity = CompLoc.strCity
	,strLocationZipCode = CompLoc.strZipPostalCode
	,strLocationState = CompLoc.strStateProvince
	,strLocationCountry = CompLoc.strCountry
	,dblFromLongitude = 0.0
	,dblFromLatitude = 0.0
	,dtmScheduledDate = TMO.dtmRequestedDate
	,strEntityName = TMO.strCustomerName
	,strEntityAddress = Site.strSiteAddress
	,strEntityCity = Site.strCity
	,strEntityZipCode = Site.strZipCode
	,strEntityState = Site.strState
	,strEntityCountry = Site.strCountry
	,strDestination = Site.strSiteAddress + ', ' + Site.strCity + ', ' + Site.strState + ' ' + Site.strZipCode 
	,dblToLongitude = Site.dblLongitude
	,dblToLatitude = Site.dblLatitude
	,strOrderStatus = TMO.strOrderStatus
	,strDriver = TMO.strDriverName
	,strItemNo = TMO.strProduct
	,dblQuantity = TMO.dblQuantity
	,strCustomerReference = ''
	,strOrderComments = TMO.strComments

FROM vyuTMOpenCallEntry TMO 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.strLocationNumber = TMO.strLocation
JOIN tblTMSite Site ON Site.intSiteID = TMO.intSiteID
WHERE TMO.strOrderStatus = 'Generated' AND TMO.strOrderNumber IS NOT NULL

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
	,dblFromLongitude = 0.0
	,dblFromLatitude = 0.0
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
WHERE LGL.intPurchaseSale = 2 AND LGL.intShipmentStatus = 1
) t1
