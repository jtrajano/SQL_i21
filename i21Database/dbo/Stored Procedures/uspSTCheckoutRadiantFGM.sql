﻿CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantFGM]
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
	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @SQL NVARCHAR(MAX) = ''

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
	BEGIN

		SET @SQL = 'INSERT INTO dbo.tblSTCheckoutPumpTotals' + CHAR(13)
		           + ' SELECT ' + CAST(@intCheckoutId AS NVARCHAR(50)) + '' + CHAR(13)
				   + ', UOM.intItemUOMId [intPumpCardCouponId]' + CHAR(13)
				   + ', I.intCategoryId' + CHAR(13)
				   + ', I.strDescription' + CHAR(13)
				   + ', CAST((ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) AS DECIMAL(18,' + @CompanyCurrencyDecimal + ')) [dblPrice]' + CHAR(13)
				   + ', ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0) [dblQuantity]' + CHAR(13)
				   + ', CAST(((CAST((ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) AS DECIMAL(18,' + @CompanyCurrencyDecimal + '))) * (ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0))) AS DECIMAL(18,' + @CompanyCurrencyDecimal + ')) [dblAmount]' + CHAR(13)
				   + ', 0' + CHAR(13)
				   + ' FROM #tempCheckoutInsert Chk' + CHAR(13)
				   + ' JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '''') <> '''' THEN IL.strPassportFuelId1' + CHAR(13)
				   + ' WHEN ISNULL(IL.strPassportFuelId2, '''') <> '''' THEN IL.strPassportFuelId2' + CHAR(13)
				   + ' WHEN ISNULL(IL.strPassportFuelId3, '''') <> '''' THEN IL.strPassportFuelId3' + CHAR(13)
				   + ' END' + CHAR(13)
				   + ' JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId' + CHAR(13)
				   + ' JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId' + CHAR(13)
				   + ' JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId' + CHAR(13)
				   + ' JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId' + CHAR(13)
				   + ' WHERE S.intStoreId = ' + CAST(@intStoreId AS NVARCHAR(50)) + '' + CHAR(13)
		
		EXEC(@SQL)

		--INSERT INTO dbo.tblSTCheckoutPumpTotals
		--SELECT @intCheckoutId 
		--, UOM.intItemUOMId [intPumpCardCouponId]
		--,I.intCategoryId
		--, I.strDescription
		--, (ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0)/ ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) [dblPrice]
		--, ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0) [dblQuantity]
		--, ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) [dblAmount]
		--, 0
		--from #tempCheckoutInsert Chk
		--JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1
		--																					WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2
		--																					WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3
		--																				END
		--JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId
		--JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId
		--JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		--JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		--WHERE S.intStoreId = @intStoreId

		
	END
	ELSE
	BEGIN
		
		SET @SQL = 'UPDATE dbo.tblSTCheckoutPumpTotals' + CHAR(13)
		           + ' SET [dblPrice] = CAST((ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) AS DECIMAL(18,' + @CompanyCurrencyDecimal + '))' + CHAR(13)
				   + ', [dblQuantity] = ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0)' + CHAR(13)
				   + ', [dblAmount] = CAST(((CAST((ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1)) AS DECIMAL(18,' + @CompanyCurrencyDecimal + '))) * (ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0))) AS DECIMAL(18,' + @CompanyCurrencyDecimal + '))' + CHAR(13)
				   + ' FROM #tempCheckoutInsert Chk' + CHAR(13)
				   + ' JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '''') <> '''' THEN IL.strPassportFuelId1' + CHAR(13)
				   + ' WHEN ISNULL(IL.strPassportFuelId2, '''') <> '''' THEN IL.strPassportFuelId2' + CHAR(13)
				   + ' WHEN ISNULL(IL.strPassportFuelId3, '''') <> '''' THEN IL.strPassportFuelId3' + CHAR(13)
				   + ' END' + CHAR(13)
				   + ' JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId' + CHAR(13)
				   + ' JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId' + CHAR(13)
				   + ' JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId' + CHAR(13)
				   + ' JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId' + CHAR(13)
				   + ' WHERE intCheckoutId = ' + CAST(@intCheckoutId AS NVARCHAR(50)) + ' AND intPumpCardCouponId = UOM.intItemUOMId' + CHAR(13)

		EXEC(@SQL)

		--UPDATE dbo.tblSTCheckoutPumpTotals
		--SET [dblPrice] = (ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)),1))
		--, [dblQuantity] = ISNULL(CAST(Chk.FuelGradeSalesVolume as decimal(18,6)), 0)
		--, [dblAmount] = ISNULL(CAST(Chk.FuelGradeSalesAmount as decimal(18,6)),0)
		--from #tempCheckoutInsert Chk
		--JOIN dbo.tblICItemLocation IL ON RIGHT(Chk.FuelGradeID, 3) COLLATE Latin1_General_CI_AS = CASE WHEN ISNULL(IL.strPassportFuelId1, '') <> '' THEN IL.strPassportFuelId1
		--																					WHEN ISNULL(IL.strPassportFuelId2, '') <> '' THEN IL.strPassportFuelId2
		--																					WHEN ISNULL(IL.strPassportFuelId3, '') <> '' THEN IL.strPassportFuelId3
		--																				END
		--JOIN dbo.tblICItem I ON I.intItemId = IL.intItemId
		--JOIN dbo.tblICItemUOM UOM ON UOM.intItemId = I.intItemId
		--JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		--JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		--WHERE intCheckoutId = @intCheckoutId AND intPumpCardCouponId = UOM.intItemUOMId

	END

	SET @intCountRows = 1
	SET @strStatusMsg = 'Success'

	End Try

	Begin Catch
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END