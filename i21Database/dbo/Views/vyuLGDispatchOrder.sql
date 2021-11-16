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
	,strTruckNumber = SVT.strTruckNumber
	,strLocation = CL.strLocationName
	,strSubLocation = CLSL.strSubLocationName
FROM tblLGDispatchOrder DO
	LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
	LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DO.intFromCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DO.intFromCompanyLocationSubLocationId
GO