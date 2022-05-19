CREATE VIEW [dbo].[vyuLGDispatchOrder]
AS
SELECT
	DO.intDispatchOrderId
	,DO.strDispatchOrderNumber
	,DO.dtmDispatchDate
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTruckId
	,DO.intEntityShipViaTrailerId
	,DO.intDriverEntityId
	,DO.intDispatchStatus
	,DO.strComments
	,DO.intConcurrencyId
	,DO.intSourceType
	,strShipVia = SV.strName
	,strDriver = DV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strTrailerNumber = SVTL.strTrailerNumber
	,strTrailerType = SVTL.strTrailerDescription --temp placeholder for trailer type
	,dblMaxWeight = DO.dblMaxWeight
	,dblLoadWeight = DO.dblLoadWeight
	,strDispatchStatus = CASE (DO.intDispatchStatus) 
		WHEN 1 THEN 'Scheduled'
		WHEN 2 THEN 'In Progress'
		WHEN 3 THEN 'Complete'
		WHEN 4 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,strSourceType = CASE (DO.intSourceType)
		WHEN 1 THEN 'LG Loads - Outbound'
		WHEN 2 THEN 'TM Orders'
		WHEN 3 THEN 'LG Loads - Inbound'
		WHEN 4 THEN 'TM Sites'
		WHEN 5 THEN 'Entities'
		WHEN 6 THEN 'Sales/Transfer Orders'
		ELSE '' END COLLATE Latin1_General_CI_AS
FROM tblLGDispatchOrder DO
	LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
	LEFT JOIN tblEMEntity DV ON DV.intEntityId = DO.intDriverEntityId
	LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
	LEFT JOIN tblSMShipViaTrailer SVTL ON SVTL.intEntityShipViaTrailerId = DO.intEntityShipViaTrailerId
GO