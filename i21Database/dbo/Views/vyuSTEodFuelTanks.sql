CREATE VIEW [dbo].[vyuSTEodFuelTanks]
AS
SELECT		device.intStoreId,
			device.strSerialNumber, 
			item.strItemNo,
			device.intDeviceId,
			device.intRegisterTankNumber
FROM		tblSTStoreFuelTanks device
INNER JOIN	tblTMSiteDevice sitedevice
ON			device.intDeviceId = sitedevice.intDeviceId
INNER JOIN	tblTMSite site
ON			site.intSiteID = sitedevice.intSiteID
INNER JOIN tblICItem item
ON			site.intProduct = item.intItemId