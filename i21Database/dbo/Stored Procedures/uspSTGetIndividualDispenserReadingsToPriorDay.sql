CREATE PROCEDURE [dbo].[uspSTGetIndividualDispenserReadingsToPriorDay]
	@intCheckoutId int
AS
BEGIN
	DECLARE @intStoreId INT
	DECLARE @intPreviousCheckoutId INT
	DECLARE @dtmCheckoutDate DATETIME

	SELECT	@intStoreId = intStoreId,
			@dtmCheckoutDate = dtmCheckoutDate
	FROM	dbo.tblSTCheckoutHeader 
	WHERE	intCheckoutId = @intCheckoutId

	SELECT	@intPreviousCheckoutId = intCheckoutId
	FROM	dbo.tblSTCheckoutHeader
	WHERE	intStoreId = @intStoreId AND
			dtmCheckoutDate = DATEADD(day, -1, @dtmCheckoutDate);

	WITH previous_day_reading (intFuelTotalsId, intFuelingPositionId,intProductNumber, dblFuelVolume, dblFuelMoney)  
	AS  
	(  
	    SELECT intFuelTotalsId, intFuelingPositionId, intProductNumber, dblFuelVolume, dblFuelMoney FROM tblSTCheckoutFuelTotals
		WHERE intCheckoutId = @intPreviousCheckoutId
	)  
	,
	current_day_reading (intFuelTotalsId, intFuelingPositionId,intProductNumber, dblFuelVolume, dblFuelMoney)  
	AS  
	(  
	    SELECT intFuelTotalsId, intFuelingPositionId,intProductNumber, dblFuelVolume, dblFuelMoney FROM tblSTCheckoutFuelTotals
		WHERE intCheckoutId = @intCheckoutId
	)
	
	SELECT		b.intFuelTotalsId, 
				@intCheckoutId,
				b.intFuelingPositionId,
				b.intProductNumber ,
				CASE 
					WHEN b.intProductNumber = 1
					THEN '87 Unl'
					WHEN b.intProductNumber = 2
					THEN '89 Mid'
					WHEN b.intProductNumber = 3
					THEN '91 Premium'
					WHEN b.intProductNumber = 4
					THEN 'Diesel'
					END as 'strDescription',
				a.dblFuelVolume as dblPriorGallons,
				a.dblFuelMoney as dblPriorDollars,
				b.dblFuelVolume as dblCurrentGallons,
				b.dblFuelMoney as dblCurrentDollars,
				b.dblFuelVolume - a.dblFuelVolume as 'dblGallonsSold',
				b.dblFuelMoney - a.dblFuelMoney as 'dblDollarsSold'
	FROM		previous_day_reading a
	INNER JOIN	current_day_reading b
	ON			a.intProductNumber = b.intProductNumber AND
				a.intFuelingPositionId = b.intFuelingPositionId
	ORDER BY	1,2
END