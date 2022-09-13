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
JOIN tblTMSiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMSite site
	ON site.intSiteID = sitedevice.intSiteID
INNER JOIN tblICItem item
	ON site.intProduct = item.intItemId