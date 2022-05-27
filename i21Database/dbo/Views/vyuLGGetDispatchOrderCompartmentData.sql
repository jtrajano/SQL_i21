CREATE VIEW [dbo].[vyuLGGetDispatchOrderCompartmentData]
AS
SELECT 
	DOC.intDispatchOrderCompartmentId
	,DOC.intDispatchOrderId
	,SVTC.intEntityShipViaTrailerId
	,SVTC.intEntityShipViaTrailerCompartmentId
	,SVTC.strCompartmentNumber
	,DOC.intCategoryId
	,CAT.strCategoryCode
	,DOC.dblCapacity 
	,DOC.dblLoadWeight
	,dblPercentageFull = (DOC.dblLoadWeight / ISNULL(DOC.dblCapacity, 1))
FROM tblLGDispatchOrderCompartment DOC
LEFT JOIN tblSMShipViaTrailerCompartment SVTC ON SVTC.intEntityShipViaTrailerCompartmentId = DOC.intEntityShipViaTrailerCompartmentId
LEFT JOIN tblICCategory CAT ON CAT.intCategoryId = DOC.intCategoryId

GO