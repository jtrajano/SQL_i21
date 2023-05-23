CREATE FUNCTION [dbo].[fnTMGetDeliveries]
(
	@dtmDate				DATETIME,
	@intSiteId				INT,
	@ysnGetPostedOnly		BIT
)
RETURNS DECIMAL(18,6)
BEGIN
	DECLARE		@dblReturnValue DECIMAL(18,6) = 0
	DECLARE		@intItemId INT = 0
	DECLARE		@intItemUOMId INT = 0
	DECLARE		@intLocationId INT = 0
	DECLARE		@ysnIsUsingTransportModule BIT

	SELECT		@ysnIsUsingTransportModule = ysnSupported
	FROM		tblSMModule
	WHERE		strApplicationName = 'i21' AND strModule = 'Transports'

	IF @ysnIsUsingTransportModule = 1
	BEGIN
		IF @ysnGetPostedOnly = 1
		BEGIN
			SELECT		@dblReturnValue = SUM(c.dblUnits)
			FROM		tblTRLoadHeader a
			INNER JOIN	tblTRLoadDistributionHeader b
			ON			a.intLoadHeaderId = b.intLoadHeaderId
			INNER JOIN	tblTRLoadDistributionDetail c
			ON			b.intLoadDistributionHeaderId = c.intLoadDistributionHeaderId
			INNER JOIN	tblTMSite d
			ON			c.intSiteId = d.intSiteID
			WHERE		d.ysnCompanySite = 1 AND 
						d.intSiteID = @intSiteId AND
						(a.dtmLoadDateTime >= @dtmDate AND a.dtmLoadDateTime < DATEADD(DAY, 1, @dtmDate)) AND
						ysnPosted = 1
		END
		ELSE
		BEGIN
			SELECT		@dblReturnValue = SUM(c.dblUnits)
			FROM		tblTRLoadHeader a
			INNER JOIN	tblTRLoadDistributionHeader b
			ON			a.intLoadHeaderId = b.intLoadHeaderId
			INNER JOIN	tblTRLoadDistributionDetail c
			ON			b.intLoadDistributionHeaderId = c.intLoadDistributionHeaderId
			INNER JOIN	tblTMSite d
			ON			c.intSiteId = d.intSiteID
			WHERE		d.ysnCompanySite = 1 AND 
						d.intSiteID = @intSiteId AND
						(a.dtmLoadDateTime >= @dtmDate AND a.dtmLoadDateTime < DATEADD(DAY, 1, @dtmDate))
		END
	END
	ELSE
	BEGIN
		IF (SELECT dbo.fnTMIsConsumptionSiteAtAStore(@intSiteId)) = 1
		BEGIN

			SELECT		@dblReturnValue = SUM(b.dblGallons)
			FROM		tblSTCheckoutHeader  a
			INNER JOIN	tblSTCheckoutFuelDeliveries b
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
			WHERE		e.intSiteID = @intSiteId AND
						a.dtmCheckoutDate = @dtmDate
		END
		ELSE
		BEGIN
			SELECT		@dblReturnValue = SUM(dblQuantity) 
			FROM		vyuICGetInventoryValuation
			WHERE		intItemId = @intItemId AND
						intLocationId = @intLocationId AND
						dblQuantity > 0 AND --meaning incoming
						(dtmCreated >= @dtmDate AND dtmCreated < DATEADD(DAY, 1, @dtmDate))
		END
	END
	
	RETURN ISNULL(@dblReturnValue, 0)
END
GO