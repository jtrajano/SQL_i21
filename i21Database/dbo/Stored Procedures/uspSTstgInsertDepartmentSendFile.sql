CREATE PROCEDURE [dbo].[uspSTstgInsertDepartmentSendFile]
	@strFilePrefix NVARCHAR(50)
	, @intStoreId INT
	, @intRegisterId INT
	, @dtmBeginningChangeDate DATETIME
	, @dtmEndingChangeDate DATETIME
	, @strGeneratedXML NVARCHAR(MAX) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @ysnSuccessResult BIT OUTPUT
	, @strMessageResult NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		
		SET @ysnSuccessResult = CAST(1 AS BIT) -- Set to true
		SET @strMessageResult = ''

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'ITT'
		DECLARE @xml XML = N''
		DECLARE @strXML AS NVARCHAR(MAX)




		-- =========================================================================================================
		-- [START] - CREATE TRANSACTION
		-- =========================================================================================================
		DECLARE @InitTranCount INT;
		SET @InitTranCount = @@TRANCOUNT
		DECLARE @Savepoint NVARCHAR(150) = 'uspSTstgInsertDepartmentSendFile' + CAST(NEWID() AS NVARCHAR(100)); 

		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END		
		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END
		-- =========================================================================================================
		-- [START] - CREATE TRANSACTION
		-- =========================================================================================================




		-- =========================================================================================================
		-- CONVERT DATE's to UTC
		-- =========================================================================================================
		DECLARE @dtmBeginningChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmBeginningChangeDate)
		DECLARE @dtmEndingChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmEndingChangeDate)
		-- =========================================================================================================
		-- END CONVERT DATE's to UTC
		-- =========================================================================================================




		-- =========================================================================================================
		-- Get Register Values
		DECLARE @strRegisterName NVARCHAR(200)
				, @strRegisterClass NVARCHAR(200)
				, @strXmlVersion NVARCHAR(10)

		SELECT @strRegisterClass = strRegisterClass
			   , @strRegisterName = strRegisterName
			   , @strXmlVersion = strXmlVersion
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId
		-- =========================================================================================================




		-- ================================================================================================================================================
		-- [START] - GET 'intImportFileHeaderId'
		-- ================================================================================================================================================
		IF EXISTS(SELECT TOP 1 1 FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
				SELECT @intImportFileHeaderId = intImportFileHeaderId
				FROM tblSTRegisterFileConfiguration 
				WHERE intRegisterId = @intRegisterId 
				AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
				SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
				SET @strGeneratedXML = ''
				SET @intImportFileHeaderId = 0
				SET @strMessageResult = 'Register ' + @strRegisterClass + ' has no Outbound setup for Pricebook File (' + @strFilePrefix + '). '

				RETURN
			END
		-- ================================================================================================================================================
		-- [END] - GET 'intImportFileHeaderId'
		-- ================================================================================================================================================


		DECLARE @XMLGatewayVersion nvarchar(100)

		SELECT @XMLGatewayVersion = strXmlVersion 
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId

		SET @XMLGatewayVersion = ISNULL(@XMLGatewayVersion, '')
		
	    
		--------------------------------------------------------------------------------------------------------------
		---------------- Start Get Category departments that has modified/added date between date range -------------------
		--------------------------------------------------------------------------------------------------------------
		DECLARE @tempTableCategory TABLE
		(
			intCategoryId INT, 
			strActionType NVARCHAR(20), 
			dtmDate DATETIME
		)

		INSERT INTO @tempTableCategory
		SELECT DISTINCT intCategoryId
						, CASE
								WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC 
									THEN 'Created' 
								ELSE 'Updated'
						  END AS strActionType
						, CASE
								WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC 
									THEN dtmDateCreated 
								ELSE dtmDateModified
						  END AS dtmDate
		FROM vyuSTCategoriesToRegister
		WHERE 
		--(
		--	dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		--	OR 
		--	dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		--)
		--AND 
		intCompanyLocationId = (
										SELECT intCompanyLocationId 
										FROM tblSTStore
										WHERE intStoreId = @intStoreId
								   )
		--------------------------------------------------------------------------------------------------------------
		----------------- End Get Inventory Items that has modified/added date between date range --------------------
		--------------------------------------------------------------------------------------------------------------

----TEST
--SELECT * FROM @tempTableItems
--SELECT '@strRegisterClass: ', @strRegisterClass
		



				-- ===========================================================================================================
				-- [START] - Validate if @tempTableCategory has record/s
				-- ===========================================================================================================
				IF NOT EXISTS(SELECT TOP 1 1 FROM @tempTableCategory)
					BEGIN
										
							SET @strGeneratedXML		= N''
							SET @intImportFileHeaderId	= 0
							SET @ysnSuccessResult		= CAST(0 AS BIT)
							SET @strMessageResult		= 'No Categories to Generate based on Store Location, Beginning and Ending date range. '

							GOTO ExitWithRollback
					END
				-- ===========================================================================================================
				-- [END] - Validate if @tempTableCategory has record/s
				-- ===========================================================================================================

				BEGIN
					INSERT INTO tblSTstgDepartmentSendFile
					SELECT DISTINCT
						ST.intStoreNo [StoreLocationID]
						, 'iRely' [VendorName]  	
						, 'Rel. 13.2.0' [VendorModelVersion]
						, 'update' [TableActionType]
						, 'addchange' [RecordActionType] 
						, 'addchange' AS [MCTDetailRecordActionType] 
						, StoreDepartments.strRegisterCode AS [MerchandiseCode] 
						, 'yes' AS [ActiveFlagValue] 
						, Cat.strDescription AS [strDescription] 
						, ISNULL(SR.strRegProdCode, 0) AS [SalesRestrictCode]
						, ISNULL((CASE	
							WHEN IL.ysnTaxFlag1 = 1 
								THEN R.intTaxStrategyIdForTax1 
							WHEN IL.ysnTaxFlag2 = 1 
								THEN R.intTaxStrategyIdForTax2 
							WHEN IL.ysnTaxFlag3 = 1 
								THEN R.intTaxStrategyIdForTax3 
							WHEN IL.ysnTaxFlag4 = 1 
								THEN R.intTaxStrategyIdForTax4
							ELSE R.intNonTaxableStrategyId
						END), 0) AS [TaxStrategyID]
					FROM tblICCategory Cat
					JOIN 
					(
						SELECT DISTINCT intCategoryId FROM @tempTableCategory 
					) AS tmpItem 
						ON tmpItem.intCategoryId = Cat.intCategoryId 
					JOIN vyuSTStoreDepartments StoreDepartments 
						ON Cat.intCategoryId = StoreDepartments.intCategoryId
					JOIN tblICItem I
						ON StoreDepartments.intGeneralItemId = I.intItemId
					JOIN tblICItemLocation IL 
						ON IL.intItemId = I.intItemId
					LEFT JOIN tblSTSubcategoryRegProd SR 
						ON SR.intRegProdId = IL.intProductCodeId
					JOIN tblSTStore ST 
						ON IL.intLocationId = ST.intCompanyLocationId
					JOIN tblSTRegister R 
						ON ST.intRegisterId = R.intRegisterId
					WHERE ST.intStoreId = @intStoreId

				END

			IF EXISTS(SELECT StoreLocationID FROM tblSTstgDepartmentSendFile)
				BEGIN

						-- Generate XML for the pricebook data availavle in staging table
						Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgDepartmentSendFile~intDepartmentSendFile > 0', 0, @strGeneratedXML OUTPUT

						--Once XML is generated delete the data from pricebook  staging table.
						DELETE FROM dbo.tblSTstgDepartmentSendFile
				END
			ELSE 
				BEGIN
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = 'No result found to generate Department - ' + @strFilePrefix + ' Outbound file'
				END	
		-- COMMIT
		GOTO ExitWithCommit

	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = @strMessageResult + ERROR_MESSAGE() + '. '

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
		SET @ysnSuccessResult			= CAST(0 AS BIT)

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strMessageResult = @strMessageResult + 'Will Rollback Transaction. '

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessageResult = @strMessageResult + 'Will Rollback to Save point. '

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
		
		
	

		
ExitPost: