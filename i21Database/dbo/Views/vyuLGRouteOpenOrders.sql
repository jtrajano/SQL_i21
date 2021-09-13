CREATE VIEW vyuLGRouteOpenOrders
AS

SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intSourceType, dtmScheduledDate DESC)) as intKeyColumn,*  FROM (
SELECT 
	intSourceType = 2 /* TM Orders */
	,intOrderId = TMO.intDispatchId
	,intOrderDetailId = NULL
	,intEntityId = NULL
	,intEntityLocationId = NULL
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,strCustomerNumber = NULL
	,intSiteID = TMO.intSiteID
	,intCustomerID = TMO.intCustomerId
	,intDispatchID = TMO.intDispatchId
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = TMO.strOrderNumber
	,strLocationName = TMO.strCompanyLocationName
	,intLocationId = TMO.intCompanyLocationId
	,strFromWarehouse = NULL
	,strLocationAddress = CompLoc.strAddress
	,strLocationCity = CompLoc.strCity
	,strLocationZipCode = CompLoc.strZipPostalCode
	,strLocationState = CompLoc.strStateProvince
	,strLocationCountry = CompLoc.strCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = TMO.dtmRequestedDate
	,dtmHoursFrom = CAST(NULL AS DATETIME)
	,dtmHoursTo = CAST(NULL AS DATETIME)
	,strEntityName = TMO.strCustomerName
	,strToWarehouse = NULL
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
	,dblOnHand = NULL
	,dblOrderedQty = NULL
	,dblQuantity = TMO.dblQuantity
	,dblStandardWeight = NULL
	,strCustomerReference = ''
	,strOrderComments = TMO.strComments
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = DATEDIFF (day, TMO.dtmRequestedDate, GetDate())
	,strOrderType = 'Outbound' COLLATE Latin1_General_CI_AS
	,intPriority = TMO.intPriority
	,ysnLeakCheckRequired = TMO.ysnLeakCheckRequired
	,dblPercentLeft = TMO.dblPercentLeft
	,dblARBalance = TMO.dblCustomerBalance
	,strFillMethod = TMO.strFillMethod
	,ysnHold = TMO.ysnHold
	,ysnRoutingAlert = TMO.ysnRoutingAlert
	,strRoute = TMR.strRouteId
FROM vyuTMGeneratedCallEntry TMO 
LEFT JOIN tblTMSite TMS ON TMS.intSiteID = TMO.intSiteID
LEFT JOIN tblTMRoute TMR ON TMR.intRouteId = TMS.intRouteId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = TMO.intCompanyLocationId
WHERE TMO.strOrderStatus <> 'Delivered' AND TMO.strOrderStatus <> 'Routed'

UNION ALL

SELECT
	intSourceType = 1  /* LG Loads - Outbound */
	,intOrderId = LGLD.intLoadDetailId
	,intOrderDetailId = NULL
	,intEntityId = LGLD.intCustomerEntityId
	,intEntityLocationId = LGLD.intCustomerEntityLocationId
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,strCustomerNumber = NULL
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = LGLD.intLoadDetailId
	,intLoadId = LGLD.intLoadId
	,intSequence = -1
	,strOrderNumber = LGLD.strLoadNumber
	,strLocationName = LGLD.strSLocationName
	,intLocationId = LGLD.intSCompanyLocationId
	,strFromWarehouse = LGLD.strSSubLocationName
	,strLocationAddress = LGLD.strSLocationAddress
	,strLocationCity = LGLD.strSLocationCity
	,strLocationZipCode = LGLD.strSLocationZipCode
	,strLocationState = LGLD.strSLocationState
	,strLocationCountry = LGLD.strSLocationCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = LGL.dtmScheduledDate
	,dtmHoursFrom = EML.dtmOperatingHoursStartTime
	,dtmHoursTo = EML.dtmOperatingHoursEndTime
	,strEntityName = LGLD.strCustomer
	,strToWarehouse = LGLD.strPSubLocationName
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
	,dblOnHand = OH.dblUnitOnHand
	,dblOrderedQty = NULL
	,dblQuantity = LGLD.dblQuantity
	,dblStandardWeight = 0.0
	,strCustomerReference = LGLD.strCustomerReference
	,strOrderComments = LGLD.strComments
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = DATEDIFF (day, LGL.dtmScheduledDate, GetDate())
	,strOrderType = 'Outbound' COLLATE Latin1_General_CI_AS
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''
	,ysnHold = Cast(0 as Bit)
	,ysnRoutingAlert = Cast(0 as Bit)
	,strRoute = EML.strLocationRoute
FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intSCompanyLocationId
JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = LGLD.intCustomerEntityLocationId
LEFT JOIN vyuICGetItemStock OH ON OH.intItemId = LGLD.intItemId AND OH.intLocationId = LGLD.intSCompanyLocationId
WHERE LGL.intPurchaseSale = 2 AND LGL.intShipmentStatus = 1 AND IsNull(LGLD.intLoadDetailId, 0) NOT IN (SELECT IsNull(intLoadDetailId, 0) FROM tblLGRouteOrder)

UNION ALL

SELECT
	intSourceType = 3  /* LG Loads - Inbound */
	,intOrderId = LGLD.intLoadDetailId
	,intOrderDetailId = NULL
	,intEntityId = LGLD.intVendorEntityId
	,intEntityLocationId = LGLD.intVendorEntityLocationId
	,intEntityTypeId = NULL
	,strEntityType = 'Vendor'
	,strCustomerNumber = NULL
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = LGLD.intLoadDetailId
	,intLoadId = LGLD.intLoadId
	,intSequence = -1
	,strOrderNumber = LGLD.strLoadNumber
	,strLocationName = LGLD.strPLocationName
	,intLocationId = LGLD.intPCompanyLocationId
	,strFromWarehouse = LGLD.strSSubLocationName
	,strLocationAddress = LGLD.strPLocationAddress
	,strLocationCity = LGLD.strPLocationCity
	,strLocationZipCode = LGLD.strPLocationZipCode
	,strLocationState = LGLD.strPLocationState
	,strLocationCountry = LGLD.strPLocationCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = LGL.dtmScheduledDate
	,dtmHoursFrom = EML.dtmOperatingHoursStartTime
	,dtmHoursTo = EML.dtmOperatingHoursEndTime
	,strEntityName = LGLD.strVendor
	,strToWarehouse = LGLD.strPSubLocationName
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
	,dblOnHand = OH.dblUnitOnHand
	,dblOrderedQty = NULL
	,dblQuantity = LGLD.dblQuantity
	,dblStandardWeight = 0.0
	,strCustomerReference = LGLD.strCustomerReference
	,strOrderComments = LGLD.strComments
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = DATEDIFF (day, LGL.dtmScheduledDate, GetDate())
	,strOrderType = 'Inbound' COLLATE Latin1_General_CI_AS
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''
	,ysnHold = Cast(0 as Bit)
	,ysnRoutingAlert = Cast(0 as Bit)
	,strRoute = EML.strLocationRoute
FROM vyuLGLoadDetailView LGLD
JOIN vyuLGLoadView LGL ON LGL.intLoadId = LGLD.intLoadId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = LGLD.intPCompanyLocationId
JOIN tblEMEntityLocation EML ON EML.intEntityLocationId = LGLD.intVendorEntityLocationId
LEFT JOIN vyuICGetItemStock OH ON OH.intItemId = LGLD.intItemId AND OH.intLocationId = LGLD.intPCompanyLocationId
WHERE LGL.intPurchaseSale = 1 AND LGL.intShipmentStatus = 1 AND IsNull(LGLD.intLoadDetailId, 0) NOT IN (SELECT IsNull(intLoadDetailId, 0) FROM tblLGRouteOrder)

UNION ALL

SELECT 
	intSourceType = 4  /* TM Sites */
	,intOrderId = TMO.intSiteId
	,intOrderDetailId = NULL
	,intEntityId = NULL
	,intEntityLocationId = NULL
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,strCustomerNumber
	,intSiteID = TMO.intSiteId
	,intCustomerID = TMO.intCustomerId
	,intDispatchID = NULL
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = NULL
	,strLocationName = TMO.strCompanyLocationName
	,intLocationId = TMO.intCompanyLocationId
	,strFromWarehouse = NULL
	,strLocationAddress = ''
	,strLocationCity = ''
	,strLocationZipCode = ''
	,strLocationState = ''
	,strLocationCountry = ''
	,dblFromLongitude = 0.0
	,dblFromLatitude = 0.0
	,dtmScheduledDate = NULL
	,dtmHoursFrom = CAST(NULL AS DATETIME)
	,dtmHoursTo = CAST(NULL AS DATETIME)
	,strEntityName = TMO.strCustomerName
	,strToWarehouse = NULL
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
	,dblOnHand = NULL
	,dblOrderedQty = NULL
	,dblQuantity = NULL
	,dblStandardWeight = NULL
	,strCustomerReference = ''
	,strOrderComments = ''
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = 0
	,strOrderType = '' COLLATE Latin1_General_CI_AS
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''
	,ysnHold = Cast(0 as Bit)
	,ysnRoutingAlert = Cast(0 as Bit)
	,strRoute = TMO.strRoute
FROM vyuTMCustomerConsumptionSiteInfo TMO WHERE TMO.ysnActive = 1

UNION ALL

SELECT  
	intSourceType = 5  /* Entities */
	,intOrderId = EN.intEntityId
	,intOrderDetailId = NULL
	,intEntityId = EN.intEntityId
	,intEntityLocationId = EL.intEntityLocationId
	,intEntityTypeId = ET.intEntityTypeId
	,strEntityType = ET.strType
	,strCustomerNumber = NULL
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = NULL
	,strLocationName = NULL
	,intLocationId = NULL
	,strFromWarehouse = NULL
	,strLocationAddress = NULL
	,strLocationCity = NULL
	,strLocationZipCode = NULL
	,strLocationState = NULL
	,strLocationCountry = NULL
	,dblFromLongitude = NULL
	,dblFromLatitude = NULL
	,dtmScheduledDate = NULL
	,dtmHoursFrom = EL.dtmOperatingHoursStartTime
	,dtmHoursTo = EL.dtmOperatingHoursEndTime
	,strEntityName = EN.strName
	,strToWarehouse = NULL
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
	,dblOnHand = NULL
	,dblOrderedQty = NULL
	,dblQuantity = NULL
	,dblStandardWeight = NULL
	,strCustomerReference = ''
	,strOrderComments = ''
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = 0
	,strOrderType = '' COLLATE Latin1_General_CI_AS
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''
	,ysnHold = Cast(0 as Bit)
	,ysnRoutingAlert = Cast(0 as Bit)
	,strRoute = EL.strLocationRoute
FROM tblEMEntityLocation EL
JOIN vyuEMEntity EN ON EN.intEntityId = EL.intEntityId
JOIN tblEMEntityType ET ON ET.intEntityId = EN.intEntityId
WHERE ET.strType = 'Vendor' Or ET.strType = 'Customer' Or ET.strType='Prospect'

UNION ALL

SELECT
	intSourceType = 6 /* Sales Orders */
	,intOrderId = SO.intSalesOrderId
	,intOrderDetailId = SOD.intSalesOrderDetailId
	,intEntityId = SO.intEntityId
	,intEntityLocationId = SO.intShipToLocationId
	,intEntityTypeId = NULL
	,strEntityType = 'Customer'
	,strCustomerNumber = NULL
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = SO.strSalesOrderNumber
	,strLocationName = CompLoc.strLocationName
	,intLocationId = CompLoc.intCompanyLocationId
	,strFromWarehouse = FromStrg.strSubLocationName
	,strLocationAddress = CompLoc.strAddress
	,strLocationCity = CompLoc.strCity
	,strLocationZipCode = CompLoc.strZipPostalCode
	,strLocationState = CompLoc.strStateProvince
	,strLocationCountry = CompLoc.strCountry
	,dblFromLongitude = CompLoc.dblLongitude
	,dblFromLatitude = CompLoc.dblLatitude
	,dtmScheduledDate = SO.dtmDate
	,dtmHoursFrom = EL.dtmOperatingHoursStartTime
	,dtmHoursTo = EL.dtmOperatingHoursEndTime
	,strEntityName = E.strName
	,strToWarehouse = ToStrg.strSubLocationName
	,strToAddress = EL.strAddress
	,strToCity = EL.strCity
	,strToZipCode = EL.strZipCode
	,strToState = EL.strState
	,strToCountry = EL.strCountry
	,strDestination = EL.strAddress + ', ' + EL.strCity + ', ' + EL.strState + ' ' + EL.strZipCode 
	,dblToLongitude = EL.dblLongitude
	,dblToLatitude = EL.dblLatitude
	,strOrderStatus = SO.strOrderStatus
	,strDriver = NULL
	,strItemNo = I.strItemNo
	,dblOnHand = OH.dblUnitOnHand
	,dblOrderedQty = SOD.dblQtyOrdered
	,dblQuantity = SOD.dblQtyOrdered
	,dblStandardWeight = ROUND(SOD.dblQtyOrdered * SOD.dblStandardWeight, 2)
	,strCustomerReference = SO.strPONumber
	,strOrderComments = SOD.strComments
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = DATEDIFF (DAY, SO.dtmDate, GetDate())
	,strOrderType = 'Sales' COLLATE Latin1_General_CI_AS
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = ISNULL(CB.dbl30Days,0.0) + ISNULL(CB.dbl60Days,0.0) + ISNULL(CB.dbl90Days,0.0) + ISNULL(CB.dbl91Days,0.0)
	,strFillMethod = ''
	,ysnHold = Cast(0 as Bit)
	,ysnRoutingAlert = Cast(0 as Bit)
	,strRoute = EL.strLocationRoute
FROM tblSOSalesOrderDetail SOD
JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SOD.intSalesOrderId 
JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = SO.intCompanyLocationId
JOIN tblEMEntity E ON E.intEntityId = SO.intEntityCustomerId
JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND SO.intShipToLocationId = EL.intEntityLocationId
JOIN tblICItem I ON I.intItemId = SOD.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation FromStrg ON FromStrg.intCompanyLocationSubLocationId = SOD.intSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation ToStrg ON ToStrg.intCompanyLocationSubLocationId = SOD.intCustomerStorageId
LEFT JOIN vyuARCustomerInquiryReport CB ON CB.intEntityCustomerId = E.intEntityId
LEFT JOIN vyuICGetItemStock OH ON OH.intItemId = I.intItemId AND OH.intLocationId = CompLoc.intCompanyLocationId
WHERE SO.strTransactionType = 'Order' AND SO.strOrderStatus NOT IN ('Closed')
AND NOT EXISTS (SELECT 1 FROM tblLGRouteOrder RO INNER JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
				WHERE R.intSourceType = 6 AND R.ysnPosted = 1 AND RO.intSalesOrderDetailId = SOD.intSalesOrderDetailId)

UNION ALL

SELECT
	intSourceType = 6  /* Transfer Orders */
	,intOrderId = IT.intInventoryTransferId 
	,intOrderDetailId = ITD.intInventoryTransferDetailId
	,intEntityId = E.intEntityId
	,intEntityLocationId = NULL
	,intEntityTypeId = NULL
	,strEntityType = 'User'
	,strCustomerNumber = NULL
	,intSiteID = NULL
	,intCustomerID = NULL
	,intDispatchID = NULL
	,intLoadDetailId = NULL
	,intLoadId = NULL
	,intSequence = -1
	,strOrderNumber = IT.strTransferNo
	,strLocationName = FromLoc.strLocationName
	,intLocationId = FromLoc.intCompanyLocationId
	,strFromWarehouse = FromStrg.strSubLocationName
	,strLocationAddress = CASE WHEN ITD.intFromSubLocationId IS NOT NULL AND ISNULL(FromStrg.strAddress, '') <> '' THEN FromStrg.strAddress ELSE FromLoc.strAddress END
	,strLocationCity = CASE WHEN ITD.intFromSubLocationId IS NOT NULL AND ISNULL(FromStrg.strAddress, '') <> '' THEN FromStrg.strCity ELSE FromLoc.strCity END
	,strLocationZipCode = CASE WHEN ITD.intFromSubLocationId IS NOT NULL AND ISNULL(FromStrg.strAddress, '') <> '' THEN FromStrg.strZipCode ELSE FromLoc.strZipPostalCode END
	,strLocationState = CASE WHEN ITD.intFromSubLocationId IS NOT NULL AND ISNULL(FromStrg.strAddress, '') <> '' THEN FromStrg.strState ELSE FromLoc.strStateProvince END
	,strLocationCountry = FromLoc.strCountry
	,dblFromLongitude = CASE WHEN ITD.intFromSubLocationId IS NOT NULL AND ISNULL(FromStrg.strAddress, '') <> '' THEN FromStrg.dblLongitude ELSE FromLoc.dblLongitude END
	,dblFromLatitude = CASE WHEN ITD.intFromSubLocationId IS NOT NULL AND ISNULL(FromStrg.strAddress, '') <> '' THEN FromStrg.dblLatitude ELSE FromLoc.dblLatitude END
	,dtmScheduledDate = IT.dtmTransferDate
	,dtmHoursFrom = CAST(NULL AS DATETIME)
	,dtmHoursTo = CAST(NULL AS DATETIME)
	,strEntityName = E.strName
	,strToWarehouse = ToStrg.strSubLocationName
	,strToAddress = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' THEN ToStrg.strAddress ELSE ToLoc.strAddress END
	,strToCity = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' THEN ToStrg.strCity ELSE ToLoc.strCity END
	,strToZipCode = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' THEN ToStrg.strZipCode ELSE ToLoc.strZipPostalCode END
	,strToState = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' THEN ToStrg.strState ELSE ToLoc.strStateProvince END
	,strToCountry = ToLoc.strCountry
	,strDestination = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' 
		THEN ToStrg.strAddress + ', ' + ToStrg.strCity + ', ' + ToStrg.strState + ' ' + ToStrg.strZipCode
		ELSE ToLoc.strAddress + ', ' + ToLoc.strCity + ', ' + ToLoc.strStateProvince + ' ' + ToLoc.strZipPostalCode END
	,dblToLongitude = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' THEN ToStrg.dblLongitude ELSE ToLoc.dblLongitude END
	,dblToLatitude = CASE WHEN ITD.intToSubLocationId IS NOT NULL AND ISNULL(ToStrg.strAddress, '') <> '' THEN ToStrg.dblLatitude ELSE ToLoc.dblLatitude END
	,strOrderStatus = ITS.strStatus
	,strDriver = NULL
	,strItemNo = I.strItemNo
	,dblOnHand = OH.dblUnitOnHand
	,dblOrderedQty = 0.0
	,dblQuantity = ITD.dblQuantity
	,dblStandardWeight = ROUND(ITD.dblQuantity * ITD.dblStandardWeight, 2)
	,strCustomerReference = NULL
	,strOrderComments = ITD.strComment
	,strLocationType = 'Delivery' COLLATE Latin1_General_CI_AS
	,intDaysPassed = DATEDIFF (DAY, IT.dtmTransferDate, GetDate())
	,strOrderType = 'Transfer' COLLATE Latin1_General_CI_AS
	,intPriority = -1
	,ysnLeakCheckRequired = Cast(0 as Bit)
	,dblPercentLeft = 0.0
	,dblARBalance = 0.0
	,strFillMethod = ''
	,ysnHold = Cast(0 as Bit)
	,ysnRoutingAlert = Cast(0 as Bit)
	,strRoute = CAST(NULL AS NVARCHAR(500))
FROM tblICInventoryTransferDetail ITD
JOIN tblICInventoryTransfer IT ON IT.intInventoryTransferId = ITD.intInventoryTransferId 
JOIN tblSMCompanyLocation FromLoc ON FromLoc.intCompanyLocationId = IT.intFromLocationId
JOIN tblSMCompanyLocation ToLoc ON ToLoc.intCompanyLocationId = IT.intToLocationId
JOIN tblEMEntity E ON E.intEntityId = IT.intEntityId
JOIN tblICItem I ON I.intItemId = ITD.intItemId
LEFT JOIN tblICStatus ITS ON ITS.intStatusId = IT.intStatusId
LEFT JOIN tblSMCompanyLocationSubLocation FromStrg ON FromStrg.intCompanyLocationSubLocationId = ITD.intFromSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation ToStrg ON ToStrg.intCompanyLocationSubLocationId = ITD.intToSubLocationId
LEFT JOIN vyuICGetItemStock OH ON OH.intItemId = I.intItemId AND OH.intLocationId = FromLoc.intCompanyLocationId
WHERE IT.intStatusId IN (1, 2)
AND NOT EXISTS (SELECT 1 FROM tblLGRouteOrder RO INNER JOIN tblLGRoute R ON R.intRouteId = RO.intRouteId
				WHERE R.intSourceType = 6 AND R.ysnPosted = 1 AND RO.intInventoryTransferDetailId = ITD.intInventoryTransferDetailId)

) t1
