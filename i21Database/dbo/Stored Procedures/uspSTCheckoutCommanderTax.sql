CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTax]
	@intCheckoutId							INT,
	@UDT_TransTax							StagingCommanderTax		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
AS
BEGIN

	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCheckoutCommanderTax' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
       
	BEGIN TRY
              
			  
		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END

		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END


		-- ==================================================================================================================  
		-- Start Validate if Translog xml file matches the Mapping on i21 
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
					, 'Commander Translog XML file did not match the layout mapping'
					, ''
					, ''
					, @intCheckoutId
					, 1
				)

				SET @intCountRows = 0
				SET @strMessage = 'Commander Translog XML file did not match the layout mapping'

				GOTO ExitWithCommit
		END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if Translog xml file matches the Mapping on i21   
		-- ==================================================================================================================


		-- COUNT
		DECLARE @intTableRowCount AS INT = 0
		SELECT @intTableRowCount = COUNT(*) FROM @UDT_TransTax

		IF(@intTableRowCount > 0)
			BEGIN

				--Get StoreId
				DECLARE @intStoreId			INT,
						@strRegisterClass	NVARCHAR(50),
						@intRegisterClassId INT

				SELECT
					@intStoreId			= chk.intStoreId,
					@strRegisterClass	= r.strRegisterClass,
					@intRegisterClassId = setup.intRegisterSetupId
				FROM tblSTCheckoutHeader chk
				INNER JOIN tblSTStore st
					ON chk.intStoreId = st.intStoreId
				INNER JOIN tblSTRegister r
					ON st.intRegisterId = r.intRegisterId
				INNER JOIN tblSTRegisterSetup setup
					ON r.strRegisterClass = setup.strRegisterClass
				WHERE chk.intCheckoutId = @intCheckoutId


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

			  

				--INSERT INTO tblSTCheckoutSalesTaxTotals
				--(
				--	 dblTotalTax		   
				--	,dblTaxableSales	   
				--	,dblTaxExemptSales	          
				--	,intCheckoutId		   
				--)
				--SELECT
				--	 CAST(ISNULL(Chk.dblTaxInfoNetTax, 0) AS DECIMAL(18,6))
				--	,CAST(ISNULL(Chk.dblTaxInfoTaxableSales, 0) AS DECIMAL(18,6))         
				--	,CAST(ISNULL(Chk.dblTaxInfoTaxExemptSales, 0) AS DECIMAL(18,6))  
				--	,@intCheckoutId
				--FROM 
				--@UDT_TransTax Chk

				---- Tax FILE
				--  UPDATE STT
				--  SET dblTotalTax		= CAST(ISNULL(Chk.dblTaxInfoNetTax, 0) AS DECIMAL(18,6))
				--  --SET dblTotalTax		= CAST(ISNULL(Chk.taxInfosalesTax, 0) AS DECIMAL(18,6)) http://jira.irelyserver.com/browse/ST-1587
				--	, dblTaxableSales	= CAST(ISNULL(Chk.dblTaxInfoTaxableSales, 0) AS DECIMAL(18,6))         
				--	, dblTaxExemptSales = CAST(ISNULL(Chk.dblTaxInfoTaxExemptSales, 0) AS DECIMAL(18,6))  
				--  FROM @UDT_TransTax Chk
				--  INNER JOIN dbo.tblSTCheckoutSalesTaxTotals STT
				--	ON ISNULL(Chk.strSysId, '') COLLATE DATABASE_DEFAULT = STT.strTaxNo
				--  WHERE STT.intCheckoutId = @intCheckoutId
				--	AND CAST(ISNULL(Chk.dblTaxRateBaseTaxRate, 0) AS DECIMAL(18,6)) != 0.000000

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
              --SET @strStatusMsg = 'Success'

			  --PRINT 'SUCCESS'

              -- COMMIT
			  GOTO ExitWithCommit

 END


	END TRY
	BEGIN CATCH
		SET @ysnSuccess = CAST(0 AS BIT)
		SET @strMessage = 'End script error: ' + ERROR_MESSAGE()

		GOTO ExitWithRollback
	END CATCH
END







ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost



ExitWithRollback:

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strMessage = @strMessage + '. Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END

		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessage = @strMessage + '. Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END







ExitPost: