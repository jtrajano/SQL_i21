CREATE PROCEDURE uspTMUpdateSiteGPSById 
	@GPSTable TMGPSUpdateByIdTable READONLY
AS
BEGIN

UPDATE tblTMSite
SET dblLatitude = Z.dblLatitude
	,dblLongitude = Z.dblLongitude
	,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
FROM( 
SELECT B.intSiteID
	,A.dblLatitude
	,A.dblLongitude
FROM tblTMSite B
INNER JOIN @GPSTable A
	ON A.intSiteId = B.intSiteID
) Z
WHERE Z.intSiteID = tblTMSite.intSiteID
	
END
GO
