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


			  DECLARE @intStoreId int
              SELECT @intStoreId = intStoreId
              FROM dbo.tblSTCheckoutHeader
              WHERE intCheckoutId = @intCheckoutId

			-- ==================================================================================================================  
			-- Start Validate if MSM xml file matches the Mapping on i21 
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
			-- ------------------------------------------------------------------------------------------------------------------
			-- End Validate if MSM xml file matches the Mapping on i21   
			-- ==================================================================================================================



			  -- ================================================================================================================== 
				-- Get Error logs. Check Register XML that is not configured in i21
				-- Compare <MiscellaneousSummarySubCodeModifier> tag of (RegisterXML) and (Store -> Store -> Payment Option(Tab) -> 'Register Mop'(strRegisterMopId))
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
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================


              
      
              ----Update tblSTCheckoutPaymentOptions
              Update dbo.tblSTCheckoutPaymentOptions
              SET dblRegisterAmount = ISNULL(chk.MSMSalesTotalsMiscellaneousSummaryAmount, 0)
                     , intRegisterCount = ISNULL(chk.MSMSalesTotalsMiscellaneousSummaryCount, 0)
                     , dblAmount = ISNULL(chk.MSMSalesTotalsMiscellaneousSummaryAmount, 0)
              FROM #tempCheckoutInsert chk
              JOIN tblSTPaymentOption PO 
				ON ISNULL(chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
				-- ON PO.strRegisterMop COLLATE DATABASE_DEFAULT = ISNULL(chk.MiscellaneousSummarySubCodeModifier, '')
              JOIN tblSTStore Store 
				ON Store.intStoreId = PO.intStoreId
              JOIN tblSTCheckoutPaymentOptions CPO 
				ON CPO.intPaymentOptionId = PO.intPaymentOptionId
              WHERE Store.intStoreId = @intStoreId
              AND chk.MiscellaneousSummaryCodesMiscellaneousSummaryCode = 'sales' 
			  AND chk.MiscellaneousSummaryCodesMiscellaneousSummarySubCode = 'MOP'
              AND intCheckoutId = @intCheckoutId

              --Update dbo.tblSTCheckoutPaymentOptions
              --SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --     , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
              --     , dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --FROM #tempCheckoutInsert chk
              --WHERE intCheckoutId = @intCheckoutId
              --AND chk.MiscellaneousSummaryCode = 4
              --AND chk.MiscellaneousSummarySubCode IN (5,6)
              --AND intPaymentOptionId IN
              --(
              --     SELECT intLotteryWinnersMopId
              --     FROM dbo.tblSTRegister
              --     Where intStoreId = @intStoreId
              --)
      
              --Update dbo.tblSTCheckoutPaymentOptions
              --SET dblRegisterAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --     , intRegisterCount = ISNULL(CAST(chk.MiscellaneousSummaryCount as int) ,0)
              --     , dblAmount = ISNULL(CAST(chk.MiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --FROM #tempCheckoutInsert chk
              --WHERE intCheckoutId = @intCheckoutId
              --AND chk.MiscellaneousSummaryCode = 19
              --AND chk.MiscellaneousSummarySubCodeModifier = 1550
              --AND intPaymentOptionId IN
              --(
              --     SELECT intPaymentOptionId
              --     FROM dbo.tblSTPaymentOption
              --     Where intRegisterMop = chk.MiscellaneousSummarySubCodeModifier
              --)

				------ Most probably this is not nessesary because sales tax totals is already preloaded
    --          IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId)
    --          BEGIN
    --                       DECLARE @tbl TABLE
    --                       (
    --                              intCnt INT,
    --                              intAccountId INT,
    --                              strAccountId nvarchar(100),
    --                              intItemId INT,
    --                              strItemNo NVARCHAR(100),
    --                              strItemDescription NVARCHAR(100)
    --                       )
    --                       INSERT INTO @tbl
    --                       EXEC uspSTGetSalesTaxTotalsPreload @intStoreId
    --                       INSERT INTO dbo.tblSTCheckoutSalesTaxTotals
    --                       (
    --                              intCheckoutId
    --                              , strTaxNo
    --                              , dblTotalTax
    --                              , dblTaxableSales
    --                              , dblTaxExemptSales
    --                              , intSalesTaxAccount
    --                              , intConcurrencyId
    --                       )
    --                       SELECT
    --                              @intCheckoutId
    --                              , intCnt
    --                              , NULL
    --                              , NULL
    --                              , NULL
    --                              , intAccountId
    --                              , 0
    --                       FROM @tbl
    --          END
      
          
    --          UPDATE STT
    --          SET dblTaxableSales =  (
    --                                    SELECT CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6))
    --                                    FROM #tempCheckoutInsert
    --                                    WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'taxTotals' 
    --                                    AND ISNULL(MiscellaneousSummarySubCode, '') = 'taxableSalesByTaxCode'
    --                                    AND ISNULL(MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
    --                                 ) 
    --          , dblTotalTax = (
    --                             SELECT CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6))
    --                             FROM #tempCheckoutInsert
    --                             WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'taxTotals' 
    --                             AND ISNULL(MiscellaneousSummarySubCode, '') = 'taxableSalesByTaxCode'
    --                             AND ISNULL(MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
    --                          ) 
    --          FROM dbo.tblSTCheckoutSalesTaxTotals STT
    --          WHERE STT.intCheckoutId = @intCheckoutId

    --          -- Difference between Passport and Radiant
    --          -- 1. Passport does not have 'TenderTransactionsCount' tag in MSM register file
    --          -- 2. Passport does not have Lottery Winners MOP in tblSTRegister (Register screen)
      
		  -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- CUSTOMER COUNT -----------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblCustomerCount = (
                                       SELECT SUM(CAST(ISNULL(MSMSalesTotalsMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6))) 
                                       FROM #tempCheckoutInsert
                                       WHERE ISNULL(MiscellaneousSummaryCodesMiscellaneousSummaryCode, '')  = 'totalizer' 
                                       AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCode, '') = 'sales'
									   AND ISNULL(MiscellaneousSummaryCodesMiscellaneousSummarySubCodeModifier, '') = 'sales'
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