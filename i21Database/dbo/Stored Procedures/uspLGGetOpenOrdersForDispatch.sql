CREATE PROCEDURE [dbo].[uspLGGetOpenOrdersForDispatch]
	@intSourceType INT
AS

IF (@intSourceType = 2)
BEGIN
	SELECT 
		intOrderId = TMO.intDispatchId
		,intSourceType = 2 /* TM Orders */
		,intOrderDetailId = NULL
		,intEntityId = E.intEntityId
		,intEntityLocationId = EL.intEntityLocationId
		,intEntityTypeId = NULL
		,strEntityType = 'Customer'
		,strCustomerNumber = E.strEntityNo
		,intSiteID = TMO.intSiteID
		,strSiteNumber = TMO.strSiteNumber
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
		,dtmHoursFrom = EL.dtmOperatingHoursStartTime
		,dtmHoursTo = EL.dtmOperatingHoursEndTime
		,strEntityName = TMO.strCustomerName
		,strEntityLocation = EL.strLocationName
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
		,intItemId = TMS.intProduct
		,strItemNo = TMO.strProduct
		,intCategoryId = I.intCategoryId
		,dblOnHand = NULL
		,dblOrderedQty = NULL
		,dblQuantity = TMO.dblQuantity
		,dblStandardWeight = TMO.dblQuantity * ISNULL(SW.dblStandardWeight, 0)
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
		LEFT JOIN tblEMEntityLocationConsumptionSite ELCS ON ELCS.intSiteID = TMS.intSiteID
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ELCS.intEntityLocationId
		LEFT JOIN tblTMCustomer TMC ON TMC.intCustomerID = TMS.intCustomerID
		LEFT JOIN tblEMEntity E ON E.intEntityId = TMC.intCustomerNumber
		LEFT JOIN tblICItem I ON I.intItemId = TMS.intProduct
		OUTER APPLY (SELECT TOP 1 dblStandardWeight FROM tblICItemUOM WHERE intItemId = TMS.intProduct AND ysnStockUnit = 1) SW
	WHERE TMO.strOrderStatus = 'Generated'
		AND NOT EXISTS (SELECT 1 FROM tblLGDispatchOrderDetail DOD 
			INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = DOD.intDispatchOrderId 
			WHERE DO.intSourceType = 2 AND DOD.intTMDispatchId = TMO.intDispatchId AND DO.intDispatchStatus NOT IN (6))
END
GO