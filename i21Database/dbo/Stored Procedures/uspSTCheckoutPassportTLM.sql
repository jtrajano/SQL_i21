CREATE PROCEDURE [dbo].[uspSTCheckoutPassportTLM]
	@intCheckoutId INT,
	@UDT_TLM	StagingPassportTLM		READONLY,
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
			  --DECLARE @SavedPointTransaction AS VARCHAR(500) = 'CheckoutPassportTLM' + CAST(NEWID() AS NVARCHAR(100));
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
			-- Start Validate if TLM xml file matches the Mapping on i21 
			-- ------------------------------------------------------------------------------------------------------------------
			IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_TLM)
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
							, 'Passport TLM XML file did not match the layout mapping'
							, ''
							, ''
							, @intCheckoutId
							, 1
						)

						SET @intCountRows = 0
						SET @strStatusMsg = 'Passport TLM XML file did not match the layout mapping'

						GOTO ExitWithCommit
				END
			-- ------------------------------------------------------------------------------------------------------------------
			-- End Validate if TLM xml file matches the Mapping on i21   
			-- ==================================================================================================================



			  -- ================================================================================================================== 
				-- Get Error logs. Check Register XML that is not configured in i21
				-- Compare <TaxLevelID> tag of (RegisterXML) and (Common Info --> Tax COdes --> Store Tax No.) and (Store --> Tax Totals --> Tax COde)
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
					, 'No Matching Register Tax Code' as strErrorMessage
					, 'TaxLevelID' as strRegisterTag
					, ISNULL(Chk.intTaxLevelID, '') AS strRegisterTagValue
					, @intCheckoutId
					, 1
				FROM @UDT_TLM Chk
				WHERE ISNULL(Chk.intTaxLevelID, '') NOT IN
				(
					SELECT DISTINCT 
						tbl.strXmlRegisterTaxLevelID
					FROM
					(
						SELECT DISTINCT
							Chk.intTaxLevelID AS strXmlRegisterTaxLevelID
						FROM @UDT_TLM Chk
						JOIN tblSTCheckoutSalesTaxTotals STT
							ON ISNULL(Chk.intTaxLevelID, '') = STT.strTaxNo
						WHERE STT.intCheckoutId = @intCheckoutId
						AND ISNULL(Chk.intTaxLevelID, '') != ''
					) AS tbl
				)
				AND ISNULL(Chk.intTaxLevelID, '') != ''
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================




			 -- -- OLD
			 -- UPDATE  dbo.tblSTCheckoutSalesTaxTotals 
			 -- SET dblTotalTax = chk.TaxCollectedAmount,
				--dblTaxableSales = chk.TaxableSalesAmount,
				--dblTaxExemptSales = chk.TaxExemptSalesAmount
			 -- FROM @UDT_TLM chk
			 -- WHERE intCheckoutId = @intCheckoutId AND chk.TaxCollectedAmount <> 0 AND intTaxNo = 1

			  

			  ---- Most probably this is not neccesary because sales tax totals is already preloaded
              IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutSalesTaxTotals WHERE intCheckoutId = @intCheckoutId)
              BEGIN
                           DECLARE @tbl TABLE
                           (
                                  intCnt INT,
                                  intAccountId INT,
                                  strAccountId nvarchar(100),
                                  intItemId INT,
                                  strItemNo NVARCHAR(100),
                                  strItemDescription NVARCHAR(100)
                           )
                           INSERT INTO @tbl
                           EXEC uspSTGetSalesTaxTotalsPreload @intStoreId
                           INSERT INTO dbo.tblSTCheckoutSalesTaxTotals
                           (
                                  intCheckoutId
                                  , strTaxNo
                                  , dblTotalTax
                                  , dblTaxableSales
                                  , dblTaxExemptSales
                                  , intSalesTaxAccount
                                  , intConcurrencyId
                           )
                           SELECT
                                  @intCheckoutId
                                  , intCnt
                                  , NULL
                                  , NULL
                                  , NULL
                                  , intAccountId
                                  , 0
                           FROM @tbl
              END
      
			  -- TLM FILE
              UPDATE STT
              SET dblTotalTax = (
                                 SELECT CAST(ISNULL(dblTaxCollectedAmount, 0) AS DECIMAL(18,6))
                                 FROM @UDT_TLM
                                 WHERE ISNULL(intTaxLevelID, '') = STT.strTaxNo
                              ) 
			  , dblTaxableSales =  (
                                        SELECT CAST(ISNULL(dblTaxableSalesAmount, 0) AS DECIMAL(18,6))
                                        FROM @UDT_TLM
                                        WHERE ISNULL(intTaxLevelID, '') = STT.strTaxNo
                                     )          
			  , dblTaxExemptSales = (
										SELECT CAST(ISNULL(dblTaxExemptSalesAmount, 0) AS DECIMAL(18,6))
										FROM @UDT_TLM
										WHERE ISNULL(intTaxLevelID, '') = STT.strTaxNo
									)  
              FROM dbo.tblSTCheckoutSalesTaxTotals STT
              WHERE STT.intCheckoutId = @intCheckoutId

              -- Difference between Passport and Radiant
              -- 1. Passport does not have 'TenderTransactionsCount' tag in MSM register file
              -- 2. Passport does not have Lottery Winners MOP in tblSTRegister (Register screen)

              SET @intCountRows = 1
              SET @strStatusMsg = 'Success'

			  --PRINT 'SUCCESS'

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