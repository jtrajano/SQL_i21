CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantFGM]
@intCheckoutId Int
AS
BEGIN

	DECLARE @intStoreId Int
	Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
	BEGIN
		INSERT INTO dbo.tblSTCheckoutPumpTotals
		SELECT @intCheckoutId 
		, UOM.intItemUOMId [intPumpCardCouponId]
		, I.strDescription
		, (CAST(ISNULL(Chk.FuelGradeSalesAmount,0) as numeric(18,6))/ CAST(ISNULL(Chk.FuelGradeSalesVolume,1) as numeric(18,6))) [dblPrice]
		, ISNULL(Chk.FuelGradeSalesVolume, 0) [dblQuantity]
		, ISNULL(Chk.FuelGradeSalesAmount,0) [dblAmount]
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
		SET [dblPrice] = (CAST(ISNULL(Chk.FuelGradeSalesAmount,0) as numeric(18,6))/ CAST(ISNULL(Chk.FuelGradeSalesVolume,1) as numeric(18,6)))
		, [dblQuantity] = ISNULL(Chk.FuelGradeSalesVolume, 0)
		, [dblAmount] = ISNULL(Chk.FuelGradeSalesAmount,0)
		from #tempCheckoutInsert Chk
		JOIN dbo.tblICItemLocation IL ON Chk.FuelGradeID COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1
																							WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2
																							WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3
																						END
		JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId
		JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE intCheckoutId = @intCheckoutId
	END

END

