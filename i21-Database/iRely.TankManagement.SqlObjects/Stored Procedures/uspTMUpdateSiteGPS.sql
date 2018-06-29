CREATE PROCEDURE uspTMUpdateSiteGPS 
	@GPSTable TMGPSUpdateTable READONLY
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
INNER JOIN tblTMCustomer C
	ON B.intCustomerID = C.intCustomerID
INNER JOIN tblEMEntity D
	ON C.intCustomerNumber = D.intEntityId
INNER JOIN @GPSTable A
	ON B.intSiteNumber = CAST(A.strSiteNumber AS INT)
	AND D.strEntityNo = A.strCustomerNumber
) Z
WHERE Z.intSiteID = tblTMSite.intSiteID
	
END
GO
