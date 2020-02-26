CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderSummary]
	@intCheckoutId							INT,
	@UDT_TransSummary						StagingCommanderSummary		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
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
				-- Start Validate if Summary xml file matches the Mapping on i21 
				-- ------------------------------------------------------------------------------------------------------------------
				IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_TransSummary)
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
								, 'Commander Summary XML file did not match the layout mapping'
								, ''
								, ''
								, @intCheckoutId
								, 1
							)

							SET @intCountRows = 0
							SET @strMessage = 'Commander Summary XML file did not match the layout mapping'
							SET @ysnSuccess = 0
							
							GOTO ExitWithCommit
					END
				-- ------------------------------------------------------------------------------------------------------------------
				-- End Validate if Summary xml file matches the Mapping on i21   
				-- ==================================================================================================================



				-- ================================================================================================================== 
				-- [START] Get Error logs. Check Register XML that is not configured in i21
				-- Compare <mopInfo sysid> tag of (RegisterXML) and (Store -> Store -> Payment Option(Tab) -> 'Register Mop'(strRegisterMopId))
				-- ================================================================================================================== 
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
							, 'mopInfo sysid' as strRegisterTag
							, ISNULL(Chk.strSysid, '') AS strRegisterTagValue
							, @intCheckoutId
							, 1
						FROM @UDT_TransSummary Chk
						WHERE ISNULL(Chk.strSysid, '') NOT IN
						(
							SELECT DISTINCT 
								tbl.strXmlRegisterMiscellaneousSummarySubCodeModifier
							FROM
							(
								SELECT DISTINCT
									Chk.strSysid AS strXmlRegisterMiscellaneousSummarySubCodeModifier
								FROM @UDT_TransSummary Chk
								JOIN tblSTPaymentOption PO 
									ON ISNULL(Chk.strSysid, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
								JOIN tblSTStore Store 
									ON Store.intStoreId = PO.intStoreId
								JOIN tblSTCheckoutPaymentOptions CPO 
									ON CPO.intPaymentOptionId = PO.intPaymentOptionId
								WHERE Store.intStoreId = @intStoreId
									--AND Chk.MiscellaneousSummaryCode = 'sales' 
									--AND Chk.MiscellaneousSummarySubCode = 'MOP'
									AND ISNULL(Chk.strSysid, '') != ''
							) AS tbl
						)
						--AND Chk.MiscellaneousSummaryCode = 'sales' 
						--AND Chk.MiscellaneousSummarySubCode = 'MOP'
						AND ISNULL(Chk.strSysid, '') != ''
					END
				-- ==================================================================================================================  
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
				AND stpo.ysnSkipImport = CAST(0 AS BIT)
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
			UPDATE dbo.tblSTCheckoutPaymentOptions
				SET dblRegisterAmount		= ISNULL(chk.dblMopInfoAmount, 0)
                     , intRegisterCount		= ISNULL(chk.dblMopInfoCount, 0)
                     , dblAmount			= ISNULL(chk.dblMopInfoAmount, 0)
            FROM @UDT_TransSummary chk
            INNER JOIN tblSTPaymentOption PO 
				ON ISNULL(chk.strSysid, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
            INNER JOIN tblSTStore Store 
				ON Store.intStoreId = PO.intStoreId
            INNER JOIN tblSTCheckoutPaymentOptions CPO 
				ON CPO.intPaymentOptionId = PO.intPaymentOptionId
            WHERE Store.intStoreId = @intStoreId
				AND CPO.intCheckoutId = @intCheckoutId
				AND CPO.ysnSkipImport = CAST(0 AS BIT)
				--AND PO.strRegisterMop NOT IN (SELECT DISTINCT strRegisterMop FROM @tempExcludedMOPid)
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
          UPDATE dbo.tblSTCheckoutHeader
          SET dblCustomerCount = (
                                       SELECT TOP 1 CAST(ISNULL(dblSummaryInfoCustomerCount, 0) AS DECIMAL(18, 6))
                                       FROM @UDT_TransSummary
                                 )
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          -------------------------------------- END CUSTOMER COUNT ---------------------------------------------------
          -------------------------------------------------------------------------------------------------------------



		  -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- TOTAL TAX -----------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader 
		  SET dblTotalTax = (
								SELECT TOP 1 CAST(ISNULL(dblSummaryInfoTotalSalesTaxes, 0) AS DECIMAL(18, 6))
                                FROM @UDT_TransSummary
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
										SELECT TOP 1 CAST(ISNULL(dblSummaryInfoCustomerCount, 0) AS DECIMAL(18, 6))
										FROM @UDT_TransSummary
									 ) 
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- END NO SALES -------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------


		  -- No FUEL ADJUSTMENTS on Commander
          ---------------------------------------------------------------------------------------------------------------
          ------------------------------------------ FUEL ADJUSTMENTS ---------------------------------------------------
          ---------------------------------------------------------------------------------------------------------------
          --UPDATE dbo.tblSTCheckoutHeader
          --SET dblFuelAdjustmentCount = (
										-- SELECT SUM(CAST(MiscellaneousSummaryCount AS DECIMAL(18, 6))) 
										-- FROM @UDT_TransSummary 
										-- WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'statistics' 
										-- AND ISNULL(MiscellaneousSummarySubCode, '') = 'driveOffs'
									 --  ) 
          --WHERE intCheckoutId = @intCheckoutId
      
          --UPDATE dbo.tblSTCheckoutHeader
          --SET dblFuelAdjustmentAmount = (
          --                                SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
          --                                FROM @UDT_TransSummary 
										--  WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'statistics' 
										--  AND ISNULL(MiscellaneousSummarySubCode, '') = 'driveOffs'
          --                              )
          --WHERE intCheckoutId = @intCheckoutId
          ---------------------------------------------------------------------------------------------------------------
          ----------------------------------------- END FUEL ADJUSTMENTS ------------------------------------------------
          ---------------------------------------------------------------------------------------------------------------



		  -- No REFUND
         -- -------------------------------------------------------------------------------------------------------------
         -- ------------------------------------------- REFUND ----------------------------------------------------------
         -- -------------------------------------------------------------------------------------------------------------
         -- UPDATE dbo.tblSTCheckoutHeader
         -- SET dblTotalRefundCount = (
									--	SELECT SUM(CAST(MiscellaneousSummaryCount AS DECIMAL(18,6)))
									--	FROM @UDT_TransSummary 
									--	WHERE ISNULL(MiscellaneousSummaryCode, '') = 'refunds' 
									--	AND ISNULL(MiscellaneousSummarySubCode, '') ='total'
									--) 
         -- WHERE intCheckoutId = @intCheckoutId
		   
         -- UPDATE dbo.tblSTCheckoutHeader
         -- SET dblTotalRefundAmount = (
         --                              SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
         --                              FROM @UDT_TransSummary 
									--   WHERE ISNULL(MiscellaneousSummaryCode, '') = 'refunds' 
									--   AND ISNULL(MiscellaneousSummarySubCode, '') ='total'
         --                            )
         -- WHERE intCheckoutId = @intCheckoutId
         -- -------------------------------------------------------------------------------------------------------------
         -- ------------------------------------------ END REFUND -------------------------------------------------------
         -- -------------------------------------------------------------------------------------------------------------



          -------------------------------------------------------------------------------------------------------------
          ------------------------------------------ PAID OUTS --------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalPaidOuts = (
									SELECT TOP 1 CAST(ISNULL(dblSummaryInfoTotalPaymentOut, 0) AS DECIMAL(18, 6))
									FROM @UDT_TransSummary
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
														SELECT TOP 1 CAST(ISNULL(dblSummaryInfoCustomerCount, 0) AS DECIMAL(18, 6))
														FROM @UDT_TransSummary								 
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
														SELECT TOP 1 CAST(ISNULL(dblSummaryInfoCustomerCount, 0) AS DECIMAL(18, 6))
														FROM @UDT_TransSummary									 
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