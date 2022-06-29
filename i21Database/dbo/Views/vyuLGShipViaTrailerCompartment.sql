CREATE VIEW [dbo].[vyuLGShipViaTrailerCompartment]  
AS  
SELECT   
	SVTC.intEntityShipViaTrailerCompartmentId  
	,SVTC.strCompartmentNumber  
	,SVTC.intEntityShipViaTrailerId  
	,SVT.strTrailerNumber  
	,SVTC.intCategoryId  
	,CAT.strCategoryCode  
	,SVTC.dblCapacity  
	,SVTC.intConcurrencyId  
FROM tblSMShipViaTrailerCompartment SVTC  
INNER JOIN tblSMShipViaTrailer SVT ON SVT.intEntityShipViaTrailerId = SVTC.intEntityShipViaTrailerId  
LEFT JOIN tblICCategory CAT ON CAT.intCategoryId = SVTC.intCategoryId  