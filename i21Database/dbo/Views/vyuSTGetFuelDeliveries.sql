CREATE VIEW [dbo].[vyuSTGetFuelDeliveries]
AS
SELECT		fuelDelivery.intFuelDeliveryId,
			fuelDelivery.intCheckoutId,
			fuelDelivery.intDeviceId,
			fuelDelivery.dblGallons,
			fuelDelivery.dtmDeliveryDate,
			fuelDelivery.intConcurrencyId,
			item.strItemNo,
			device.strSerialNumber
FROM		tblSTCheckoutFuelDeliveries fuelDelivery
INNER JOIN	tblTMDevice device
ON			fuelDelivery.intDeviceId = device.intDeviceId
INNER JOIN	tblTMSiteDevice sitedevice
ON			device.intDeviceId = sitedevice.intDeviceId
INNER JOIN	tblTMSite site
ON			site.intSiteID = sitedevice.intSiteID
INNER JOIN tblICItem item
ON			site.intProduct = item.intItemId