CREATE VIEW [dbo].[vyuSTFuelTanks]
AS
SELECT DISTINCT 
	device.strSerialNumber, 
	item.strItemNo, 
	item.strDescription,
	site.intCompanyLocationId,
	CASE 
		WHEN LEN(site.intSiteNumber) = 1
		THEN '000' + CAST(site.intSiteNumber as NVARCHAR(1))
		WHEN LEN(site.intSiteNumber) = 2
		THEN '00' + CAST(site.intSiteNumber as NVARCHAR(2))
		WHEN LEN(site.intSiteNumber) = 3
		THEN '0' + CAST(site.intSiteNumber as NVARCHAR(3))
		ELSE CAST(site.intSiteNumber as NVARCHAR(1))
		END as strSiteNumber,
	device.intDeviceId,
	site.intCompanyConsumptionSiteId
FROM tblTMDevice device
JOIN tblTMCompanySiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMCompanyConsumptionSite site
	ON site.intCompanyConsumptionSiteId = sitedevice.intCompanyConsumptionSiteId
INNER JOIN tblICItem item
	ON site.intItemId = item.intItemId
WHERE device.strSerialNumber != '' AND 
		device.intDeviceTypeId = 1 AND --intDeviceTypeId = 1 means Tank
		site.ysnCompanySite = 1