CREATE VIEW [dbo].[vyuLGGetDispatchOrderCompartmentData]
AS
SELECT 
	DO.intDispatchOrderId
	,DO.intEntityShipViaTrailerId
	,SVTC.intEntityShipViaTrailerCompartmentId
	,SVTC.strCompartmentNumber
	,SVTC.intCategoryId
	,CAT.strCategoryCode
	,SVTC.dblCapacity 
	,dblLoadWeight = DOD.dblLoadWeight
	,dblPercentageFull = (DOD.dblLoadWeight / ISNULL(SVTC.dblCapacity, 1)) * 100
FROM tblLGDispatchOrder DO
LEFT JOIN tblSMShipViaTrailerCompartment SVTC ON SVTC.intEntityShipViaTrailerId = DO.intEntityShipViaTrailerId
LEFT JOIN tblICCategory CAT ON CAT.intCategoryId = SVTC.intCategoryId
OUTER APPLY (SELECT dblLoadWeight = SUM(ISNULL(dblStandardWeight, 0)) 
			FROM tblLGDispatchOrderDetail 
			WHERE intDispatchOrderId = DO.intDispatchOrderId
				AND intEntityShipViaCompartmentId = SVTC.intEntityShipViaTrailerCompartmentId) DOD
GO

