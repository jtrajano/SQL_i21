CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMSM]
	@intCheckoutId INT,
	@UDT_MSM	StagingPassportMSM		READONLY,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN

	--SET NOCOUNT ON
    SET XACT_ABORT ON
       
	   BEGIN TRY
              
			  DECLARE @intStoreId int
              SELECT @intStoreId = intStoreId
              FROM dbo.tblSTCheckoutHeader
              WHERE intCheckoutId = @intCheckoutId

			  -------------------------------------------------------------------------------------------- 
			  -- Create Save Point. 
			  --------------------------------------------------------------------------------------------   
			  -- Create a unique transaction name.
			  --DECLARE @SavedPointTransaction AS VARCHAR(500) = 'CheckoutPassportMSM' + CAST(NEWID() AS NVARCHAR(100));
			  --DECLARE @intTransactionCount INT = @@TRANCOUNT;

			  --IF(@intTransactionCount = 0)
				 -- BEGIN
					--  BEGIN TRAN @SavedPointTransaction
				 -- END
			  --ELSE
				 -- BEGIN
					--  SAVE TRAN @SavedPointTransaction --> Save point
				 -- END
			  BEGIN TRANSACTION
			  -------------------------------------------------------------------------------------------- 
			  -- END Create Save Point. 
			  --------------------------------------------------------------------------------------------



			-- ==================================================================================================================  
			-- Start Validate if MSM xml file matches the Mapping on i21 
			-- ------------------------------------------------------------------------------------------------------------------
				IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_MSM)
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
					, ISNULL(Chk.strMiscellaneousSummarySubCodeModifier, '') AS strRegisterTagValue
					, @intCheckoutId
					, 1
				FROM @UDT_MSM Chk
				WHERE ISNULL(Chk.strMiscellaneousSummarySubCodeModifier, '') NOT IN
				(
					SELECT DISTINCT 
						tbl.strXmlRegisterMiscellaneousSummarySubCodeModifier
					FROM
					(
						SELECT DISTINCT
							Chk.strMiscellaneousSummarySubCodeModifier AS strXmlRegisterMiscellaneousSummarySubCodeModifier
						FROM @UDT_MSM Chk
						JOIN tblSTPaymentOption PO 
							ON ISNULL(Chk.strMiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
						JOIN tblSTStore Store 
							ON Store.intStoreId = PO.intStoreId
						JOIN tblSTCheckoutPaymentOptions CPO 
							ON CPO.intPaymentOptionId = PO.intPaymentOptionId
						WHERE Store.intStoreId = @intStoreId
						AND Chk.strMiscellaneousSummaryCode = 'sales' 
						AND Chk.strMiscellaneousSummarySubCode = 'MOP'
						AND ISNULL(Chk.strMiscellaneousSummarySubCodeModifier, '') != ''
					) AS tbl
				)
				AND Chk.strMiscellaneousSummaryCode = 'sales' 
				AND Chk.strMiscellaneousSummarySubCode = 'MOP'
				AND ISNULL(Chk.strMiscellaneousSummarySubCodeModifier, '') != ''
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================


              
      
              ----Update tblSTCheckoutPaymentOptions
              Update dbo.tblSTCheckoutPaymentOptions
              SET dblRegisterAmount = ISNULL(chk.dblMiscellaneousSummaryAmount, 0)
                     , intRegisterCount = ISNULL(chk.intMiscellaneousSummaryCount, 0)
                     , dblAmount = ISNULL(chk.dblMiscellaneousSummaryAmount, 0)
              FROM @UDT_MSM chk
              JOIN tblSTPaymentOption PO 
				ON ISNULL(chk.strMiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
				-- ON PO.strRegisterMop COLLATE DATABASE_DEFAULT = ISNULL(Chk.strMiscellaneousSummarySubCodeModifier, '')
              JOIN tblSTStore Store 
				ON Store.intStoreId = PO.intStoreId
              JOIN tblSTCheckoutPaymentOptions CPO 
				ON CPO.intPaymentOptionId = PO.intPaymentOptionId
              WHERE Store.intStoreId = @intStoreId
              AND chk.strMiscellaneousSummaryCode = 'sales' 
			  AND chk.strMiscellaneousSummarySubCode = 'MOP'
              AND intCheckoutId = @intCheckoutId

              --Update dbo.tblSTCheckoutPaymentOptions
              --SET dblRegisterAmount = ISNULL(CAST(chk.dblMiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --     , intRegisterCount = ISNULL(CAST(chk.intMiscellaneousSummaryCount as int) ,0)
              --     , dblAmount = ISNULL(CAST(chk.dblMiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --FROM @UDT_MSM chk
              --WHERE intCheckoutId = @intCheckoutId
              --AND Chk.strMiscellaneousSummaryCode = 4
              --AND Chk.strMiscellaneousSummarySubCode IN (5,6)
              --AND intPaymentOptionId IN
              --(
              --     SELECT intLotteryWinnersMopId
              --     FROM dbo.tblSTRegister
              --     Where intStoreId = @intStoreId
              --)
      
              --Update dbo.tblSTCheckoutPaymentOptions
              --SET dblRegisterAmount = ISNULL(CAST(chk.dblMiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --     , intRegisterCount = ISNULL(CAST(chk.intMiscellaneousSummaryCount as int) ,0)
              --     , dblAmount = ISNULL(CAST(chk.dblMiscellaneousSummaryAmount as decimal(18,6)) ,0)
              --FROM @UDT_MSM chk
              --WHERE intCheckoutId = @intCheckoutId
              --AND Chk.strMiscellaneousSummaryCode = 19
              --AND Chk.strMiscellaneousSummarySubCodeModifier = 1550
              --AND intPaymentOptionId IN
              --(
              --     SELECT intPaymentOptionId
              --     FROM dbo.tblSTPaymentOption
              --     Where intRegisterMop = Chk.strMiscellaneousSummarySubCodeModifier
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
    --                                    FROM @UDT_MSM
    --                                    WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'taxTotals' 
    --                                    AND ISNULL(MiscellaneousSummarySubCode, '') = 'taxableSalesByTaxCode'
    --                                    AND ISNULL(MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
    --                                 ) 
    --          , dblTotalTax = (
    --                             SELECT CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6))
    --                             FROM @UDT_MSM
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
                                       SELECT SUM(CAST(ISNULL(intMiscellaneousSummaryCount, 0) AS DECIMAL(18, 6))) 
                                       FROM @UDT_MSM
                                       WHERE ISNULL(strMiscellaneousSummaryCode, '')  = 'totalizer' 
                                       AND ISNULL(strMiscellaneousSummarySubCode, '') = 'sales'
									   AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') = 'sales'
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
								SELECT SUM(CAST(intMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
								FROM @UDT_MSM 
								WHERE ISNULL(strMiscellaneousSummaryCode, '') = 'totalizer' 
								AND ISNULL(strMiscellaneousSummarySubCode, '') = 'tax' 
								AND ISNULL(strMiscellaneousSummarySubCodeModifier, '') = 'taxColl'
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
										SELECT SUM(CAST(intMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
										FROM @UDT_MSM 
										WHERE ISNULL(strMiscellaneousSummaryCode, '')  = 'statistics' 
										AND ISNULL(strMiscellaneousSummarySubCode, '') = 'noSales'
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
										 SELECT SUM(CAST(intMiscellaneousSummaryCount AS DECIMAL(18, 6))) 
										 FROM @UDT_MSM 
										 WHERE ISNULL(strMiscellaneousSummaryCode, '')  = 'statistics' 
										 AND ISNULL(strMiscellaneousSummarySubCode, '') = 'driveOffs'
									   ) 
          WHERE intCheckoutId = @intCheckoutId
      
          UPDATE dbo.tblSTCheckoutHeader
          SET dblFuelAdjustmentAmount = (
                                          SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                          FROM @UDT_MSM 
										  WHERE ISNULL(strMiscellaneousSummaryCode, '')  = 'statistics' 
										  AND ISNULL(strMiscellaneousSummarySubCode, '') = 'driveOffs'
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
										SELECT SUM(CAST(intMiscellaneousSummaryCount AS DECIMAL(18,6)))
										FROM @UDT_MSM 
										WHERE ISNULL(strMiscellaneousSummaryCode, '') = 'refunds' 
										AND ISNULL(strMiscellaneousSummarySubCode, '') ='total'
									) 
          WHERE intCheckoutId = @intCheckoutId
		   
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalRefundAmount = (
                                       SELECT SUM(CAST(ISNULL(dblMiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                       FROM @UDT_MSM 
									   WHERE ISNULL(strMiscellaneousSummaryCode, '') = 'refunds' 
									   AND ISNULL(strMiscellaneousSummarySubCode, '') ='total'
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
									SELECT SUM(CAST(dblMiscellaneousSummaryAmount as decimal(18,6))) 
									FROM @UDT_MSM 
									WHERE ISNULL(strMiscellaneousSummaryCode, '') = 'payouts' 
									AND ISNULL(strMiscellaneousSummarySubCode, '') ='total'
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