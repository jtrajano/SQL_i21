CREATE VIEW [dbo].[vyuSTGetFuelInventory]
AS
SELECT		fuelInventory.intFuelInventoryId,
			fuelInventory.intCheckoutId,
			fuelInventory.intDeviceId,
			fuelInventory.dblGallons,
			fuelInventory.dtmFuelInventoryDate,
			fuelInventory.intConcurrencyId,
			item.strItemNo,
			device.strSerialNumber,
			fuelInventory.ysnIsManualEntry
FROM		tblSTCheckoutFuelInventory fuelInventory
INNER JOIN	tblTMDevice device
ON			fuelInventory.intDeviceId = device.intDeviceId
INNER JOIN	tblTMSiteDevice sitedevice
ON			device.intDeviceId = sitedevice.intDeviceId
INNER JOIN	tblTMSite site
ON			site.intSiteID = sitedevice.intSiteID
INNER JOIN tblICItem item
ON			site.intProduct = item.intItemId