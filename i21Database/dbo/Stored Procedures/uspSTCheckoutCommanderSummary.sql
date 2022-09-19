﻿CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderSummary]
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
					  , @ysnConsignmentStore BIT = 1

				SELECT @intStoreId			  = ch.intStoreId
					 , @intCustomerChargeMopId = st.intCustomerChargeMopId
					 , @intCashTransctionMopId = st.intCashTransctionMopId
					 , @ysnConsignmentStore = st.ysnConsignmentStore
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
							, ISNULL(Chk.strSysId, '') AS strRegisterTagValue
							, @intCheckoutId
							, 1
						FROM @UDT_TransSummary Chk
						WHERE ISNULL(Chk.strSysId, '') NOT IN
						(
							SELECT DISTINCT 
								tbl.strXmlRegisterMiscellaneousSummarySubCodeModifier
							FROM
							(
								SELECT DISTINCT
									Chk.strSysId AS strXmlRegisterMiscellaneousSummarySubCodeModifier
								FROM @UDT_TransSummary Chk
								JOIN tblSTPaymentOption PO 
									ON ISNULL(Chk.strSysId, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
								JOIN tblSTStore Store 
									ON Store.intStoreId = PO.intStoreId
								JOIN tblSTCheckoutPaymentOptions CPO 
									ON CPO.intPaymentOptionId = PO.intPaymentOptionId
								WHERE Store.intStoreId = @intStoreId
									--AND Chk.MiscellaneousSummaryCode = 'sales' 
									--AND Chk.MiscellaneousSummarySubCode = 'MOP'
									AND ISNULL(Chk.strSysId, '') != ''
							) AS tbl
						)
						--AND Chk.MiscellaneousSummaryCode = 'sales' 
						--AND Chk.MiscellaneousSummarySubCode = 'MOP'
						AND ISNULL(Chk.strSysId, '') != ''
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
			IF @ysnConsignmentStore = 0
			BEGIN
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
			END
			ELSE
			BEGIN
				INSERT INTO @tempExcludedMOPid  
				(  
				intPaymentOptionId  
				)  
				SELECT intPaymentOptionId
				FROM tblSTPaymentOption 
				WHERE intStoreId = @intStoreId
				AND strRegisterMop IS NOT NULL
				AND ISNULL(ysnDepositable,0) = 1
			END
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
				ON ISNULL(chk.strSysId, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
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
          --------------------------------------CONSIGNMENT DATA-------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
		  DECLARE @dblAggregateMeterReadingsForDollars DECIMAL(18, 6)
		  DECLARE @dblSummaryInfoFuelSales DECIMAL(18, 6)
		  
		  SELECT 		TOP 1
						@dblSummaryInfoFuelSales = CAST(ISNULL(dblSummaryInfoFuelSales, 0) AS DECIMAL(18, 6))
		  FROM 			@UDT_TransSummary
		  
          UPDATE dbo.tblSTCheckoutHeader
          SET dblSummaryInfoFuelSales = @dblSummaryInfoFuelSales 
          WHERE intCheckoutId = @intCheckoutId

		  UPDATE dbo.tblSTCheckoutHeader
          SET dblSummaryInfoPopPredispensedAmount = (
									SELECT TOP 1 CAST(ISNULL(dblSummaryInfoPopPredispensedAmount, 0) AS DECIMAL(18, 6))
									FROM @UDT_TransSummary
								 ) 
          WHERE intCheckoutId = @intCheckoutId
		  
		  SET @dblAggregateMeterReadingsForDollars = dbo.fnSTGetAggregateMeterReadingsForDollars(@intCheckoutId)
		  
		  IF (@dblAggregateMeterReadingsForDollars != @dblSummaryInfoFuelSales)
			BEGIN
				INSERT INTO tblSTCheckoutProcessErrorWarning (intCheckoutProcessId, strMessageType, strMessage, intConcurrencyId)
				VALUES (dbo.fnSTGetLatestProcessId(@intStoreId), 'S', 'Aggregate Meter Readings does not Match the Register''s Summary File value', 1)
			END
          -------------------------------------------------------------------------------------------------------------
          ------------------------------------- END CONSIGNMENT DATA --------------------------------------------------
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
		
		-- ======================================================================================================================
		-- [START] - INSERT CASHIER DETAIL 
		-- ======================================================================================================================
			IF @ysnConsignmentStore = 0 -- If not Consignment
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM dbo.tblSTCheckoutCashiers WHERE intCheckoutId = @intCheckoutId)  
					BEGIN  
					 INSERT INTO dbo.tblSTCheckoutCashiers (  
					   [intCheckoutId]  
					  ,[intCashierId]  
					  ,[dblTotalPaymentOption]  
					  ,[intNumberOfVoids]  
					  ,[dblVoidAmount]  
					  ,[intOverrideCount]  
					  ,[intCustomerCount]  
					  ,[dblTotalDeposit]  
					  )  
					 SELECT  
					  @intCheckoutId    
					  , (SELECT TOP 1 intCashierId FROM tblSTCashier WHERE strCashierName = CAST(ISNULL(UDT.strCashier, '') AS NVARCHAR(50)) COLLATE SQL_Latin1_General_CP1_CS_AS)  
					  , CAST(UDT.dblCashierTotalPaymentOption AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierVoidLineNumberOfVoids  AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierVoidLineAmountOfVoids AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierSummaryInfoNumberOfOverrides AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierSummaryInfoNumberOfCustomerCount AS DECIMAL(18,6))  
					  , CAST(UDT.dblTotalDeposit AS DECIMAL(18,6))  
					 FROM @UDT_TransSummary UDT  
					END  
				   ELSE  
					BEGIN  
					 UPDATE dbo.tblSTCheckoutCashiers  
					  SET dblTotalPaymentOption  = ISNULL(UDT.dblCashierTotalPaymentOption, 0)  
					  , intNumberOfVoids  = ISNULL(UDT.dblCashierVoidLineNumberOfVoids, 0)  
					  , dblVoidAmount   = ISNULL(UDT.dblCashierVoidLineAmountOfVoids, 0)  
					  , intOverrideCount   = ISNULL(UDT.dblCashierSummaryInfoNumberOfOverrides, 0)  
					  , intCustomerCount   = ISNULL(UDT.dblCashierSummaryInfoNumberOfCustomerCount, 0)  
					  , dblTotalDeposit         =ISNULL(UDT.dblTotalDeposit , 0)  
					 FROM @UDT_TransSummary UDT  
					 WHERE tblSTCheckoutCashiers.intCheckoutId = @intCheckoutId    
					END  
				END
			  ELSE -- Consignment (filter payment options, exclude MOPs that are not marked as depositable)
				BEGIN
					IF NOT EXISTS (SELECT 1 FROM dbo.tblSTCheckoutCashiers WHERE intCheckoutId = @intCheckoutId)  
					BEGIN  
					 INSERT INTO dbo.tblSTCheckoutCashiers (  
					   [intCheckoutId]  
					  ,[intCashierId]  
					  ,[dblTotalPaymentOption]  
					  ,[intNumberOfVoids]  
					  ,[dblVoidAmount]  
					  ,[intOverrideCount]  
					  ,[intCustomerCount]  
					  ,[dblTotalDeposit]  
					  )  
					 SELECT  
					  @intCheckoutId    
					  , (SELECT TOP 1 intCashierId FROM tblSTCashier WHERE strCashierName = CAST(ISNULL(UDT.strCashier, '') AS NVARCHAR(50)) COLLATE SQL_Latin1_General_CP1_CS_AS)  
					  , CAST(UDT.dblCashierTotalPaymentOption AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierVoidLineNumberOfVoids  AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierVoidLineAmountOfVoids AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierSummaryInfoNumberOfOverrides AS DECIMAL(18,6))  
					  , CAST(UDT.dblCashierSummaryInfoNumberOfCustomerCount AS DECIMAL(18,6))  
					  , CAST(UDT.dblTotalDeposit AS DECIMAL(18,6))  
					 FROM @UDT_TransSummary UDT  
					 WHERE UDT.strSysId NOT IN  
					   (  
						SELECT strRegisterMop COLLATE SQL_Latin1_General_CP1_CS_AS AS strSysId
						FROM tblSTPaymentOption 
						WHERE intStoreId = @intStoreId
						AND strRegisterMop IS NOT NULL
						AND ISNULL(ysnDepositable,0) = 1
					   )  
					END  
				   ELSE  
					BEGIN  
					 UPDATE dbo.tblSTCheckoutCashiers  
					  SET dblTotalPaymentOption  = ISNULL(UDT.dblCashierTotalPaymentOption, 0)  
					  , intNumberOfVoids  = ISNULL(UDT.dblCashierVoidLineNumberOfVoids, 0)  
					  , dblVoidAmount   = ISNULL(UDT.dblCashierVoidLineAmountOfVoids, 0)  
					  , intOverrideCount   = ISNULL(UDT.dblCashierSummaryInfoNumberOfOverrides, 0)  
					  , intCustomerCount   = ISNULL(UDT.dblCashierSummaryInfoNumberOfCustomerCount, 0)  
					  , dblTotalDeposit         =ISNULL(UDT.dblTotalDeposit , 0)  
					 FROM @UDT_TransSummary UDT  
					 WHERE tblSTCheckoutCashiers.intCheckoutId = @intCheckoutId   
					 AND UDT.strSysId NOT IN  
					   (  
						SELECT strRegisterMop COLLATE SQL_Latin1_General_CP1_CS_AS AS strSysId
						FROM tblSTPaymentOption 
						WHERE intStoreId = @intStoreId
						AND strRegisterMop IS NOT NULL
						AND ISNULL(ysnDepositable,0) = 1
					   )  
					END  
				END
		-- ======================================================================================================================
		-- [ENDT] - INSERT CASHIER DETAIL 
		-- ======================================================================================================================



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