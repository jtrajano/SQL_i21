CREATE VIEW [dbo].[vyuLGDispatchOrderViewSearch]
AS
SELECT 
	DO.intDispatchOrderId
	,DO.strDispatchOrderNumber
	,strDeliveryStatus = CASE DO.intDeliveryStatus 
		WHEN 1 THEN 'Ready'
		WHEN 2 THEN 'In Transit'
		WHEN 3 THEN 'Delivered'
		WHEN 4 THEN 'On-hold'
		WHEN 5 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DO.dtmDispatchDate
	,DO.dtmDeliveryTimeStart
	,DO.dtmDeliveryTimeEnd
	,strShipVia = SV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strDriver = DR.strName
	,strFromLocation = CL.strLocationName
	,strFromStorageLocation = CLSL.strSubLocationName 
	,DOD.intSequence
	,DOD.strOrderNumber
	,DOD.strOrderType
	,DOD.strEntityName
	,DOD.strEntityContact
	,DOD.strLocationName
	,DOD.strAddress
	,DOD.strCity
	,DOD.strState
	,DOD.strCountry
	,DOD.strZipCode
	,DOD.strItemNo
	,DOD.strItemDescription
	,DOD.dblQuantity
	,DOD.strOrderComments
	,DOD.strDeliveryComments
	,DO.intConcurrencyId
FROM 
tblLGDispatchOrder DO
LEFT JOIN tblLGDispatchOrderDetail DOD ON DOD.intDispatchOrderId = DO.intDispatchOrderId
LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
LEFT JOIN tblEMEntity DR ON DR.intEntityId = DO.intDriverEntityId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DO.intFromCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DO.intFromCompanyLocationSubLocationId
