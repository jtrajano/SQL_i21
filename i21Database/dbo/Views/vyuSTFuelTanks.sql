CREATE VIEW [dbo].[vyuSTFuelTanks]
AS
SELECT DISTINCT 
	device.strSerialNumber, 
	item.strItemNo, 
	item.strDescription
FROM tblTMDevice device
JOIN tblTMCompanySiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMCompanyConsumptionSite site
	ON site.intCompanyConsumptionSiteId = sitedevice.intCompanyConsumptionSiteId
INNER JOIN tblICItem item
	ON site.intItemId = item.intItemId
WHERE strSerialNumber != ''