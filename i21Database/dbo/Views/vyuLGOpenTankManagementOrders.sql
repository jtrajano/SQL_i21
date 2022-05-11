CREATE VIEW [dbo].[vyuLGOpenTankManagementOrders]
AS
SELECT 
	intDispatchId = TMO.intDispatchId	
	,intCompanyLocationId = TMO.intCompanyLocationId
	,intEntityId = E.intEntityId
	,intEntityLocationId = EL.intEntityLocationId
	,intSiteId = TMO.intSiteID
	,strOrderNumber = TMO.strOrderNumber
	,strLocationName = TMO.strCompanyLocationName
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
FROM vyuTMGeneratedCallEntry TMO 
	LEFT JOIN tblTMSite TMS ON TMS.intSiteID = TMO.intSiteID
	LEFT JOIN tblTMRoute TMR ON TMR.intRouteId = TMS.intRouteId
	LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = TMO.intCompanyLocationId
	LEFT JOIN tblEMEntityLocationConsumptionSite ELCS ON ELCS.intSiteID = TMS.intSiteID
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ELCS.intEntityLocationId
	LEFT JOIN tblEMEntity E ON E.intEntityId = EL.intEntityId
	LEFT JOIN tblICItem I ON I.intItemId = TMS.intProduct
	OUTER APPLY (SELECT TOP 1 uom.intItemUOMId, um.intUnitMeasureId, um.strUnitMeasure FROM tblICItemUOM uom
		LEFT JOIN tblICUnitMeasure um on um.intUnitMeasureId = uom.intUnitMeasureId
		WHERE intItemId = I.intItemId AND ysnStockUnit = 1) UOM
WHERE TMO.strOrderStatus <> 'Delivered' AND TMO.strOrderStatus <> 'Routed'

GO