CREATE VIEW vyuSTStoreFuelTanks
AS
SELECT 
	FT.intStoreFuelTankId,
	FT.intStoreId,
	device.strSerialNumber, 
	item.strItemNo, 
	item.strDescription,
	FT.intRegisterTankNumber,
	FT.intConcurrencyId,
	site.intLocationId as intCompanyLocationId,
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
	site.intSiteID as intCompanyConsumptionSiteId,
	site.intCustomerID
FROM tblSTStoreFuelTanks FT
JOIN tblSTStore ST
	ON FT.intStoreId = ST.intStoreId
JOIN tblTMDevice device
	ON FT.strSerialNumber = device.strSerialNumber
JOIN tblTMSiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMSite site
	ON site.intSiteID = sitedevice.intSiteID AND
		ST.intCompanyLocationId = site.intLocationId
INNER JOIN tblICItem item
	ON site.intProduct = item.intItemId