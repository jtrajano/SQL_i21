CREATE FUNCTION [dbo].[fnTMGetFuelTankReadingStartOrEndVolume]
(
	@dtmDate				DATETIME,
	@intSiteId				INT,
	@ysnStore				BIT,
	@ysnGetStartVolume		BIT
)
RETURNS DECIMAL(18,6)
BEGIN
	DECLARE		@dblReturnValue DECIMAL(18,6) = 0

	IF @ysnGetStartVolume = 1
	BEGIN
		IF @ysnStore = 1
		BEGIN
			SELECT		TOP 1 @dblReturnValue = dblFuelVolume
			FROM		tblTMTankReading 
			WHERE		dtmDateTime < @dtmDate AND
						intSiteId = @intSiteId AND
						intReadingSource IN (2)
			ORDER BY	dtmDateTime DESC
		END
		ELSE
		BEGIN
			SELECT		TOP 1 @dblReturnValue = dblFuelVolume
			FROM		tblTMTankReading 
			WHERE		dtmDateTime < @dtmDate AND
						intSiteId = @intSiteId AND
						intReadingSource IN (1,3)
			ORDER BY	dtmDateTime DESC
		END
	END
	ELSE
	BEGIN
		IF @ysnStore = 1
		BEGIN
			SELECT		TOP 1 @dblReturnValue = dblFuelVolume
			FROM		tblTMTankReading 
			WHERE		dtmDateTime >= @dtmDate AND dtmDateTime < DATEADD(DAY,1,@dtmDate) AND
						intSiteId = @intSiteId AND
						intReadingSource IN (2)
			ORDER BY	dtmDateTime DESC
		END
		ELSE
		BEGIN
			SELECT		TOP 1 @dblReturnValue = dblFuelVolume
			FROM		tblTMTankReading 
			WHERE		dtmDateTime >= @dtmDate AND dtmDateTime < DATEADD(DAY,1,@dtmDate) AND
						intSiteId = @intSiteId AND
						intReadingSource IN (1,3)
			ORDER BY	dtmDateTime DESC
		END
	END
	
	RETURN @dblReturnValue
END
GO