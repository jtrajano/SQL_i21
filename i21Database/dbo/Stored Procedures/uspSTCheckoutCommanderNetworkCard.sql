CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderNetworkCard]
	@intCheckoutId								INT,
	@UDT_NetworkCard StagingNetworkCard			READONLY,
	@ysnSuccess									BIT				OUTPUT,
	@strMessage									NVARCHAR(1000)	OUTPUT,
	@intCountRows								INT				OUTPUT
AS
BEGIN

	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCheckoutCommanderNetworkCard' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY


		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END

		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END

		--SELECT * FROM @UDT_NetworkCard
		-- =================================================================================================================
		-- [START] - Get Store and Register Id 
		-- =================================================================================================================
		DECLARE @intStoreId			INT,
		        @intRegisterId		INT,
				@strRegisterClass	NVARCHAR(50),
				@intRegisterClassId INT

		SELECT  TOP 1
			@intStoreId				= st.intStoreId
			, @intRegisterId		= reg.intRegisterId
			, @strRegisterClass		= reg.strRegisterClass
			, @intRegisterClassId	= setup.intRegisterSetupId
		FROM tblSTCheckoutHeader ch
		INNER JOIN tblSTStore st
			ON ch.intStoreId = st.intStoreId
		INNER JOIN tblSTRegister reg
			ON st.intRegisterId = reg.intRegisterId
		LEFT JOIN tblSTRegisterSetup setup
			ON reg.strRegisterClass = setup.strRegisterClass
		WHERE ch.intCheckoutId = @intCheckoutId
		-- =================================================================================================================
		-- [END] - Get Store and Register Id 
		-- =================================================================================================================



		-- =================================================================================================================
		-- [START] - Check if Network Totals is activated
		-- =================================================================================================================
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTRegister WHERE intRegisterId = @intRegisterId AND ysnNetworkTotals = CAST(1 AS BIT))
			BEGIN
				-- =========================================================================================================
				-- [START] - Inactive network totals
				-- =========================================================================================================
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
					strErrorType			= 'INACTIVE NETWORK TOTALS'
					, strErrorMessage		= 'No Matching Network Card in Store setup'
					, strRegisterTag		= ''
					, strRegisterTagValue	= ''
					, intCheckoutId			= @intCheckoutId
					, intConcurrencyId		= 1
				-- =========================================================================================================
				-- [END] -  Inactive network totals
				-- =========================================================================================================


				SET @ysnSuccess	= CAST(0 AS BIT)
				SET @strMessage = 'Register Network Totals is set to false. Will not process network cards.'
				SET @intCountRows = 0

				GOTO ExitWithCommit
			END		
		-- =================================================================================================================
		-- [END] - Check if Network Totals is activated
		-- =================================================================================================================



		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- ==================================================================================================================  
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
			, strErrorMessage		= 'No Matching Network Card in Store setup'
			, strRegisterTag		= 'cardName'
			, strRegisterTagValue	= nc.strCardInfoCardName
			, intCheckoutId			= @intCheckoutId
			, intConcurrencyId		= 1
		FROM @UDT_NetworkCard nc
		WHERE nc.strCardInfoCardName COLLATE DATABASE_DEFAULT NOT IN
		(
			SELECT DISTINCT
				po.strNetworkCreditCardName
			FROM tblSTCheckoutPaymentOptions po
			INNER JOIN tblSTCheckoutHeader ch
				ON po.intCheckoutId = ch.intCheckoutId
			INNER JOIN tblSTStore st
				ON ch.intStoreId = st.intStoreId
			WHERE ch.intCheckoutId = @intCheckoutId
				AND po.ysnSkipImport = CAST(0 AS BIT)   -- Note: If set to false then it will NOT skip and will continue to import Network Cards
		)
			AND nc.strCardInfoCardName IS NOT NULL
		-- ==================================================================================================================   
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================


		-- COUNT
		DECLARE @intTableRowCount AS INT = 0
		SELECT @intTableRowCount = COUNT(*) FROM @UDT_NetworkCard


		IF(@intTableRowCount > 0)
			BEGIN

				UPDATE CPO
					SET dblRegisterAmount		= ISNULL(nc.dblCardChargesAmount, 0)
						 , intRegisterCount		= ISNULL(nc.dblCardChargesCount, 0)
						 , dblAmount			= ISNULL(nc.dblCardChargesAmount, 0)
				FROM @UDT_NetworkCard nc
				INNER JOIN tblSTPaymentOption PO 
					ON nc.strCardInfoCardName COLLATE DATABASE_DEFAULT = PO.strNetworkCreditCardName
				INNER JOIN tblSTStore Store 
					ON Store.intStoreId = PO.intStoreId
				INNER JOIN tblSTCheckoutPaymentOptions CPO 
					ON CPO.intPaymentOptionId = PO.intPaymentOptionId
				WHERE Store.intStoreId = @intStoreId
					AND CPO.intCheckoutId = @intCheckoutId
					AND PO.ysnSkipImport = CAST(0 AS BIT)

				
				SET @ysnSuccess = CAST(1 AS BIT)
				SET @strMessage = 'Success'
				SET @intCountRows = @@ROWCOUNT



			END
		ELSE IF(@intTableRowCount = 0)
			BEGIN
					SET @ysnSuccess	= CAST(0 AS BIT)
					SET @strMessage = 'Selected register file is empty'
					SET @intCountRows = 0

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
