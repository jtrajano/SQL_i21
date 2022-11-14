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

	SELECT	@intPreviousCheckoutId = MAX(intCheckoutId)
	FROM	dbo.tblSTCheckoutHeader
	WHERE	intStoreId = @intStoreId AND
	        strCheckoutType = 'Automatic' AND
			dtmCheckoutDate < @dtmCheckoutDate;

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
				@intCheckoutId as intCheckoutId,
				b.intFuelingPositionId,
				b.intProductNumber ,
				I.strDescription,
				ISNULL(a.dblFuelVolume, 0) as dblPriorGallons,
				ISNULL(a.dblFuelMoney, 0) as dblPriorDollars,
				b.dblFuelVolume as dblCurrentGallons,
				b.dblFuelMoney as dblCurrentDollars,
				b.dblFuelVolume - ISNULL(a.dblFuelVolume, 0) as 'dblGallonsSold',
				b.dblFuelMoney - ISNULL(a.dblFuelMoney, 0) as 'dblDollarsSold'
	FROM		current_day_reading b			
	LEFT JOIN	previous_day_reading a
	ON			a.intProductNumber = b.intProductNumber AND
				a.intFuelingPositionId = b.intFuelingPositionId
	JOIN dbo.tblICItemLocation IL 
	ON ISNULL(CAST(b.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, '')) AND
				IL.intLocationId = (SELECT intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId)
	 JOIN dbo.tblICItem I 
		ON I.intItemId = IL.intItemId
	 JOIN dbo.tblICItemUOM UOM 
		ON UOM.intItemId = I.intItemId
	 JOIN dbo.tblSMCompanyLocation CL 
		ON CL.intCompanyLocationId = IL.intLocationId
	 JOIN dbo.tblSTStore S 
		ON S.intCompanyLocationId = CL.intCompanyLocationId
END