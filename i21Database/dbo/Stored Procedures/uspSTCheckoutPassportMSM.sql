CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMSM]
	@intCheckoutId INT,
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
			  DECLARE @SavedPointTransaction AS VARCHAR(500) = 'CheckoutPassportMSM' + CAST(NEWID() AS NVARCHAR(100));
			  DECLARE @intTransactionCount INT = @@TRANCOUNT;

			  IF(@intTransactionCount = 0)
				  BEGIN
					  BEGIN TRAN @SavedPointTransaction
				  END
			  ELSE
				  BEGIN
					  SAVE TRAN @SavedPointTransaction --> Save point
				  END
			  -------------------------------------------------------------------------------------------- 
			  -- END Create Save Point. 
			  --------------------------------------------------------------------------------------------



			  -- ================================================================================================================== 
				-- Get Error logs. Check Register XML that is not configured in i21
				-- Compare <MiscellaneousSummarySubCodeModifier> tag of (RegisterXML) and (Store -> Store -> Payment Option(Tab) -> 'Register Mop'(strRegisterMopId))
				-- ------------------------------------------------------------------------------------------------------------------ 
				INSERT INTO tblSTCheckoutErrorLogs 
				(
					strErrorMessage 
					, strRegisterTag
					, strRegisterTagValue
					, intCheckoutId
					, intConcurrencyId
				)
				SELECT DISTINCT
					'Missing Miscellaneous Summary SubCode Modifier' as strErrorMessage
					, 'MiscellaneousSummarySubCodeModifier' as strRegisterTag
					, ISNULL(Chk.MiscellaneousSummarySubCodeModifier, '') AS strRegisterTagValue
					, @intCheckoutId
					, 1
				FROM #tempCheckoutInsert Chk
				WHERE ISNULL(Chk.MiscellaneousSummarySubCodeModifier, '') NOT IN
				(
					SELECT DISTINCT 
						tbl.strXmlRegisterMiscellaneousSummarySubCodeModifier
					FROM
					(
						SELECT DISTINCT
							Chk.MiscellaneousSummarySubCodeModifier AS strXmlRegisterMiscellaneousSummarySubCodeModifier
						FROM #tempCheckoutInsert chk
						JOIN tblSTPaymentOption PO 
							ON ISNULL(chk.MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
						JOIN tblSTStore Store 
							ON Store.intStoreId = PO.intStoreId
						JOIN tblSTCheckoutPaymentOptions CPO 
							ON CPO.intPaymentOptionId = PO.intPaymentOptionId
						WHERE Store.intStoreId = @intStoreId
						AND chk.MiscellaneousSummaryCode = 'sales' 
						AND chk.MiscellaneousSummarySubCode = 'MOP'
						AND intCheckoutId = @intCheckoutId
						AND ISNULL(Chk.MiscellaneousSummarySubCodeModifier, '') != ''
					) AS tbl
				)
				AND ISNULL(Chk.MiscellaneousSummarySubCodeModifier, '') != ''
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================


              
      
              ----Update tblSTCheckoutPaymentOptions
              Update dbo.tblSTCheckoutPaymentOptions
              SET dblRegisterAmount = ISNULL(chk.MiscellaneousSummaryAmount, 0)
                     , intRegisterCount = ISNULL(chk.MiscellaneousSummaryCount, 0)
                     , dblAmount = ISNULL(chk.MiscellaneousSummaryAmount, 0)
              FROM #tempCheckoutInsert chk
              JOIN tblSTPaymentOption PO 
				ON ISNULL(chk.MiscellaneousSummarySubCodeModifier, '') COLLATE DATABASE_DEFAULT = PO.strRegisterMop
				--ON PO.strRegisterMop COLLATE DATABASE_DEFAULT = ISNULL(chk.MiscellaneousSummarySubCodeModifier, '')
              JOIN tblSTStore Store 
				ON Store.intStoreId = PO.intStoreId
              JOIN tblSTCheckoutPaymentOptions CPO 
				ON CPO.intPaymentOptionId = PO.intPaymentOptionId
              WHERE Store.intStoreId = @intStoreId
              AND chk.MiscellaneousSummaryCode = 'sales' 
			  AND chk.MiscellaneousSummarySubCode = 'MOP'
              AND intCheckoutId = @intCheckoutId

    --          -- Difference between Passport and Radiant
    --          -- 1. Passport does not have 'TenderTransactionsCount' tag in MSM register file
    --          -- 2. Passport does not have Lottery Winners MOP in tblSTRegister (Register screen)
      
		  -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- CUSTOMER COUNT -----------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
          UPDATE dbo.tblSTCheckoutHeader
          SET dblCustomerCount = (
                                       SELECT SUM(CAST(ISNULL(MiscellaneousSummaryCount, 0) AS DECIMAL(18, 6))) 
                                       FROM #tempCheckoutInsert
                                       WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'totalizer' 
                                       AND ISNULL(MiscellaneousSummarySubCode, '') = 'sales'
									   AND ISNULL(MiscellaneousSummarySubCodeModifier, '') = 'sales'
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
								SELECT SUM(CAST(MiscellaneousSummaryCount AS DECIMAL(18, 6))) 
								FROM #tempCheckoutInsert 
								WHERE ISNULL(MiscellaneousSummaryCode, '') = 'totalizer' 
								AND ISNULL(MiscellaneousSummarySubCode, '') = 'tax' 
								AND ISNULL(MiscellaneousSummarySubCodeModifier, '') = 'taxColl'
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
										SELECT SUM(CAST(MiscellaneousSummaryCount AS DECIMAL(18, 6))) 
										FROM #tempCheckoutInsert 
										WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'statistics' 
										AND ISNULL(MiscellaneousSummarySubCode, '') = 'noSales'
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
										 SELECT SUM(CAST(MiscellaneousSummaryCount AS DECIMAL(18, 6))) 
										 FROM #tempCheckoutInsert 
										 WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'statistics' 
										 AND ISNULL(MiscellaneousSummarySubCode, '') = 'driveOffs'
									   ) 
          WHERE intCheckoutId = @intCheckoutId
      
          UPDATE dbo.tblSTCheckoutHeader
          SET dblFuelAdjustmentAmount = (
                                          SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                          FROM #tempCheckoutInsert 
										  WHERE ISNULL(MiscellaneousSummaryCode, '')  = 'statistics' 
										  AND ISNULL(MiscellaneousSummarySubCode, '') = 'driveOffs'
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
										SELECT SUM(CAST(MiscellaneousSummaryCount AS DECIMAL(18,6)))
										FROM #tempCheckoutInsert 
										WHERE ISNULL(MiscellaneousSummaryCode, '') = 'refunds' 
										AND ISNULL(MiscellaneousSummarySubCode, '') ='total'
									) 
          WHERE intCheckoutId = @intCheckoutId
		   
          UPDATE dbo.tblSTCheckoutHeader
          SET dblTotalRefundAmount = (
                                       SELECT SUM(CAST(ISNULL(MiscellaneousSummaryAmount, 0) AS DECIMAL(18,6)))
                                       FROM #tempCheckoutInsert 
									   WHERE ISNULL(MiscellaneousSummaryCode, '') = 'refunds' 
									   AND ISNULL(MiscellaneousSummarySubCode, '') ='total'
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
									SELECT SUM(CAST(MiscellaneousSummaryAmount as decimal(18,6))) 
									FROM #tempCheckoutInsert 
									WHERE ISNULL(MiscellaneousSummaryCode, '') = 'payouts' 
									AND ISNULL(MiscellaneousSummarySubCode, '') ='total'
								 ) 
          WHERE intCheckoutId = @intCheckoutId
          -------------------------------------------------------------------------------------------------------------
          ----------------------------------------- END PAID OUTS -----------------------------------------------------
          -------------------------------------------------------------------------------------------------------------
      

              SET @intCountRows = 1
              SET @strStatusMsg = 'Success'

			  --PRINT 'SUCCESS'

              -- IF SUCCESS Commit Transaction
			  IF(@intTransactionCount = 0)
				BEGIN
					COMMIT TRANSACTION @SavedPointTransaction
				END
       END TRY

       BEGIN CATCH
              SET @intCountRows = 0
              SET @strStatusMsg = ERROR_MESSAGE()

			  PRINT ERROR_MESSAGE()

			  -- IF HAS Error Rollback Transaction
			  IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0)) 
				BEGIN
					 ROLLBACK TRANSACTION @SavedPointTransaction;
					 --THROW;
				END
       END CATCH
END