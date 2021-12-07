CREATE VIEW [dbo].[vyuLGDispatchOrderViewSearch]
AS
SELECT 
	DO.intDispatchOrderId
	,DOD.intDispatchOrderDetailId
	,DO.strDispatchOrderNumber
	,strDispatchStatus = CASE DO.intDispatchStatus
		WHEN 1 THEN 'Scheduled'
		WHEN 2 THEN 'In Progress'
		WHEN 3 THEN 'Complete'
		WHEN 4 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DO.dtmDispatchDate
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTruckId
	,strShipVia = SV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strDriver = DR.strName
	,strFromLocation = CL.strLocationName
	,strFromStorageLocation = CLSL.strSubLocationName 
	,DOD.intSequence
	,DOD.intStopType
	,strStopType = CASE DOD.intStopType 
		WHEN 1 THEN 'Pick Up'
		WHEN 2 THEN 'Delivery'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOD.dtmStartTime
	,DOD.dtmEndTime
	,DOD.intOrderStatus
	,strOrderStatus = CASE DOD.intOrderStatus
		WHEN 1 THEN 'Ready'
		WHEN 2 THEN 'In Transit'
		WHEN 3 THEN CASE WHEN (DOD.intStopType = 1) THEN 'Loaded' ELSE 'Delivered' END
		WHEN 4 THEN 'On-hold'
		WHEN 5 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOD.strOrderNumber
	,DOD.strOrderType
	,strEntityName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (strOrderType IN ('Transfer')) THEN CL.strLocationName ELSE E.strName END
	,strLocationName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (strOrderType IN ('Transfer')) THEN CLSL.strSubLocationName ELSE EL.strLocationName END
	,DOD.strEntityContact
	,DOD.strAddress
	,DOD.strCity
	,DOD.strState
	,DOD.strCountry
	,DOD.strZipCode
	,I.strItemNo
	,strItemDescription = I.strDescription
	,DOD.dblQuantity
	,DOD.strOrderComments
	,DOD.strDeliveryComments
	,DO.intConcurrencyId
FROM 
tblLGDispatchOrder DO
LEFT JOIN tblLGDispatchOrderDetail DOD ON DOD.intDispatchOrderId = DO.intDispatchOrderId
LEFT JOIN tblICItem I ON I.intItemId = DOD.intItemId
LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
LEFT JOIN tblEMEntity DR ON DR.intEntityId = DO.intDriverEntityId
LEFT JOIN tblEMEntity E ON E.intEntityId = DOD.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DOD.intEntityLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DOD.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DOD.intCompanyLocationSubLocationId
