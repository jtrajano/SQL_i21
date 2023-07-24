CREATE FUNCTION [dbo].[fnTMGetFuelTankReadingStartOrEndVolume]
(
	@dtmDate				DATETIME,
	@intSiteId				INT,
	@ysnStore				BIT,
	@ysnGetStartVolume		BIT,
	@ysnIsUnAuditedReport	BIT
)
RETURNS DECIMAL(18,6)
BEGIN
	DECLARE		@dblReturnValue DECIMAL(18,6) = 0

	IF @ysnGetStartVolume = 1
	BEGIN
		SELECT		TOP 1 @dblReturnValue = dblFuelVolume
		FROM		tblTMTankReading 
		WHERE		dtmDateTime < @dtmDate AND
					intSiteId = @intSiteId AND
					intReadingSource IN (1,2,3)
		ORDER BY	dtmDateTime DESC
	END
	ELSE
	BEGIN
		IF @ysnStore = 1
		BEGIN
			IF @ysnIsUnAuditedReport = 0
			BEGIN
				SELECT		TOP 1 @dblReturnValue = dblFuelVolume
				FROM		tblTMTankReading 
				WHERE		dtmDateTime >= @dtmDate AND dtmDateTime < DATEADD(DAY,1,@dtmDate) AND
							intSiteId = @intSiteId AND
							intReadingSource IN (2, 3)
				ORDER BY	dtmDateTime DESC
			END
			ELSE
			BEGIN
				SELECT		TOP 1 @dblReturnValue = dblFuelVolume FROM (
								SELECT			fuelInventory.dblGallons as dblFuelVolume,
												checkoutHeader.dtmCheckoutDate as dtmDateTime
								FROM			tblSTCheckoutHeader checkoutHeader
								INNER JOIN		tblSTCheckoutFuelInventory fuelInventory
								ON				checkoutHeader.intCheckoutId = fuelInventory.intCheckoutId
								INNER JOIN		tblTMDevice device
								ON				fuelInventory.intDeviceId = device.intDeviceId
								INNER JOIN		tblSTStoreFuelTanks storeFuelTank
								ON				fuelInventory.intDeviceId = storeFuelTank.intDeviceId
								LEFT JOIN		tblTMSiteDevice siteDevice 
								ON				fuelInventory.intDeviceId = siteDevice.intDeviceId
								WHERE			checkoutHeader.dtmCheckoutDate = @dtmDate AND
												siteDevice.intSiteID = @intSiteId

								UNION

								SELECT		dblFuelVolume,
											dtmDateTime
								FROM		tblTMTankReading 
								WHERE		dtmDateTime >= @dtmDate AND dtmDateTime < DATEADD(DAY,1,@dtmDate) AND
											intSiteId = @intSiteId AND
											intReadingSource IN (2, 3)) combinedData
				ORDER BY	combinedData.dtmDateTime DESC
			END
		END
		ELSE
		BEGIN
			SELECT		TOP 1 @dblReturnValue = dblFuelVolume
			FROM		tblTMTankReading 
			WHERE		dtmDateTime >= @dtmDate AND dtmDateTime < DATEADD(DAY,1,@dtmDate) AND
						intSiteId = @intSiteId AND
						intReadingSource IN (1,2,3)
			ORDER BY	dtmDateTime DESC
		END
	END
	
	RETURN @dblReturnValue
END
GO