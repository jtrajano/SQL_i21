CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantFGM]
@intCheckoutId Int,
@strXML nvarchar(MAX)
AS
BEGIN

	DECLARE @intStoreId Int
	Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
	BEGIN
		INSERT INTO dbo.tblSTCheckoutPumpTotals
		SELECT @intCheckoutId 
		, UOM.intItemUOMId [intPumpCardCouponId]
		,I.intCategoryId
		, I.strDescription
		, (ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0)/ ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) [dblPrice]
		, ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0) [dblQuantity]
		, ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) [dblAmount]
		, 0
		from #tempCheckoutInsert Chk
		JOIN dbo.tblICItemLocation IL ON Chk.FuelGradeID COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1
																							WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2
																							WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3
																						END
		JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId
		JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE S.intStoreId = @intStoreId
	END
	ELSE
	BEGIN
		UPDATE dbo.tblSTCheckoutPumpTotals
		SET [dblPrice] = (ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0)/ ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1))
		, [dblQuantity] = ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0)
		, [dblAmount] = ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0)
		from #tempCheckoutInsert Chk
		JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1
																							WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2
																							WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3
																						END
		JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId
		JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE intCheckoutId = @intCheckoutId AND intPumpCardCouponId = UOM.intItemUOMId

	END

END

