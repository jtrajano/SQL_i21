CREATE VIEW [dbo].[vyuLGDispatchOrder]
AS
SELECT
	DO.intDispatchOrderId
	,DO.strDispatchOrderNumber
	,DO.dtmDispatchDate
	,DO.dtmDeliveryTimeStart
	,DO.dtmDeliveryTimeEnd
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTruckId
	,DO.intDriverEntityId
	,DO.intDeliveryStatus
	,DO.intFromCompanyLocationId
	,DO.intFromCompanyLocationSubLocationId
	,DO.strComments
	,DO.intConcurrencyId
	,strShipVia = SV.strName
	,strDriver = DV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strLocation = CL.strLocationName
	,strSubLocation = CLSL.strSubLocationName
	,strDeliveryStatus = CASE (DO.intDeliveryStatus) 
		WHEN 1 THEN 'Ready'
		WHEN 2 THEN 'In Transit'
		WHEN 3 THEN 'Delivered'
		WHEN 4 THEN 'On-hold'
		WHEN 5 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
FROM tblLGDispatchOrder DO
	LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
	LEFT JOIN tblEMEntity DV ON DV.intEntityId = DO.intDriverEntityId
	LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DO.intFromCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DO.intFromCompanyLocationSubLocationId
GO