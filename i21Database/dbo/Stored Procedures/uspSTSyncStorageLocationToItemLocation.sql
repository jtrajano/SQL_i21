CREATE PROCEDURE [dbo].[uspSTSyncStorageLocationToItemLocation]
	@intStoreId		INT
AS
BEGIN
	UPDATE		ItemLocation
	SET			ItemLocation.intSubLocationId = e.intCompanyLocationSubLocationId
	FROM 		tblSTStore c
	INNER JOIN	tblSTStoreFuelTanks d
	ON			c.intStoreId = d.intStoreId
	INNER JOIN	tblTMSite e
	ON			c.intCompanyLocationId = e.intLocationId AND e.ysnCompanySite = 1
	INNER JOIN	tblTMSiteDevice f
	ON			f.intSiteID = e.intSiteID AND
				d.intDeviceId = f.intDeviceId
	INNER JOIN	tblICItemLocation ItemLocation
	ON			ItemLocation.intItemId = e.intProduct AND
				c.intCompanyLocationId = ItemLocation.intLocationId
	WHERE		c.intStoreId = @intStoreId
END