CREATE PROCEDURE [dbo].[uspSTCheckoutUpdatePumpTotals]
	@intCheckoutId							INT,
	@ysnFromEdit							BIT,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT
AS
BEGIN
	--SET NOCOUNT ON
    SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @intStoreId INT = 0
		DECLARE @ysnConsMeterReadingsForDollars BIT = 0
		DECLARE @ysnConsDepartmentTotals BIT = 0
		DECLARE @dblMeterReadings DECIMAL (18,6) = 0
		DECLARE @dblMeterReadingsCH DECIMAL (18,6) = 0
		DECLARE @dblAggregateAmount DECIMAL (18,6) = 0
		DECLARE @dblDepartmentTotals DECIMAL (18,6) = 0
		DECLARE @dblTotalTierProduct DECIMAL (18,6) = 0

		SELECT			@intStoreId = intStoreId
		FROM			tblSTCheckoutHeader
		WHERE			intCheckoutId = @intCheckoutId

		SELECT			@ysnConsMeterReadingsForDollars = ysnConsMeterReadingsForDollars
		FROM			tblSTStore
		WHERE			intStoreId = @intStoreId
		
		IF (@ysnConsMeterReadingsForDollars = 1 OR @ysnFromEdit = 1)
		BEGIN
			DELETE FROM		tblSTCheckoutPumpTotals
			WHERE			intCheckoutId = @intCheckoutId AND 
							intPumpCardCouponId NOT IN (SELECT intItemUOMId FROM tblSTCheckoutFuelSalesByGradeAndPricePoint WHERE intCheckoutId = @intCheckoutId)
							
			UPDATE			CPT
			SET				CPT.dblQuantity = Chk.dblSumGallonsSold, 
							CPT.dblAmount = Chk.dblSumDollarsSold, 
							CPT.dblPrice = CASE WHEN ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1) = 0
											THEN 0
											ELSE CAST((ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
											END
			FROM			dbo.tblSTCheckoutPumpTotals CPT
			INNER JOIN		(	SELECT		intCheckoutId, 
											intItemUOMId, 
											SUM(dblDollarsSold - ISNULL(dblPumpTestDollars,0)) as dblSumDollarsSold, 
											SUM(dblGallonsSold - ISNULL(dblPumpTestGallons,0)) as dblSumGallonsSold 
								FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint
								WHERE		intCheckoutId = @intCheckoutId
								GROUP BY	intCheckoutId, 
											intItemUOMId) Chk
			ON				CPT.intPumpCardCouponId = Chk.intItemUOMId AND
							CPT.intCheckoutId = Chk.intCheckoutId
			WHERE			CPT.intCheckoutId = @intCheckoutId

			INSERT INTO dbo.tblSTCheckoutPumpTotals(intCheckoutId, intPumpCardCouponId, intCategoryId, strDescription, dblPrice , dblQuantity, dblAmount, intConcurrencyId)
			SELECT		@intCheckoutId , Chk.intItemUOMId , I.intCategoryId , I.strDescription,  
						CASE WHEN ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1) = 0
						THEN 0
						ELSE CAST((ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
						END, 
						ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)), 0), 
						ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0),  
						0
			FROM		(	SELECT		intCheckoutId, 
										intItemUOMId, 
										SUM(dblDollarsSold - ISNULL(dblPumpTestDollars,0)) as dblSumDollarsSold, 
										SUM(dblGallonsSold - ISNULL(dblPumpTestGallons,0)) as dblSumGallonsSold 
							FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint
							WHERE		intCheckoutId = @intCheckoutId AND 
										intItemUOMId NOT IN (	SELECT		intPumpCardCouponId 
																FROM		tblSTCheckoutPumpTotals 
																WHERE		intCheckoutId = @intCheckoutId)
							GROUP BY intCheckoutId, intItemUOMId) Chk
			JOIN		tblICItemUOM UOM
			ON			Chk.intItemUOMId = UOM.intItemUOMId
			JOIN		tblICItem I
			ON			I.intItemId = UOM.intItemId

			IF @ysnFromEdit = 0
			BEGIN
				UPDATE		tblSTCheckoutHeader
				SET			dblEditableAggregateMeterReadingsForDollars = (	SELECT		ISNULL(SUM(dblDollarsSold),0)
																			FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint 
																			WHERE		intCheckoutId = @intCheckoutId)
				WHERE intCheckoutId = @intCheckoutId
			END
		END
		ELSE
		BEGIN
			SELECT @dblMeterReadingsCH = dblEditableAggregateMeterReadingsForDollars FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId 
			SELECT @dblAggregateAmount = SUM(ISNULL(dblDollarsSold,0)) FROM tblSTCheckoutFuelSalesByGradeAndPricePoint WHERE intCheckoutId = @intCheckoutId
			SELECT @dblDepartmentTotals = dbo.fnSTGetDepartmentTotalsForFuel(@intCheckoutId) 
			SELECT @dblTotalTierProduct = (SUM(tp.dblAmount)) FROM tblSTCheckoutTierProducts tp WHERE intCheckoutId = @intCheckoutId
			 
			IF (@dblDepartmentTotals != @dblTotalTierProduct)			
			BEGIN			
				SET @dblMeterReadings = (CASE WHEN @dblMeterReadingsCH = 0 THEN @dblAggregateAmount ELSE @dblAggregateAmount END)
				IF (@dblMeterReadings = @dblDepartmentTotals)
				BEGIN
					DELETE FROM		tblSTCheckoutPumpTotals
					WHERE			intCheckoutId = @intCheckoutId AND 
									intPumpCardCouponId NOT IN (SELECT intItemUOMId FROM tblSTCheckoutFuelSalesByGradeAndPricePoint WHERE intCheckoutId = @intCheckoutId)
							
					UPDATE			CPT
					SET				CPT.dblQuantity = Chk.dblSumGallonsSold, 
									CPT.dblAmount = Chk.dblSumDollarsSold, 
									CPT.dblPrice = CASE WHEN ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1) = 0
													THEN 0
													ELSE CAST((ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
													END
					FROM			dbo.tblSTCheckoutPumpTotals CPT
					INNER JOIN		(	SELECT		intCheckoutId, 
													intItemUOMId, 
													SUM(dblDollarsSold - ISNULL(dblPumpTestDollars,0)) as dblSumDollarsSold, 
													SUM(dblGallonsSold - ISNULL(dblPumpTestGallons,0)) as dblSumGallonsSold 
										FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint
										WHERE		intCheckoutId = @intCheckoutId
										GROUP BY	intCheckoutId, 
													intItemUOMId) Chk
					ON				CPT.intPumpCardCouponId = Chk.intItemUOMId AND
									CPT.intCheckoutId = Chk.intCheckoutId
					WHERE			CPT.intCheckoutId = @intCheckoutId

					INSERT INTO dbo.tblSTCheckoutPumpTotals(intCheckoutId, intPumpCardCouponId, intCategoryId, strDescription, dblPrice , dblQuantity, dblAmount, intConcurrencyId)
					SELECT		@intCheckoutId , Chk.intItemUOMId , I.intCategoryId , I.strDescription,  
								CASE WHEN ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1) = 0
								THEN 0
								ELSE CAST((ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0) / ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)),1)) AS DECIMAL(18,6))
								END, 
								ISNULL(CAST(Chk.dblSumGallonsSold as decimal(18,6)), 0), 
								ISNULL(CAST(Chk.dblSumDollarsSold as decimal(18,6)),0),  
								0
					FROM		(	SELECT		intCheckoutId, 
												intItemUOMId, 
												SUM(dblDollarsSold - ISNULL(dblPumpTestDollars,0)) as dblSumDollarsSold, 
												SUM(dblGallonsSold - ISNULL(dblPumpTestGallons,0)) as dblSumGallonsSold 
									FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint
									WHERE		intCheckoutId = @intCheckoutId AND 
												intItemUOMId NOT IN (	SELECT		intPumpCardCouponId 
																		FROM		tblSTCheckoutPumpTotals 
																		WHERE		intCheckoutId = @intCheckoutId)
									GROUP BY intCheckoutId, intItemUOMId) Chk
					JOIN		tblICItemUOM UOM
					ON			Chk.intItemUOMId = UOM.intItemUOMId
					JOIN		tblICItem I
					ON			I.intItemId = UOM.intItemId

					IF @ysnFromEdit = 0
					BEGIN
						UPDATE		tblSTCheckoutHeader
						SET			dblEditableAggregateMeterReadingsForDollars = (	SELECT		ISNULL(SUM(dblDollarsSold),0)
																					FROM		tblSTCheckoutFuelSalesByGradeAndPricePoint 
																					WHERE		intCheckoutId = @intCheckoutId)
						WHERE intCheckoutId = @intCheckoutId
					END
				END
				ELSE
				BEGIN
					DELETE FROM tblSTCheckoutPumpTotals
					WHERE intCheckoutId = @intCheckoutId

					INSERT INTO tblSTCheckoutPumpTotals (intCheckoutId, intPumpCardCouponId, intCategoryId, strDescription, dblPrice , dblQuantity, dblAmount, intConcurrencyId)
					SELECT	@intCheckoutId,
							UOM.intItemUOMId,
							I.intCategoryId,
							I.strDescription,
							CASE WHEN ISNULL(CAST(a.dblVolume as decimal(18,6)),1) = 0
								THEN 0
								ELSE CAST((ISNULL(CAST(a.dblAmount as decimal(18,6)),0) / ISNULL(CAST(a.dblVolume as decimal(18,6)),1)) AS DECIMAL(18,6))
								END, 
							ISNULL(CAST(a.dblVolume as decimal(18,6)), 0), 
							ISNULL(CAST(a.dblAmount as decimal(18,6)),0), 
							1
					FROM	tblSTCheckoutTierProducts a
					JOIN dbo.tblSTPumpItem SPI 
						ON ISNULL(CAST(a.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, ''))
					JOIN dbo.tblICItemUOM UOM 
						ON UOM.intItemUOMId = SPI.intItemUOMId
					JOIN dbo.tblICItem I
						ON I.intItemId = UOM.intItemId
					JOIN dbo.tblSTStore S 
						ON S.intStoreId = SPI.intStoreId
					WHERE S.intStoreId = @intStoreId AND 
						UOM.intItemUOMId IN (SELECT intItemUOMId FROM tblSTPumpItem WHERE intStoreId = @intStoreId) AND
						a.intCheckoutId = @intCheckoutId
				END
			END	
			ELSE
			BEGIN
				DELETE FROM tblSTCheckoutPumpTotals
					WHERE intCheckoutId = @intCheckoutId

					INSERT INTO tblSTCheckoutPumpTotals (intCheckoutId, intPumpCardCouponId, intCategoryId, strDescription, dblPrice , dblQuantity, dblAmount, intConcurrencyId)
					SELECT	@intCheckoutId,
							UOM.intItemUOMId,
							I.intCategoryId,
							I.strDescription,
							CASE WHEN ISNULL(CAST(a.dblVolume as decimal(18,6)),1) = 0
								THEN 0
								ELSE CAST((ISNULL(CAST(a.dblAmount as decimal(18,6)),0) / ISNULL(CAST(a.dblVolume as decimal(18,6)),1)) AS DECIMAL(18,6))
								END, 
							ISNULL(CAST(a.dblVolume as decimal(18,6)), 0), 
							ISNULL(CAST(a.dblAmount as decimal(18,6)),0), 
							1
					FROM	tblSTCheckoutTierProducts a
					JOIN dbo.tblSTPumpItem SPI 
						ON ISNULL(CAST(a.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, ''))
					JOIN dbo.tblICItemUOM UOM 
						ON UOM.intItemUOMId = SPI.intItemUOMId
					JOIN dbo.tblICItem I
						ON I.intItemId = UOM.intItemId
					JOIN dbo.tblSTStore S 
						ON S.intStoreId = SPI.intStoreId
					WHERE S.intStoreId = @intStoreId AND 
						UOM.intItemUOMId IN (SELECT intItemUOMId FROM tblSTPumpItem WHERE intStoreId = @intStoreId) AND
						a.intCheckoutId = @intCheckoutId
			END		
		END	

		SET @strMessage = 'Success'
		SET @ysnSuccess = 1

		-- COMMIT
		GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
		SET @strMessage = ERROR_MESSAGE()
		SET @ysnSuccess = 0

		-- ROLLBACK
		GOTO ExitWithRollback
	END CATCH
END


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END
		
ExitPost: