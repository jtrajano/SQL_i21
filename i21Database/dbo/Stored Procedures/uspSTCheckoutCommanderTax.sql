CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTax]
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
			-- Start Validate if Tax xml file matches the Mapping on i21 
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
							, 'Commander Tax XML file did not match the layout mapping'
							, ''
							, ''
							, @intCheckoutId
							, 1
						)

						SET @intCountRows = 0
						SET @strStatusMsg = 'Commander Tax XML file did not match the layout mapping'

						GOTO ExitWithCommit
				END
			-- ------------------------------------------------------------------------------------------------------------------
			-- End Validate if Tax xml file matches the Mapping on i21   
			-- ==================================================================================================================



			  -- ================================================================================================================== 
				-- Get Error logs. Check Register XML that is not configured in i21
				-- Compare <taxrateBase sysid> tag of (RegisterXML) and (Common Info --> Tax COdes --> Store Tax No.) and (Store --> Tax Totals --> Tax COde)
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
					strErrorType			= 'NO MATCHING TAG'
					, strErrorMessage		= 'No Matching Register Tax Code'
					, strRegisterTag		= 'taxrateBase sysid'
					, strRegisterTagValue	= ISNULL(Chk.taxrateBasesysid, '')
					, intCheckoutId			= @intCheckoutId
					, intConcurrencyId		= 1
				FROM #tempCheckoutInsert Chk
				WHERE ISNULL(Chk.taxrateBasesysid, '') NOT IN
				(
					SELECT DISTINCT 
						tbl.strXmlRegisterTaxLevelID
					FROM
					(
						SELECT DISTINCT
							Chk.taxrateBasesysid AS strXmlRegisterTaxLevelID
						FROM #tempCheckoutInsert Chk
						JOIN tblSTCheckoutSalesTaxTotals STT
							ON ISNULL(Chk.taxrateBasesysid, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
						WHERE STT.intCheckoutId = @intCheckoutId
							AND ISNULL(Chk.taxrateBasesysid, '') != ''
							AND CAST(ISNULL(Chk.taxrateBasetaxRate, 0) AS DECIMAL(18,6)) != 0.000000
					) AS tbl
				)
					AND ISNULL(Chk.taxrateBasesysid, '') != ''
					AND CAST(ISNULL(Chk.taxrateBasetaxRate, 0) AS DECIMAL(18,6)) != 0.000000
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================

			  


				-- Tax FILE
				  UPDATE STT
				  SET dblTotalTax		= CAST(ISNULL(Chk.taxInfonetTax, 0) AS DECIMAL(18,6))
				  --SET dblTotalTax		= CAST(ISNULL(Chk.taxInfosalesTax, 0) AS DECIMAL(18,6)) http://jira.irelyserver.com/browse/ST-1587
					, dblTaxableSales	= CAST(ISNULL(Chk.taxInfotaxableSales, 0) AS DECIMAL(18,6))         
					, dblTaxExemptSales = CAST(ISNULL(Chk.taxInfotaxExemptSales, 0) AS DECIMAL(18,6))  
				  FROM #tempCheckoutInsert Chk
				  INNER JOIN dbo.tblSTCheckoutSalesTaxTotals STT
					ON ISNULL(Chk.taxrateBasesysid, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
				  WHERE STT.intCheckoutId = @intCheckoutId
					AND CAST(ISNULL(Chk.taxrateBasetaxRate, 0) AS DECIMAL(18,6)) != 0.000000

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