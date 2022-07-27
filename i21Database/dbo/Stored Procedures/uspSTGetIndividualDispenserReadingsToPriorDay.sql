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
				@intCheckoutId as intCheckoutId,
				b.intFuelingPositionId,
				b.intProductNumber ,
				I.strDescription,
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
	JOIN dbo.tblICItemLocation IL 
	ON ISNULL(CAST(b.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, ''))
	 JOIN dbo.tblICItem I 
		ON I.intItemId = IL.intItemId
	 JOIN dbo.tblICItemUOM UOM 
		ON UOM.intItemId = I.intItemId
	 JOIN dbo.tblSMCompanyLocation CL 
		ON CL.intCompanyLocationId = IL.intLocationId
	 JOIN dbo.tblSTStore S 
		ON S.intCompanyLocationId = CL.intCompanyLocationId
END