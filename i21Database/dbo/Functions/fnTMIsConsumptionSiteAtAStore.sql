CREATE FUNCTION [dbo].[fnTMIsConsumptionSiteAtAStore]
(
	@intSiteId INT
)
RETURNS BIT
BEGIN
	DECLARE @ysnReturnValue BIT = 0

	SELECT		@ysnReturnValue = 1
	FROM		tblSTStore c
	INNER JOIN	tblSTStoreFuelTanks d
	ON			c.intStoreId = d.intStoreId
	INNER JOIN	tblTMSite e
	ON			c.intCompanyLocationId = e.intLocationId AND 
				e.intSiteID = @intSiteId AND
				e.ysnCompanySite = 1
	
	RETURN @ysnReturnValue
END
GO