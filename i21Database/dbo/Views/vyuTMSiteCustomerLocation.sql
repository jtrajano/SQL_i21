CREATE VIEW [dbo].[vyuTMSiteCustomerLocation]
AS 
SELECT LCS.intEntityLocationConsumptionSiteId
, LCS.intEntityLocationId
, EL.strLocationName
, LCS.intSiteID
FROM tblEMEntityLocationConsumptionSite LCS
INNER JOIN tblTMSite S ON S.intSiteID = LCS.intSiteID
INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LCS.intEntityLocationId
