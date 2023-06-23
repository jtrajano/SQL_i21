CREATE VIEW [dbo].[vyuLGDispatchScheduleViewSearch]
AS
SELECT
	DOR.intDispatchOrderId
	,DOR.intDispatchOrderRouteId
	,DOD.intDispatchOrderDetailId
	,DOR.intDriverEntityId
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTrailerId
	,DOR.intEntityShipViaTruckId
	,DOD.intEntityId
	,DOD.intEntityLocationId
	,intSiteId = DOD.intTMSiteId
	,intTMCustomerId = TMC.intCustomerID
	,strDispatchOrderNumber = DO.strDispatchOrderNumber
	,DO.intDispatchStatus
	,strDispatchStatus = CASE (DO.intDispatchStatus) 
		WHEN 0 THEN 'Created'
		WHEN 1 THEN 'Routed'
		WHEN 2 THEN 'Scheduled'
		WHEN 3 THEN 'Dispatched'
		WHEN 4 THEN 'Complete'
		WHEN 5 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DO.dtmDispatchDate
	,strShipVia = SV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strDriver = DV.strName
	,strTrailerNumber = SVTL.strTrailerNumber
	,ysnDispatched = CONVERT(BIT, CASE WHEN DO.intDispatchStatus > 2 THEN 1 ELSE 0 END)

	,DOR.intStopType
	,strStopType = CASE DOR.intStopType 
		WHEN 1 THEN 'Pick Up'
		WHEN 2 THEN 'Delivery'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOR.intOrderStatus
	,strOrderStatus = CASE DOR.intOrderStatus
		WHEN 1 THEN 'Ready'
		WHEN 2 THEN 'In Transit'
		WHEN 3 THEN 'At Location'
		WHEN 4 THEN CASE WHEN (DOR.intStopType = 1) THEN 'Loaded' ELSE 'Delivered' END
		WHEN 5 THEN 'On-hold'
		WHEN 6 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOR.intRouteSeq
	,DOR.dtmStartTime
	,DOR.dtmEndTime
	
	,DOR.strEntityName
	,DOR.strEntityLocation
	,DOR.strSiteNumber
	,DOR.strAddress
	,DOR.strCity
	,DOR.strState
	,DOR.strZipCode
	,DOR.strCountry
	,strOrderNumber = CASE WHEN (DOR.intStopType = 1) THEN DO.strDispatchOrderNumber ELSE DOR.strOrderNumber END
	,DOR.strItemNo
	,DOR.dblQuantity
	,DOR.dblStandardWeight
FROM tblLGDispatchOrderRoute DOR 
LEFT JOIN tblLGDispatchOrderDetail DOD ON DOD.intDispatchOrderDetailId = DOR.intDispatchOrderDetailId
LEFT JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = DOR.intDispatchOrderId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = DO.intEntityShipViaId
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DOR.intEntityShipViaTruckId
LEFT JOIN tblSMShipViaTrailer SVTL ON SVTL.intEntityShipViaTrailerId = DO.intEntityShipViaTrailerId
LEFT JOIN tblEMEntity DV ON DV.intEntityId = DOR.intDriverEntityId
LEFT JOIN tblTMSite TMS ON TMS.intSiteID = DOD.intTMSiteId
LEFT JOIN tblTMCustomer TMC ON TMC.intCustomerID = TMS.intCustomerID

GO