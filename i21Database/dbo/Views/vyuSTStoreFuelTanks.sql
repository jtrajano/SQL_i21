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
FROM tblSTStoreFuelTanks FT
JOIN tblSTStore ST
	ON FT.intStoreId = ST.intStoreId
JOIN tblTMDevice device
	ON FT.strSerialNumber = device.strSerialNumber
JOIN tblTMCompanySiteDevice sitedevice
	ON device.intDeviceId = sitedevice.intDeviceId
INNER JOIN tblTMCompanyConsumptionSite site
	ON site.intCompanyConsumptionSiteId = sitedevice.intCompanyConsumptionSiteId AND
		ST.intCompanyLocationId = site.intCompanyLocationId
INNER JOIN tblICItem item
	ON site.intItemId = item.intItemId