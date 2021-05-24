CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMSM]
	@intCheckoutId INT,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN

	--SET NOCOUNT ON
    SET XACT_ABORT ON
       
	   BEGIN TRY
              
				BEGIN TRANSACTION


				DECLARE @intStoreId INT
					  , @intCustomerChargeMopId INT
					  , @intCashTransctionMopId INT

				SELECT @intStoreId			  = ch.intStoreId
					 , @intCustomerChargeMopId = st.intCustomerChargeMopId
					 , @intCashTransctionMopId = st.intCashTransctionMopId
				FROM dbo.tblSTCheckoutHeader ch
				INNER JOIN dbo.tblSTStore st
					ON ch.intStoreId = st.intStoreId
				WHERE ch.intCheckoutId = @intCheckoutId

				-- ==================================================================================================================  
				-- [START] Validate if MSM xml file matches the Mapping on i21 
				-- ================================================================================================================== 
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
								, 'Passport MSM XML file did not match the layout mapping'
								, ''
								, ''
								, @intCheckoutId
								, 1
							)

							SET @intCountRows = 0
							SET @strStatusMsg = 'Passport MSM XML file did not match the layout mapping'

							GOTO ExitWithCommit
					END
				-- ================================================================================================================== 
				-- [END] Validate if MSM xml file matches the Mapping on i21   
				-- ==================================================================================================================



				-- ================================================================================================================== 
				-- [START] Get Error logs. Check Register XML that is not configured in i21
				-- Compare <MiscellaneousSummarySubCodeModifier> tag of (RegisterXML) and (Store -> Store -> Payment Option(Tab) -> 'Register Mop'(strRegisterMopId))
				-- ------------------------------------------------------------------------------------------------------------------ 
				IF(@intCustomerChargeMopId IS NULL AND @intCashTransctionMopId IS NULL)
					BEGIN
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
							, 'No Matching Register MOP in Payment Options' as strErrorMessage
							, 'MiscellaneousSummarySubCodeModifier' as strRegisterTag
							, ISNULL(Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') AS strRegisterTagValue
							, @intCheckoutId
							, 1
						FROM #tempCheckoutInsert Chk
						WHERE ISNULL(Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') NOT IN
						(
							SELECT DISTINCT 
								tbl.strXmlRegisterMiscellaneousSummarySubCodeModifier
							FROM
							(
								SELECT DISTINCT
									Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier AS strXmlRegisterMiscellaneousSummarySubCodeModifier
								FROM #tempCheckoutInsert Chk
								JOIN tblSTPaymentOption PO 
									ON ISNULL(Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
								JOIN tblSTStore Store 
									ON Store.intStoreId = PO.intStoreId
								JOIN tblSTCheckoutPaymentOptions CPO 
									ON CPO.intPaymentOptionId = PO.intPaymentOptionId
								WHERE Store.intStoreId = @intStoreId
								AND Chk.MiscellaneousSummaryCodesMiscellaneousSummaryCode = 'sales' 
								AND Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCode = 'MOP'
								AND ISNULL(Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') != ''
							) AS tbl
						)
						AND Chk.MiscellaneousSummaryCodesMiscellaneousSummaryCode = 'sales' 
						AND Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCode = 'MOP'
						AND ISNULL(Chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') != ''
					END	
				-- ------------------------------------------------------------------------------------------------------------------  
				-- [END] Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================


				-- ======================================================================================================================
				-- [START] - Create list of excluded MOP Id
				-- ======================================================================================================================
				DECLARE @tempExcludedMOPid TABLE
				(
					intPaymentOptionId INT
				)

				INSERT INTO @tempExcludedMOPid
				(
					intPaymentOptionId
				)
				SELECT 
					stpo.intPaymentOptionId
				FROM tblSTStore st
				INNER JOIN tblSTPaymentOption stpo
					ON st.intStoreId = stpo.intStoreId
					AND stpo.intPaymentOptionId IN (st.intCashTransctionMopId, st.intCustomerChargeMopId)
				WHERE st.intStoreId = @intStoreId
				-- ======================================================================================================================
				-- [END] - Create list of excluded MOP Id
				-- ======================================================================================================================
			


				-- ======================================================================================================================
				-- [START] - DELETE Payment Option that is not included
				-- ======================================================================================================================
				DELETE FROM dbo.tblSTCheckoutPaymentOptions
				WHERE intCheckoutId = @intCheckoutId
					AND intPaymentOptionId IN (SELECT DISTINCT intPaymentOptionId FROM @tempExcludedMOPid)
				-- ======================================================================================================================
				-- [END] - DELETE Payment Option that is not included
				-- ======================================================================================================================
              
      
				----Update tblSTCheckoutPaymentOptions
				Update dbo.tblSTCheckoutPaymentOptions
				SET dblRegisterAmount = ISNULL(chk.MSMSalesTotalsMiscellaneousSummaryAmount, 0)
                     , intRegisterCount = ISNULL(chk.MSMSalesTotalsMiscellaneousSummaryCount, 0)
                     , dblAmount = ISNULL(chk.MSMSalesTotalsMiscellaneousSummaryAmount, 0)
				FROM #tempCheckoutInsert chk
				INNER JOIN tblSTPaymentOption PO 
					ON ISNULL(chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
					-- ON PO.strRegisterMop COLLATE DATABASE_DEFAULT = ISNULL(chk.MiscellaneousSummarySubCodeModifier, '')
				INNER JOIN tblSTStore Store 
					ON Store.intStoreId = PO.intStoreId
				INNER JOIN tblSTCheckoutPaymentOptions CPO 
					ON CPO.intPaymentOptionId = PO.intPaymentOptionId
				WHERE Store.intStoreId = @intStoreId
					AND chk.MiscellaneousSummaryCodesMiscellaneousSummaryCode = 'sales' 
					AND chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCode = 'MOP'
					AND intCheckoutId = @intCheckoutId
					AND (
							(
									(EXISTS((SELECT TOP 1 1 FROM @tempExcludedMOPid)))
									AND
									(
										PO.intPaymentOptionId NOT IN (SELECT DISTINCT intPaymentOptionId FROM @tempExcludedMOPid)
									)
									OR
									(NOT EXISTS((SELECT TOP 1 1 FROM @tempExcludedMOPid)))
									AND
									(
										1=1
									)
							)
						)

			   -------------------------------------------------------------------------------------------------------------
			   ---------------------------------------- CUSTOMER COUNT -----------------------------------------------------
			   -------------------------------------------------------------------------------------------------------------
			   --UPDATE dbo.tblSTCheckoutHeader
			   --SET dblCustomerCount = (
						--				   SELECT SUM(CAST(ISNULL(MSMSalesTotalsMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6))) 
						--				   FROM #tempCheckoutInsert
						--				   WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'totalizer' 
						--				   AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'sales'
						--				   AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') = 'sales'
						--				 )
			   --WHERE intCheckoutId = @intCheckoutId

			   UPDATE dbo.tblSTCheckoutHeader
			   SET dblCustomerCount = (
										   SELECT SUM(CAST(ISNULL(intRegisterCount, 0) AS DECIMAL(18, 6))) 
										   FROM tblSTCheckoutPaymentOptions
										   WHERE intCheckoutId  = @intCheckoutId
										 )
			   WHERE intCheckoutId = @intCheckoutId
			   -------------------------------------------------------------------------------------------------------------
			   -------------------------------------- END CUSTOMER COUNT ---------------------------------------------------
               -------------------------------------------------------------------------------------------------------------



			  -------------------------------------------------------------------------------------------------------------
			  ---------------------------------------- TOTAL TAX ----------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------
			  UPDATE dbo.tblSTCheckoutHeader 
			  SET dblTotalTax = (
									SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
									FROM #tempCheckoutInsert 
									WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '') = 'totalizer' 
									AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'tax' 
									AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') = 'taxColl'
								)  
			  WHERE intCheckoutId = @intCheckoutId
			  -------------------------------------------------------------------------------------------------------------
			  ---------------------------------------- END TOTAL TAX ------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------



			  -------------------------------------------------------------------------------------------------------------
			  ------------------------------------------ NO SALES ---------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------
			  UPDATE dbo.tblSTCheckoutHeader
			  SET dblTotalNoSalesCount = (
											SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
											FROM #tempCheckoutInsert 
											WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'statistics' 
											AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'noSales'
										 ) 
			  WHERE intCheckoutId = @intCheckoutId
			  -------------------------------------------------------------------------------------------------------------
			  ---------------------------------------- END NO SALES -------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------



			  -------------------------------------------------------------------------------------------------------------
			  ---------------------------------------- FUEL ADJUSTMENTS ---------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------
			  UPDATE dbo.tblSTCheckoutHeader
			  SET dblFuelAdjustmentCount = (
											 SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
											 FROM #tempCheckoutInsert 
											 WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'statistics' 
											 AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'driveOffs'
										   ) 
			  WHERE intCheckoutId = @intCheckoutId
      
			  UPDATE dbo.tblSTCheckoutHeader
			  SET dblFuelAdjustmentAmount = (
											  SELECT SUM(CAST(ISNULL(MSMSalesTotalsMiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
											  FROM #tempCheckoutInsert 
											  WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'statistics' 
											  AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'driveOffs'
											)
			  WHERE intCheckoutId = @intCheckoutId
			  -------------------------------------------------------------------------------------------------------------
			  --------------------------------------- END FUEL ADJUSTMENTS ------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------



			  -------------------------------------------------------------------------------------------------------------
			  ------------------------------------------- REFUND ----------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------
			  UPDATE dbo.tblSTCheckoutHeader
			  SET dblTotalRefundCount = (
											SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryCount AS DECIMAL(18,6)))
											FROM #tempCheckoutInsert 
											WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '') = 'refunds' 
											AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') ='total'
										) 
			  WHERE intCheckoutId = @intCheckoutId
		   
			  UPDATE dbo.tblSTCheckoutHeader
			  SET dblTotalRefundAmount = (
										   SELECT SUM(CAST(ISNULL(MSMSalesTotalsMiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
										   FROM #tempCheckoutInsert 
										   WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '') = 'refunds' 
										   AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') ='total'
										 )
			  WHERE intCheckoutId = @intCheckoutId
			  -------------------------------------------------------------------------------------------------------------
			  ------------------------------------------ END REFUND -------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------



			  -------------------------------------------------------------------------------------------------------------
			  ------------------------------------------ PAID OUTS --------------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------
			  UPDATE dbo.tblSTCheckoutHeader
			  SET dblTotalPaidOuts = (
										SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryAmount as decimal(18,6))) 
										FROM #tempCheckoutInsert 
										WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '') = 'payouts' 
										AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') ='total'
									 ) 
			  WHERE intCheckoutId = @intCheckoutId
			  -------------------------------------------------------------------------------------------------------------
			  ----------------------------------------- END PAID OUTS -----------------------------------------------------
			  -------------------------------------------------------------------------------------------------------------
				
			  



			  -------------------------------------------------------------------------------------------------------------
			  -- [START] - METRICS TAB 
			  -------------------------------------------------------------------------------------------------------------
			  BEGIN
					-- intRegisterImportFieldId
					-- 1 = Department Item Sold
					-- 2 = Fuel Customer Count
					-- 3 = Inside Customer Count
					-- 4 = Customer Count
					-- 5 = Manual
					-- 6 = No Sales
					 
					DECLARE @intCustomerCount	INT = 4
					       ,@intNoSales			INT = 6

					-- NO SALES COUNT METRIC
					IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutMetrics WHERE intCheckoutId = @intCheckoutId AND intRegisterImportFieldId = @intNoSales)
						BEGIN
							UPDATE chkMet
								SET chkMet.dblAmount = (		
														-- SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryAmount AS DECIMAL(18, 6)))										
														SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
														FROM #tempCheckoutInsert 
														WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'statistics' 
															AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'noSales'									 
												       )
							FROM tblSTCheckoutMetrics chkMet
							WHERE chkMet.intCheckoutId = @intCheckoutId 
								AND chkMet.intRegisterImportFieldId = @intNoSales
						END

					-- CUSTOMER COUNT METRIC
					IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutMetrics WHERE intCheckoutId = @intCheckoutId AND intRegisterImportFieldId = @intCustomerCount)
						BEGIN
							UPDATE chkMet
								SET chkMet.dblAmount = (		
														-- SELECT SUM(CAST(MSMSalesTotalsMiscellaneousSummaryAmount AS DECIMAL(18, 6))) 
														--SELECT SUM(CAST(ISNULL(MSMSalesTotalsMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6))) 
														--FROM #tempCheckoutInsert
														--WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'totalizer' 
														--	AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'sales'
														--	AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') = 'sales'	
															
														SELECT SUM(CAST(ISNULL(intRegisterCount, 0) AS DECIMAL(18, 6))) 
														   FROM tblSTCheckoutPaymentOptions
														   WHERE intCheckoutId  = @intCheckoutId
												       )
							FROM tblSTCheckoutMetrics chkMet
							WHERE chkMet.intCheckoutId = @intCheckoutId 
								AND chkMet.intRegisterImportFieldId = @intCustomerCount
						END
			  END
			  -------------------------------------------------------------------------------------------------------------
			  -- [END] - METRICS TAB 
			  -------------------------------------------------------------------------------------------------------------






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
