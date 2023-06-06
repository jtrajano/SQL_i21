CREATE VIEW [dbo].[vyuSTGetTankVarianceCalculation]
AS
SELECT		tankVariance.intTankVarianceId,
			tankVariance.intCheckoutId,
			tankVariance.intDeviceId,
			tankVariance.dblStartFuelVolume,
			tankVariance.dblDeliveries,
			tankVariance.dblSales,
			tankVariance.dblEndFuelVolume,
			tankVariance.dblCalculatedVariance,
			item.strDescription,
			device.strSerialNumber,
			CASE 
			WHEN LEN(site.intSiteNumber) = 1
			THEN '000' + CAST(site.intSiteNumber as NVARCHAR(1))
			WHEN LEN(site.intSiteNumber) = 2
			THEN '00' + CAST(site.intSiteNumber as NVARCHAR(2))
			WHEN LEN(site.intSiteNumber) = 3
			THEN '0' + CAST(site.intSiteNumber as NVARCHAR(3))
			ELSE CAST(site.intSiteNumber as NVARCHAR(1))
			END as strConsumptionSite,
			tankVariance.intConcurrencyId
FROM		tblSTCheckoutTankVarianceCalculation tankVariance
INNER JOIN	tblTMDevice device
ON			tankVariance.intDeviceId = device.intDeviceId
INNER JOIN	tblTMSiteDevice sitedevice
ON			device.intDeviceId = sitedevice.intDeviceId
INNER JOIN	tblTMSite site
ON			site.intSiteID = sitedevice.intSiteID
INNER JOIN tblICItem item
ON			site.intProduct = item.intItemId