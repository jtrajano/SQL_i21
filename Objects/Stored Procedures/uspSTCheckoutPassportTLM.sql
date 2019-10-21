CREATE PROCEDURE [dbo].[uspSTCheckoutPassportTLM]
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
			-- Start Validate if TLM xml file matches the Mapping on i21 
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
					, ISNULL(Chk.TLMDetailTaxLevelID, '') AS strRegisterTagValue
					, @intCheckoutId
					, 1
				FROM #tempCheckoutInsert Chk
				WHERE ISNULL(Chk.TLMDetailTaxLevelID, '') NOT IN
				(
					SELECT DISTINCT 
						tbl.strXmlRegisterTaxLevelID
					FROM
					(
						SELECT DISTINCT
							Chk.TLMDetailTaxLevelID AS strXmlRegisterTaxLevelID
						FROM #tempCheckoutInsert Chk
						JOIN tblSTCheckoutSalesTaxTotals STT
							ON ISNULL(Chk.TLMDetailTaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
						WHERE STT.intCheckoutId = @intCheckoutId
						AND ISNULL(Chk.TLMDetailTaxLevelID, '') != ''
					) AS tbl
				)
				AND ISNULL(Chk.TLMDetailTaxLevelID, '') != ''
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================




			 -- -- OLD
			 -- UPDATE  dbo.tblSTCheckoutSalesTaxTotals 
			 -- SET dblTotalTax = chk.TaxCollectedAmount,
				--dblTaxableSales = chk.TaxableSalesAmount,
				--dblTaxExemptSales = chk.TaxExemptSalesAmount
			 -- FROM #tempCheckoutInsert chk
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
                                 SELECT CAST(ISNULL(TLMDetailTaxCollectedAmount, 0) AS DECIMAL(18,6))
                                 FROM #tempCheckoutInsert
                                 WHERE ISNULL(TLMDetailTaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
                              ) 
			  , dblTaxableSales =  (
                                        SELECT CAST(ISNULL(TLMDetailTaxableSalesAmount, 0) AS DECIMAL(18,6))
                                        FROM #tempCheckoutInsert
                                        WHERE ISNULL(TLMDetailTaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
                                     )          
			  , dblTaxExemptSales = (
										SELECT CAST(ISNULL(TLMDetailTaxExemptSalesAmount, 0) AS DECIMAL(18,6))
										FROM #tempCheckoutInsert
										WHERE ISNULL(TLMDetailTaxLevelID, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
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