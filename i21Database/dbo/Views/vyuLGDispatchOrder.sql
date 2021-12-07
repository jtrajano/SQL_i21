CREATE VIEW [dbo].[vyuLGDispatchOrder]
AS
SELECT
	DO.intDispatchOrderId
	,DO.strDispatchOrderNumber
	,DO.dtmDispatchDate
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTruckId
	,DO.intDriverEntityId
	,DO.intDispatchStatus
	,DO.strComments
	,DO.intConcurrencyId
	,strShipVia = SV.strName
	,strDriver = DV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strDispatchStatus = CASE (DO.intDispatchStatus) 
		WHEN 1 THEN 'Scheduled'
		WHEN 2 THEN 'In Progress'
		WHEN 3 THEN 'Complete'
		WHEN 4 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
FROM tblLGDispatchOrder DO
	LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
	LEFT JOIN tblEMEntity DV ON DV.intEntityId = DO.intDriverEntityId
	LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
GO