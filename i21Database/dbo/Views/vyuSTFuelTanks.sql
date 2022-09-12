CREATE VIEW [dbo].[vyuSTFuelTanks]
AS

SELECT DISTINCT 
	device.strSerialNumber, 
	item.strItemNo, 
	item.strDescription
FROM tblTMDevice device
JOIN tblTMSiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMSite site
	ON site.intSiteID = sitedevice.intSiteID
INNER JOIN tblICItem item
	ON site.intProduct = item.intItemId
WHERE strSerialNumber != ''