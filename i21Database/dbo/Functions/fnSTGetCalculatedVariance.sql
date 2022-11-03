CREATE FUNCTION [dbo].[fnSTGetCalculatedVariance] 
(
	@intCheckoutId AS INT,
	@intDeviceId AS INT,
	@dblFuelVolume AS DECIMAL(18, 6),
	@dblSumOfDeliveriesPerTank AS DECIMAL(18, 6),
	@dblTankVolume AS DECIMAL(18, 6)
)
RETURNS DECIMAL(18, 6)
AS BEGIN
	DECLARE @dtmCheckoutDate DATETIME
	DECLARE @intStoreId INT
	DECLARE @intPreviousCheckoutId INT
	DECLARE @dblPreviousCheckoutTankMonitorFuelVolume DECIMAL(18, 6)

	SELECT	@intStoreId = intStoreId,
			@dtmCheckoutDate = dtmCheckoutDate
	FROM	dbo.tblSTCheckoutHeader 
	WHERE	intCheckoutId = @intCheckoutId

	SELECT	@intPreviousCheckoutId = MAX(intCheckoutId)
	FROM	dbo.tblSTCheckoutHeader
	WHERE	intStoreId = @intStoreId AND
			strCheckoutType = 'Automatic' AND
			dtmCheckoutDate < @dtmCheckoutDate

	SELECT	@dblPreviousCheckoutTankMonitorFuelVolume = dblFuelVolume
	FROM	tblSTCheckoutTankReadings
	WHERE	intCheckoutId = @intPreviousCheckoutId AND 
			intDeviceId = @intDeviceId

	RETURN	ABS((@dblPreviousCheckoutTankMonitorFuelVolume + @dblSumOfDeliveriesPerTank - @dblTankVolume) - @dblFuelVolume)
END