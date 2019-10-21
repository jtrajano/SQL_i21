﻿CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderFPHose]
	@intCheckoutId Int,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows int OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId Int
		Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

		BEGIN TRANSACTION

		-- ==================================================================================================================  
		-- Start Validate if FPHose xml file matches the Mapping from i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM #tempCheckoutInsert)
			BEGIN
					-- Add to error logging
					INSERT INTO tblSTCheckoutErrorLogs 
					(
						strErrorType
						, strErrorMessage 
						, strRegisterTag
						, strRegisterTagValue
						, intCheckoutId
						, intConcurrencyId
					)
					VALUES
					(
						'XML LAYOUT MAPPING'
						, 'Commander FPHose XML file did not match the layout mapping'
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					SET @intCountRows = 0
					SET @strStatusMsg = 'Commander FPHose XML file did not match the layout mapping'

					-- ROLLBACK
					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if FPHose xml file matches the Mapping from i21   
		-- ==================================================================================================================  
		
		




		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <fuelProdBaseNAXMLFuelGradeID> tag of (RegisterXML) and (Inventory->Item->Item Location->strPassportFuelId1, strPassportFuelId2 or strPassportFueldId3)
		-- ------------------------------------------------------------------------------------------------------------------ 
		INSERT INTO tblSTCheckoutErrorLogs 
		(
			strErrorType
			, strErrorMessage 
			, strRegisterTag
			, strRegisterTagValue
			, intCheckoutId
			, intConcurrencyId
		)
		SELECT DISTINCT
			'NO MATCHING TAG' as strErrorType
			, 'No Matching Fuel Grade in Inventory' as strErrorMessage
			, 'NAXMLFuelGradeID' as strRegisterTag
			, ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM #tempCheckoutInsert Chk
		WHERE ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterFuelGradeID
			FROM
			(
				SELECT DISTINCT
					Chk.fuelProdBaseNAXMLFuelGradeID AS strXmlRegisterFuelGradeID
				FROM #tempCheckoutInsert Chk
				JOIN dbo.tblICItemLocation IL 
					ON ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, ''))
				JOIN dbo.tblICItem I 
					ON I.intItemId = IL.intItemId
				JOIN dbo.tblICItemUOM UOM 
					ON UOM.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
				AND ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') != ''


		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================


		--Update values that are '' empty
		Update #tempCheckoutInsert
		Set fuelInfovolume = 1
		WHERE fuelInfovolume IS NULL OR fuelInfovolume = '' OR fuelInfovolume = '0'

		Select * FROM #tempCheckoutInsert

		-- Company Currency Decimal
		DECLARE @intCompanyCurrencyDecimal INT
		SET @intCompanyCurrencyDecimal = 0
		SELECT @intCompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

		DECLARE @SQL NVARCHAR(MAX) = ''



		IF NOT EXISTS (SELECT COUNT(intCheckoutId) FROM dbo.tblSTCheckoutPumpTotals Where intCheckoutId = @intCheckoutId)
			BEGIN

				INSERT INTO dbo.tblSTCheckoutPumpTotals(
					 [intCheckoutId]
					 , [intPumpCardCouponId]
					 , [intCategoryId]
					 , [strDescription]
					 , [dblPrice]
					 , [dblQuantity]
					 , [dblAmount]
					 , [intConcurrencyId]
				)
				 SELECT 
					  [intCheckoutId]			    = @intCheckoutId
					, [intPumpCardCouponId]			= UOM.intItemUOMId
					, [intCategoryId]			    = I.intCategoryId
					, [strDescription]				= I.strDescription
					, [dblPrice]					= CAST((ISNULL(CAST(Chk.fuelInfoamount as decimal(18,6)),0) / ISNULL(CAST(Chk.fuelInfovolume as decimal(18,6)),1)) AS DECIMAL(18,6))
					, [dblQuantity]					= ISNULL(CAST(Chk.fuelInfovolume as decimal(18,6)), 0)
					, [dblAmount]					= CAST(((CAST((ISNULL(CAST(Chk.fuelInfoamount as decimal(18,6)),0) / ISNULL(CAST(Chk.fuelInfovolume as decimal(18,6)),1)) AS DECIMAL(18,6))) * (ISNULL(CAST(Chk.fuelInfovolume as decimal(18,6)), 0))) AS DECIMAL(18,6))
					, [intConcurrencyId]			= 0
				 FROM #tempCheckoutInsert Chk
				 JOIN dbo.tblICItemLocation IL 
					ON ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, ''))
					AND Chk.fuelInfoamount <> '0'
				 --JOIN dbo.tblICItemLocation IL ON ISNULL(Chk.FuelGradeID, '') COLLATE Latin1_General_CI_AS = CASE 
					--																							WHEN ISNULL(IL.strPassportFuelId1, '') <> '' 
					--																								THEN IL.strPassportFuelId1
					--																							WHEN ISNULL(IL.strPassportFuelId2, '') <> '' 
					--																								THEN IL.strPassportFuelId2
					--																							WHEN ISNULL(IL.strPassportFuelId3, '') <> '' 
					--																								THEN IL.strPassportFuelId3
					--																						 END
				 JOIN dbo.tblICItem I 
					ON I.intItemId = IL.intItemId
				 JOIN dbo.tblICItemUOM UOM 
					ON UOM.intItemId = I.intItemId
				 JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				 JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				 WHERE S.intStoreId = @intStoreId
			END
		ELSE
			BEGIN


					--SELECT ISNULL(Chk.FuelGradeSalesAmount, 0), ISNULL(Chk.FuelGradeSalesVolume, 0), ISNULL(Chk.FuelGradeSalesAmount, 0), CPT.* 
					UPDATE CPT
					SET CPT.[dblPrice] = ISNULL(NULLIF(CAST(Chk.fuelInfoamount AS DECIMAL(18,6)), 0) / NULLIF(CAST(Chk.fuelInfovolume AS DECIMAL(18,6)),0),0)
						, CPT.[dblQuantity] = CAST(ISNULL(Chk.fuelInfovolume, 0) AS DECIMAL(18,6))
						, CPT.[dblAmount] = (ISNULL(NULLIF(CAST(Chk.fuelInfoamount AS DECIMAL(18,6)), 0) / NULLIF(CAST(Chk.fuelInfovolume AS DECIMAL(18,6)),0),0)) * CAST(ISNULL(Chk.fuelInfovolume, 0) AS DECIMAL(18,6))
					FROM dbo.tblSTCheckoutPumpTotals CPT
					INNER JOIN tblSTCheckoutHeader CH
						ON CPT.intCheckoutId = CH.intCheckoutId
					INNER JOIN tblSTStore ST
						ON CH.intStoreId = ST.intStoreId
					INNER JOIN tblICItemUOM UOM
						ON CPT.intPumpCardCouponId = UOM.intItemUOMId
					INNER JOIN tblICItem Item
						ON UOM.intItemId = Item.intItemId
					INNER JOIN dbo.tblICItemLocation IL 
						ON Item.intItemId = IL.intItemId
						AND ST.intCompanyLocationId = IL.intLocationId
					INNER JOIN #tempCheckoutInsert Chk
						ON ISNULL(Chk.fuelProdBaseNAXMLFuelGradeID, '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, ''))
						AND Chk.fuelInfoamount <> '0'
					WHERE CPT.intCheckoutId = @intCheckoutId
			END



		SET @intCountRows = 1
		SET @strStatusMsg = 'Success'

		-- COMMIT
		GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()

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