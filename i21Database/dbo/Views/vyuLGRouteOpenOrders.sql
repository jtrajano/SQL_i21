CREATE VIEW vyuLGRouteOpenOrders
AS

SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intSourceType)) as intKeyColumn,*  FROM (
SELECT 
	intSourceType = 2
	,intOrderId = TMO.intDispatchId
	,intEntityId = NULL
	,intEntityLocationId = NULL
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,intSiteID = TMO.intSiteID
	,intCustomerID = TMO.intCustomerId
	,intDispatchID = TMO.intDispatchId
	,intLoadDetailId = NULL
	,intLoadId = NULL
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
	,ysnLeakCheckRequired = TMO.ysnLeakCheckRequired
	,dblPercentLeft = TMO.dblSiteEstimatedPercentLeft
	,dblARBalance = TMO.dblCustomerBalance
	,strFillMethod = TMO.strFillMethod

FROM vyuTMGeneratedCallEntry TMO 
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = TMO.intCompanyLocationId
WHERE TMO.strOrderStatus <> 'Delivered' AND TMO.strOrderStatus <> 'Routed'

UNION ALL

SELECT
	intSourceType = 1
	,intOrderId = LGLD.intLoadDetailId
	,intEntityId = LGLD.intCustomerEntityId
	,intEntityLocationId = LGLD.intCustomerEntityLocationId
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = LGLD.intLoadDetailId
	,intLoadId = LGLD.intLoadId
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
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''

FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intSCompanyLocationId
JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = LGLD.intCustomerEntityLocationId
WHERE LGL.intPurchaseSale = 2 AND LGL.intShipmentStatus = 1 AND IsNull(LGLD.intLoadDetailId, 0) NOT IN (SELECT IsNull(intLoadDetailId, 0) FROM tblLGRouteOrder)

UNION ALL

SELECT
	intSourceType = 3
	,intOrderId = LGLD.intLoadDetailId
	,intEntityId = LGLD.intVendorEntityId
	,intEntityLocationId = LGLD.intVendorEntityLocationId
	,intEntityTypeId = NULL
	,strEntityType = 'Vendor'
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = LGLD.intLoadDetailId
	,intLoadId = LGLD.intLoadId
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
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''

FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intPCompanyLocationId
JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = LGLD.intVendorEntityLocationId
WHERE LGL.intPurchaseSale = 1 AND LGL.intShipmentStatus = 1 AND IsNull(LGLD.intLoadDetailId, 0) NOT IN (SELECT IsNull(intLoadDetailId, 0) FROM tblLGRouteOrder)

UNION ALL

SELECT 
	intSourceType = 4
	,intOrderId = TMO.intSiteId
	,intEntityId = NULL
	,intEntityLocationId = NULL
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,intSiteID = TMO.intSiteId
	,intCustomerID = TMO.intCustomerId
	,intDispatchID = NULL
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = NULL
	,strLocationName = TMO.strCompanyLocationName
	,intLocationId = TMO.intCompanyLocationId
	,strLocationAddress = ''
	,strLocationCity = ''
	,strLocationZipCode = ''
	,strLocationState = ''
	,strLocationCountry = ''
	,dblFromLongitude = 0.0
	,dblFromLatitude = 0.0
	,dtmScheduledDate = NULL
	,strEntityName = TMO.strCustomerName
	,strToAddress = TMO.strSiteAddress
	,strToCity = TMO.strSiteCity
	,strToZipCode = TMO.strSiteZip
	,strToState = TMO.strSiteState
	,strToCountry = ''
	,strDestination = TMO.strSiteAddress + ', ' + TMO.strSiteCity + ', ' + TMO.strSiteState + ' ' + TMO.strSiteZip 
	,dblToLongitude = TMO.dblLongitude
	,dblToLatitude = TMO.dblLatitude
	,strOrderStatus = NULL
	,strDriver = TMO.strDriverName COLLATE Latin1_General_CI_AS
	,strItemNo = NULL
	,dblQuantity = NULL
	,strCustomerReference = ''
	,strOrderComments = ''
	,strLocationType = 'Delivery'
	,intDaysPassed = 0
	,strOrderType = ''
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''

FROM vyuTMCustomerConsumptionSiteInfo TMO WHERE TMO.ysnActive = 1

UNION ALL

SELECT  
	intSourceType = 5
	,intOrderId = EN.intEntityId
	,intEntityId = EN.intEntityId
	,intEntityLocationId = EL.intEntityLocationId
	,intEntityTypeId = ET.intEntityTypeId
	,strEntityType = ET.strType
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = NULL
	,strLocationName = NULL
	,intLocationId = NULL
	,strLocationAddress = NULL
	,strLocationCity = NULL
	,strLocationZipCode = NULL
	,strLocationState = NULL
	,strLocationCountry = NULL
	,dblFromLongitude = NULL
	,dblFromLatitude = NULL
	,dtmScheduledDate = NULL
	,strEntityName = EN.strName
	,strToAddress = EL.strAddress
	,strToCity = EL.strCity
	,strToZipCode = EL.strZipCode
	,strToState = EL.strState
	,strToCountry = EL.strCountry
	,strDestination = EL.strAddress + ', ' + EL.strCity + ', ' + EL.strState + ' ' + EL.strZipCode 
	,dblToLongitude = EL.dblLongitude
	,dblToLatitude = EL.dblLatitude
	,strOrderStatus = NULL
	,strDriver = NULL
	,strItemNo = NULL
	,dblQuantity = NULL
	,strCustomerReference = ''
	,strOrderComments = ''
	,strLocationType = 'Delivery'
	,intDaysPassed = 0
	,strOrderType = ''
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''

FROM tblEMEntityLocation EL
JOIN vyuEMEntity EN ON EN.intEntityId = EL.intEntityId
JOIN tblEMEntityType ET ON ET.intEntityId = EN.intEntityId
WHERE ET.strType = 'Vendor' Or ET.strType = 'Customer' Or ET.strType='Prospect'
) t1
