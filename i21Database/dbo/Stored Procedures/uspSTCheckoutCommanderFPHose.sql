CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderFPHose]
	@intCheckoutId							INT,
	@UDT_TranFPHose							StagingCommanderFPHose		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId Int
		Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

		DECLARE @UDT_TranFPHose2  AS StagingCommanderFPHose

		INSERT INTO @UDT_TranFPHose2
		(
			 [intRowCount] 								
			,[strFuelProdBaseNAXMLFuelGradeID] 			
			,[dblFuelInfoAmount]                         
			,[dblFuelInfoCount]                          
			,[dblFuelInfoVolume]                         
		)
		SELECT 
			[intRowCount] 								
			,[strFuelProdBaseNAXMLFuelGradeID] 			
			,[dblFuelInfoAmount]                         
			,[dblFuelInfoCount]                          
			,[dblFuelInfoVolume]     
		FROM 
		@UDT_TranFPHose

		BEGIN TRANSACTION

		-- ==================================================================================================================  
		-- Start Validate if FPHose xml file matches the Mapping from i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_TranFPHose2)
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
					SET @strMessage = 'Commander FPHose XML file did not match the layout mapping'
					SET @ysnSuccess = 0

					-- ROLLBACK
					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if FPHose xml file matches the Mapping from i21   
		-- ==================================================================================================================  
		
		




		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <strFuelProdBaseNAXMLFuelGradeID> tag of (RegisterXML) and (Store->Pump Items->->strRegisterFuelId1 ir strRegisterFuelId2)
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
			, ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM @UDT_TranFPHose2 Chk
		WHERE ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterFuelGradeID
			FROM
			(
				SELECT DISTINCT
					Chk.strFuelProdBaseNAXMLFuelGradeID AS strXmlRegisterFuelGradeID
				FROM @UDT_TranFPHose2 Chk
				JOIN dbo.tblSTPumpItem SPI 
					ON ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, ''))
				JOIN dbo.tblICItemUOM UOM 
					ON UOM.intItemUOMId = SPI.intItemUOMId
				JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				JOIN dbo.tblSTStore S 
					ON S.intStoreId = SPI.intStoreId
				WHERE S.intStoreId = @intStoreId
				AND ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') != ''


		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================

		
		--Select * FROM @UDT_TranFPHose2


		--Update values that are '' empty
		--Handled in API side

		--Update @UDT_TranFPHose2
		--Set dblFuelInfoVolume = 1
		--WHERE dblFuelInfoVolume IS NULL OR dblFuelInfoVolume = '' OR dblFuelInfoVolume = '0'



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
					, [dblPrice]					= CAST((ISNULL(CAST(Chk.dblFuelInfoAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.dblFuelInfoVolume as decimal(18,6)),1)) AS DECIMAL(18,6))
					, [dblQuantity]					= ISNULL(CAST(Chk.dblFuelInfoVolume as decimal(18,6)), 0)
					, [dblAmount]					= CAST(((CAST((ISNULL(CAST(Chk.dblFuelInfoAmount as decimal(18,6)),0) / ISNULL(CAST(Chk.dblFuelInfoVolume as decimal(18,6)),1)) AS DECIMAL(18,6))) * (ISNULL(CAST(Chk.dblFuelInfoVolume as decimal(18,6)), 0))) AS DECIMAL(18,6))
					, [intConcurrencyId]			= 0
				 FROM @UDT_TranFPHose2 Chk
				 JOIN dbo.tblSTPumpItem SPI 
					ON ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, '')) AND Chk.dblFuelInfoAmount <> '0'
				 JOIN dbo.tblICItemUOM UOM 
					ON UOM.intItemUOMId = SPI.intItemUOMId
				 JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				 JOIN dbo.tblSTStore S 
					ON S.intStoreId = SPI.intStoreId
				 WHERE S.intStoreId = @intStoreId
			END
		ELSE
			BEGIN
					UPDATE CPT
					SET CPT.[dblPrice] = ISNULL(NULLIF(CAST(Chk.dblFuelInfoAmount AS DECIMAL(18,6)), 0) / NULLIF(CAST(Chk.dblFuelInfoVolume AS DECIMAL(18,6)),0),0)
						, CPT.[dblQuantity] = CAST(ISNULL(Chk.dblFuelInfoVolume, 0) AS DECIMAL(18,6))
						, CPT.[dblAmount] = (ISNULL(NULLIF(CAST(Chk.dblFuelInfoAmount AS DECIMAL(18,6)), 0) / NULLIF(CAST(Chk.dblFuelInfoVolume AS DECIMAL(18,6)),0),0)) * CAST(ISNULL(Chk.dblFuelInfoVolume, 0) AS DECIMAL(18,6))
					FROM dbo.tblSTCheckoutPumpTotals CPT
					INNER JOIN tblSTCheckoutHeader CH
						ON CPT.intCheckoutId = CH.intCheckoutId
					INNER JOIN tblSTStore ST
						ON CH.intStoreId = ST.intStoreId
					INNER JOIN tblICItemUOM UOM
						ON CPT.intPumpCardCouponId = UOM.intItemUOMId
					INNER JOIN dbo.tblSTPumpItem SPI 
						ON ST.intStoreId = SPI.intStoreId AND
							UOM.intItemUOMId = SPI.intItemUOMId
					INNER JOIN @UDT_TranFPHose2 Chk
						ON ISNULL(Chk.strFuelProdBaseNAXMLFuelGradeID, '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, ''))
						AND Chk.dblFuelInfoAmount <> '0'
					WHERE CPT.intCheckoutId = @intCheckoutId
			END

			
			UPDATE
				dept
			SET
				dept.dblTotalSalesAmountComputed = pump.dblAmount,
				dept.intItemsSold = pump.dblQuantity
			FROM
				tblSTCheckoutDepartmetTotals AS dept
				INNER JOIN (
					SELECT 
						intCategoryId,
						SUM(dblQuantity) AS dblQuantity, 
						SUM(dblAmount) AS dblAmount
					FROM tblSTCheckoutPumpTotals
					WHERE intCheckoutId = @intCheckoutId
					GROUP BY intCategoryId
				) AS pump
					ON pump.intCategoryId = dept.intCategoryId
			WHERE
				dept.intCheckoutId = @intCheckoutId

		SET @intCountRows = 1
		SET @strMessage = 'Success'
		SET @ysnSuccess = 1

		-- COMMIT
		GOTO ExitWithCommit
	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
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