CREATE PROCEDURE [dbo].[uspSTCheckoutPassportFGM]
@intCheckoutId Int,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows int OUTPUT
AS
BEGIN
	Begin Try

	DECLARE @intStoreId Int
	Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	--Update values that are '' empty
	Update #tempCheckoutInsert
	Set FuelGradeSalesVolume = 1
	WHERE FuelGradeSalesVolume IS NULL OR FuelGradeSalesVolume = '' OR FuelGradeSalesVolume = '0'

	Select * FROM #tempCheckoutInsert

	-- Company Currency Decimal
	DECLARE @intCompanyCurrencyDecimal INT
	SET @intCompanyCurrencyDecimal = 0
	SELECT @intCompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @SQL NVARCHAR(MAX) = ''



	IF NOT EXISTS (SELECT COUNT(intCheckoutId) FROM dbo.tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
		BEGIN

			INSERT INTO dbo.tblSTCheckoutPumpTotals(				 [intCheckoutId]				 , [intPumpCardCouponId]				 , [intCategoryId]				 , [strDescription]				 , [dblPrice]				 , [dblQuantity]				 , [dblAmount]				 , [intConcurrencyId]			)			 SELECT 				  [intCheckoutId]			    = @intCheckoutId				, [intPumpCardCouponId]		= UOM.intItemUOMId				, [intCategoryId]			    = I.intCategoryId				, [strDescription]			= I.strDescription				, [dblPrice]					= CAST((ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) AS DECIMAL(18,6))				, [dblQuantity]				= ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0)				, [dblAmount]					= CAST(((CAST((ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) AS DECIMAL(18,6))) * (ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0))) AS DECIMAL(18,6))				, [intConcurrencyId]			= 0			 FROM #tempCheckoutInsert Chk			 JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1					WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2					WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3					END			 JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId			 JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId			 JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId			 JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId			 WHERE S.intStoreId = @intStoreId

	
		END
	ELSE
		BEGIN

				UPDATE dbo.tblSTCheckoutPumpTotals					 SET [dblPrice] = CAST(ISNULL(Chk.FuelGradeSalesAmount, 0) AS DECIMAL(18,6)) / CAST(ISNULL(Chk.FuelGradeSalesVolume, 0) AS DECIMAL(18,6))					, [dblQuantity] = CAST(ISNULL(Chk.FuelGradeSalesVolume, 0) AS DECIMAL(18,6))					, [dblAmount] = (CAST(ISNULL(Chk.FuelGradeSalesAmount, 0) AS DECIMAL(18,6)) / CAST(ISNULL(Chk.FuelGradeSalesVolume, 0) AS DECIMAL(18,6))) * CAST(ISNULL(Chk.FuelGradeSalesVolume, 0) AS DECIMAL(18,6))				 FROM #tempCheckoutInsert Chk				 JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1							WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2							WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3						END				 JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId				 JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId				 JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId				 JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId				 WHERE (intCheckoutId = @intCheckoutId) AND intPumpCardCouponId = UOM.intItemUOMId

		END

	SET @intCountRows = 1
	SET @strStatusMsg = 'Success'

	End Try

	Begin Catch
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END