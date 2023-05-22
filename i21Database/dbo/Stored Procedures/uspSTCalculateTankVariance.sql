﻿CREATE PROCEDURE [dbo].[uspSTCalculateTankVariance] 
(
	@intCheckoutId AS INT,
	@ysnFromEdit AS BIT
)
AS BEGIN
	DECLARE @dtmCheckoutDate DATETIME
	DECLARE @intStoreId INT
	DECLARE @intPreviousCheckoutId INT
	DECLARE @dblPreviousCheckoutTankMonitorFuelVolume DECIMAL(18, 6)
	DECLARE @dblDeliveries DECIMAL(18, 6)
	DECLARE @intDeviceId INT
	DECLARE @intSiteId INT
	DECLARE @dtmStartDate DATETIME
	DECLARE @dtmEndDate DATETIME
	DECLARE @dtmDeliveryDate DATETIME
	

	SELECT	@intStoreId = intStoreId,
			@dtmCheckoutDate = dtmCheckoutDate,
			@dtmStartDate = CONVERT(DATETIME, strCheckoutStartDate),
			@dtmEndDate = CONVERT(DATETIME, strCheckoutCloseDate)
	FROM	dbo.tblSTCheckoutHeader 
	WHERE	intCheckoutId = @intCheckoutId

	SELECT	@intPreviousCheckoutId = MAX(intCheckoutId)
	FROM	dbo.tblSTCheckoutHeader
	WHERE	intStoreId = @intStoreId AND
			strCheckoutType = 'Automatic' AND
			dtmCheckoutDate < @dtmCheckoutDate
	
	DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR  
	SELECT		a.intDeviceId
	FROM		tblSTCheckoutTankVarianceCalculation a
	WHERE		a.intCheckoutId = @intCheckoutId

	OPEN MY_CURSOR  
	FETCH NEXT FROM MY_CURSOR INTO @intDeviceId
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SELECT		@dblPreviousCheckoutTankMonitorFuelVolume = dblEndFuelVolume
		FROM		tblSTCheckoutTankVarianceCalculation
		WHERE		intCheckoutId = @intPreviousCheckoutId AND 
					intDeviceId = @intDeviceId

		SELECT		@intSiteId = e.intSiteID
		FROM		tblSTCheckoutHeader  a
		INNER JOIN	tblSTCheckoutTankVarianceCalculation b
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
		WHERE		a.intCheckoutId = @intCheckoutId AND b.intDeviceId = @intDeviceId

		SELECT		@dblDeliveries = SUM(c.dblUnits),
					@dtmDeliveryDate = a.dtmLoadDateTime
		FROM		tblTRLoadHeader a
		INNER JOIN	tblTRLoadDistributionHeader b
		ON			a.intLoadHeaderId = b.intLoadHeaderId
		INNER JOIN	tblTRLoadDistributionDetail c
		ON			b.intLoadDistributionHeaderId = c.intLoadDistributionHeaderId
		INNER JOIN	tblTMSite d
		ON			c.intSiteId = d.intSiteID
		WHERE		d.ysnCompanySite = 1 AND 
					d.intSiteID = @intSiteId AND
					(a.dtmLoadDateTime >= @dtmStartDate AND a.dtmLoadDateTime <= @dtmEndDate)
		GROUP BY	a.dtmLoadDateTime


		SET @dblPreviousCheckoutTankMonitorFuelVolume = ISNULL(@dblPreviousCheckoutTankMonitorFuelVolume, 0)
		SET @dblDeliveries = ISNULL(@dblDeliveries, 0)

		IF @dblDeliveries > 0
		BEGIN
			IF @ysnFromEdit = 0
			BEGIN
				INSERT INTO tblSTCheckoutFuelDeliveries (intCheckoutId, intDeviceId, dblGallons, dtmDeliveryDate, intConcurrencyId)
				VALUES (@intCheckoutId, @intDeviceId, @dblDeliveries, @dtmDeliveryDate, 1)
			END
		END

		IF @ysnFromEdit = 1
		BEGIN
			SELECT		@dblDeliveries = SUM(dblGallons)
			FROM		tblSTCheckoutFuelDeliveries
			WHERE		intDeviceId = @intDeviceId AND
						intCheckoutId = @intCheckoutId
		END

		SET @dblDeliveries = ISNULL(@dblDeliveries, 0)

		UPDATE	tblSTCheckoutTankVarianceCalculation
		SET		dblStartFuelVolume = @dblPreviousCheckoutTankMonitorFuelVolume,
				dblDeliveries = @dblDeliveries,
				dblCalculatedVariance = ABS((@dblPreviousCheckoutTankMonitorFuelVolume + @dblDeliveries - dblSales) - dblEndFuelVolume)
		WHERE	intCheckoutId = @intCheckoutId AND intDeviceId = @intDeviceId

		FETCH NEXT FROM MY_CURSOR INTO @intDeviceId
	END  
	CLOSE MY_CURSOR  
	DEALLOCATE MY_CURSOR  
END