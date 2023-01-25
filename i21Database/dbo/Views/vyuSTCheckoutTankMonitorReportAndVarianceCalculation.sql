CREATE VIEW vyuSTCheckoutTankMonitorReportAndVarianceCalculation
AS
SELECT		b.intTankReadingsId as intTankReadingsId,
			a.intCheckoutId,
			d.intRegisterTankNumber as intRegisterTankNumber,
			e.strDescription as strDescription,
			CASE 
			WHEN LEN(e.intSiteNumber) = 1
			THEN '000' + CAST(e.intSiteNumber as NVARCHAR(1))
			WHEN LEN(e.intSiteNumber) = 2
			THEN '00' + CAST(e.intSiteNumber as NVARCHAR(2))
			WHEN LEN(e.intSiteNumber) = 3
			THEN '0' + CAST(e.intSiteNumber as NVARCHAR(3))
			ELSE CAST(e.intSiteNumber as NVARCHAR(1))
			END as strConsumptionSite,
			ISNULL(b.dblFuelLvl, 0) AS dblFuelLvl,
			ISNULL(b.dblFuelVolume, 0) AS dblFuelVolume,
			ISNULL(b.dblFuelTemperature, 0) AS dblFuelTemperature,
			ISNULL(b.dblWaterLevel, 0) AS dblWaterLevel,
			ISNULL(b.dblSumOfDeliveriesPerTank, 0) AS dblSumOfDeliveriesPerTank,
			ISNULL(b.dblTankVolume, 0) AS dblTankVolume,
			ISNULL(b.dblCalculatedVariance, 0) AS dblCalculatedVariance
FROM		tblSTCheckoutHeader  a
INNER JOIN	tblSTCheckoutTankReadings b
ON			a.intCheckoutId = b.intCheckoutId
INNER JOIN	tblSTStore c
ON			a.intStoreId = c.intStoreId
INNER JOIN	tblSTStoreFuelTanks d
ON			c.intStoreId = d.intStoreId AND b.intDeviceId = d.intDeviceId
INNER JOIN	tblTMSite e
ON			c.intCompanyLocationId = e.intLocationId AND e.ysnCompanySite = 1
INNER JOIN	tblTMSiteDevice f
ON			f.intSiteID = e.intSiteID AND
			b.intDeviceId = f.intDeviceId