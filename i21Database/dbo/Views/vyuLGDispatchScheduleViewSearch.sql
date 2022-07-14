﻿CREATE VIEW [dbo].[vyuLGDispatchScheduleViewSearch]
AS
SELECT
	DOR.intDispatchOrderId
	,DOR.intDispatchOrderRouteId
	,DOD.intDispatchOrderDetailId
	,DO.intDriverEntityId
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTrailerId
	,DO.intEntityShipViaTruckId
	,DOD.intEntityId
	,DOD.intEntityLocationId
	,intSiteId = DOD.intTMSiteId
	
	,strDispatchOrderNumber = DO.strDispatchOrderNumber
	,DO.dtmDispatchDate
	,strShipVia = SV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strDriver = DV.strName
	,strTrailerNumber = SVTL.strTrailerNumber

	,DOR.intStopType
	,strStopType = CASE DOR.intStopType 
		WHEN 1 THEN 'Pick Up'
		WHEN 2 THEN 'Delivery'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOR.intOrderStatus
	,strOrderStatus = CASE DOD.intOrderStatus
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
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
LEFT JOIN tblSMShipViaTrailer SVTL ON SVTL.intEntityShipViaTrailerId = DO.intEntityShipViaTrailerId
LEFT JOIN tblEMEntity DV ON DV.intEntityId = DO.intDriverEntityId

GO