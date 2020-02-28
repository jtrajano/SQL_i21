CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTax]
	@intCheckoutId							INT,
	@UDT_TransTax							StagingCommanderTax		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
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
			IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_TransTax)
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
						SET @strMessage = 'Commander Tax XML file did not match the layout mapping'
						SET @ysnSuccess = 0

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
					, strRegisterTagValue	= ISNULL(Chk.strSysId, '')
					, intCheckoutId			= @intCheckoutId
					, intConcurrencyId		= 1
				FROM @UDT_TransTax Chk
				WHERE ISNULL(Chk.strSysId, '') NOT IN
				(
					SELECT DISTINCT 
						tbl.strXmlRegisterTaxLevelID
					FROM
					(
						SELECT DISTINCT
							Chk.strSysId AS strXmlRegisterTaxLevelID
						FROM @UDT_TransTax Chk
						JOIN tblSTCheckoutSalesTaxTotals STT
							ON ISNULL(Chk.strSysId, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
						WHERE STT.intCheckoutId = @intCheckoutId
							AND ISNULL(Chk.strSysId, '') != ''
							--AND CAST(ISNULL(Chk.taxrateBasetaxRate, 0) AS DECIMAL(18,6)) != 0.000000
					) AS tbl
				)
					AND ISNULL(Chk.strSysId, '') != ''
					--AND CAST(ISNULL(Chk.taxrateBasetaxRate, 0) AS DECIMAL(18,6)) != 0.000000
				-- ------------------------------------------------------------------------------------------------------------------  
				-- END Get Error logs. Check Register XML that is not configured in i21.  
				-- ==================================================================================================================

			  


				-- Tax FILE
				  UPDATE STT
				  SET dblTotalTax		= CAST(ISNULL(Chk.dblTaxInfoNetTax, 0) AS DECIMAL(18,6))
				  --SET dblTotalTax		= CAST(ISNULL(Chk.taxInfosalesTax, 0) AS DECIMAL(18,6)) http://jira.irelyserver.com/browse/ST-1587
					, dblTaxableSales	= CAST(ISNULL(Chk.dblTaxInfoTaxableSales, 0) AS DECIMAL(18,6))         
					, dblTaxExemptSales = CAST(ISNULL(Chk.dblTaxInfoTaxExemptSales, 0) AS DECIMAL(18,6))  
				  FROM @UDT_TransTax Chk
				  INNER JOIN dbo.tblSTCheckoutSalesTaxTotals STT
					ON ISNULL(Chk.strSysId, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
				  WHERE STT.intCheckoutId = @intCheckoutId
					AND CAST(ISNULL(Chk.dblTaxRateBaseTaxRate, 0) AS DECIMAL(18,6)) != 0.000000

              -- Difference between Passport and Radiant
              -- 1. Passport does not have 'TenderTransactionsCount' tag in MSM register file
              -- 2. Passport does not have Lottery Winners MOP in tblSTRegister (Register screen)

              SET @intCountRows = 1
              SET @strMessage = 'Success'
			  SET @ysnSuccess = 1

			  --PRINT 'SUCCESS'

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