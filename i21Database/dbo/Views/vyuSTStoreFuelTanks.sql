CREATE VIEW vyuSTStoreFuelTanks
AS
SELECT 
	FT.intStoreFuelTankId,
	FT.intStoreId,
	device.strSerialNumber, 
	item.strItemNo, 
	item.strDescription,
	FT.intRegisterTankNumber,
	FT.intConcurrencyId
FROM tblSTStoreFuelTanks FT
JOIN tblTMDevice device
	ON FT.strSerialNumber = device.strSerialNumber
JOIN tblTMCompanySiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMCompanyConsumptionSite site
	ON site.intCompanyConsumptionSiteId = sitedevice.intCompanyConsumptionSiteId
INNER JOIN tblICItem item
	ON site.intItemId = item.intItemId