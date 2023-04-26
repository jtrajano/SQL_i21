CREATE VIEW [dbo].[vyuLGOpenTankManagementOrders]
AS
SELECT 
	intDispatchId = TMO.intDispatchId	
	,intCompanyLocationId = TMO.intCompanyLocationId
	,intSubLocationId = IL.intSubLocationId
	,intEntityId = E.intEntityId
	,intEntityLocationId = EL.intEntityLocationId
	,intSiteId = TMO.intSiteID
	,intDeviceId = SD.intDeviceId
	,strSerialNumber = SD.strSerialNumber
	,strOrderNumber = TMO.strOrderNumber
	,strLocationName = TMO.strCompanyLocationName
	,strSubLocationName = CLSL.strSubLocationName
	,strEntityNo = E.strEntityNo
	,strEntityName = TMO.strCustomerName
	,strEntityLocation = EL.strLocationName
	,strSiteNumber = TMO.strSiteNumber
	,strToAddress = TMO.strSiteAddress
	,strToCity = TMO.strSiteCity
	,strToZipCode = TMO.strSiteZipCode
	,strToState = TMO.strSiteState
	,strToCountry = TMO.strSiteCountry
	,intItemId = I.intItemId
	,intCommodityId = I.intCommodityId
	,intCategoryId = I.intCategoryId
	,strItemNo = I.strItemNo
	,strDescription = TMO.strProduct
	,dblQuantity = TMO.dblQuantity
	,intItemUOMId = UOM.intItemUOMId
	,intUnitMeasureId = UOM.intUnitMeasureId
	,strUnitMeasure = UOM.strUnitMeasure
	,strOrderStatus = TMO.strOrderStatus
	,dtmScheduledDate = TMO.dtmRequestedDate
	,dtmHoursFrom = EL.dtmOperatingHoursStartTime
	,dtmHoursTo = EL.dtmOperatingHoursEndTime
	,strDriver = TMO.strDriverName
	,strOrderComments = TMO.strComments
	,intDaysPassed = DATEDIFF (day, TMO.dtmRequestedDate, GetDate())
	,intPriority = TMO.intPriority
	,ysnLeakCheckRequired = TMO.ysnLeakCheckRequired
	,dblPercentLeft = TMO.dblPercentLeft
	,dblARBalance = TMO.dblCustomerBalance
	,strFillMethod = TMO.strFillMethod
	,ysnHold = TMO.ysnHold
	,ysnRoutingAlert = TMO.ysnRoutingAlert
	,strRoute = TMR.strRouteId
	,TMO.intConcurrencyId
	,TMS.strRecurringPONumber
FROM vyuTMGeneratedCallEntry TMO 
	LEFT JOIN tblTMSite TMS ON TMS.intSiteID = TMO.intSiteID
	OUTER APPLY (SELECT TOP 1 sd.intDeviceId, d.strSerialNumber FROM tblTMSiteDevice sd 
		INNER JOIN tblTMDevice d ON d.intDeviceId = sd.intDeviceId WHERE sd.intSiteID = TMS.intSiteID) SD
	LEFT JOIN tblTMRoute TMR ON TMR.intRouteId = TMS.intRouteId
	LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = TMO.intCompanyLocationId
	LEFT JOIN tblEMEntityLocationConsumptionSite ELCS ON ELCS.intSiteID = TMS.intSiteID
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ELCS.intEntityLocationId
	LEFT JOIN tblTMCustomer TMC ON TMC.intCustomerID = TMS.intCustomerID
	LEFT JOIN tblEMEntity E ON E.intEntityId = TMC.intCustomerNumber
	LEFT JOIN tblICItem I ON I.intItemId = TMS.intProduct
	LEFT JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId AND IL.intLocationId IS NOT NULL AND IL.intLocationId = TMS.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = IL.intSubLocationId
	OUTER APPLY (SELECT TOP 1 uom.intItemUOMId, um.intUnitMeasureId, um.strUnitMeasure FROM tblICItemUOM uom
		LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId = uom.intUnitMeasureId
		WHERE intItemId = I.intItemId AND ysnStockUnit = 1) UOM
WHERE TMO.strOrderStatus <> 'Delivered' AND TMO.strOrderStatus <> 'Routed'
	AND TMO.dblQuantity > 0
	AND intDispatchId NOT IN (SELECT intTMDispatchId FROM tblLGLoadDetail WHERE intTMDispatchId IS NOT NULL)

GO