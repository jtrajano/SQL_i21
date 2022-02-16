CREATE PROCEDURE [dbo].[uspSTstgInsertPricebookSendFile]
	@strFilePrefix NVARCHAR(50)
	, @intStoreId INT
	, @intRegisterId INT
	, @strCategoryCode NVARCHAR(MAX)
	, @dtmBeginningChangeDate DATETIME
	, @dtmEndingChangeDate DATETIME
	, @ysnExportEntirePricebookFile BIT
	, @strGuid UNIQUEIDENTIFIER
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
		DECLARE @Savepoint NVARCHAR(150) = 'uspSTstgInsertPricebookSendFile' + CAST(NEWID() AS NVARCHAR(100)); 

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
		---------------- Start Get Inventory Items that has modified/added date between date range -------------------
		--------------------------------------------------------------------------------------------------------------
		IF EXISTS(SELECT TOP 1 1 FROM tblSTUpdateRegisterItemReport WHERE strGuid = @strGuid)
			BEGIN
				-- Remove
				DELETE FROM tblSTUpdateRegisterItemReport 
				WHERE strGuid = @strGuid
			END

		DECLARE @tempTableItems TABLE
		(
			intItemId INT, 
			strActionType NVARCHAR(20), 
			dtmDate DATETIME
		)

		INSERT INTO @tempTableItems
		SELECT DISTINCT intItemId
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
		FROM vyuSTItemsToRegister
		WHERE 
		(
			dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
			OR 
			dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		)
		AND intCompanyLocationId = (
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
		-- [START] - Validate if @tblTempPassportITT has record/s
		-- ===========================================================================================================
		IF NOT EXISTS(SELECT TOP 1 1 FROM @tempTableItems)
			BEGIN
										
					SET @strGeneratedXML		= N''
					SET @intImportFileHeaderId	= 0
					SET @ysnSuccessResult		= CAST(0 AS BIT)
					SET @strMessageResult		= 'No Item to Generate based on Store Location, Beginning and Ending date range. '

					GOTO ExitWithRollback
			END
		-- ===========================================================================================================
		-- [END] - Validate if @tblTempPassportITT has record/s
		-- ===========================================================================================================





		-- =======================================================================================================================================================
		-- [START] - Check if has UPC longer than 13 digits
		-- =======================================================================================================================================================
		DECLARE @strInvalidUPCs NVARCHAR(MAX)

		DECLARE @tempInvalidUpc AS TABLE
		(
			intItemUOMId		INT,
			strLongUPCCode		NVARCHAR(50),
			strItemNo			NVARCHAR(50),
			strItemDescription	NVARCHAR(150)
		)

		INSERT INTO @tempInvalidUpc
		(
			intItemUOMId,
			strLongUPCCode,
			strItemNo,
			strItemDescription
		)
		SELECT DISTINCT
			intItemUOMId		= uom.intItemUOMId,
			strLongUPCCode		= uom.strLongUPCCode,
			strItemNo			= item.strItemNo,
			strItemDescription	= item.strDescription
		FROM tblICItemUOM uom
		INNER JOIN tblICItem item	
			ON uom.intItemId = item.intItemId
		INNER JOIN tblICCategory category
			ON item.intCategoryId = category.intCategoryId
		INNER JOIN tblICItemLocation itemLoc
			ON item.intItemId = itemLoc.intItemId
		INNER JOIN tblSTStore store
			ON itemLoc.intLocationId = store.intCompanyLocationId
		INNER JOIN @tempTableItems temp
			ON item.intItemId = temp.intItemId
		WHERE item.ysnFuelItem = CAST(0 AS BIT) 
			AND store.intStoreId = @intStoreId
			AND uom.strLongUPCCode IS NOT NULL
			AND uom.strLongUPCCode <> ''
			AND uom.strLongUPCCode <> '0'
			AND uom.strLongUPCCode NOT LIKE '%[^0-9]%'
			AND LEN(uom.strLongUPCCode) > 13
			AND (
					(
							(@ysnExportEntirePricebookFile = CAST(0 AS BIT)  AND  @strCategoryCode <> 'whitespaces')
							AND
							(
								category.intCategoryId IN(SELECT * FROM dbo.fnSplitString(@strCategoryCode,','))
							)
							OR
							(@ysnExportEntirePricebookFile = CAST(0 AS BIT)  AND  @strCategoryCode = 'whitespaces')
							AND
							(
								category.intCategoryId = category.intCategoryId
							)
							OR 
							(@ysnExportEntirePricebookFile = CAST(1 AS BIT))
							AND
							(
								1=1
							)
					)
				)



		IF EXISTS(SELECT TOP 1 1 FROM @tempInvalidUpc)
			BEGIN

				SELECT @strInvalidUPCs = COALESCE(@strInvalidUPCs + ', ' + strLongUPCCode, strLongUPCCode) 
				FROM @tempInvalidUpc

				SET @strMessageResult = @strMessageResult + 'Invalid UPC found and were not added to ' + @strFilePrefix + ' file: (' + @strInvalidUPCs + '). ' + CHAR(13)

			END
		-- =======================================================================================================================================================
		-- [END] - Check if has UPC longer than 13 digits
		-- =======================================================================================================================================================





		-- =======================================================================================================================================================
		-- Requirements
		-- 1. User role permision should have same location as Store						( System Manager -> Users -> User tab -> User Roles tab )
		-- 2. The Item's category should have same location as Store in Category Location   ( Inventory -> Categories -> Point of Sales tab )
		-- 3. The Item's UPC should have value. This should not be null or empty			( Inventory -> Items -> Unit of Measure panel )
		-- =======================================================================================================================================================





		-- PASSPORT
		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				IF(@strXmlVersion = '3.4')
					BEGIN
						-- Create Temp Table
						DECLARE @tblTempPassportITT TABLE 
						(
							[intTHPassportITTId]					INT IDENTITY (1, 1)							NOT NULL, 
							[strTHRegisterVersion]					NVARCHAR(5) COLLATE Latin1_General_CI_AS	NULL,

							[strTHStoreLocationID]					NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL,
							[strTHVendorName]						NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL,
							[strTHVendorModelVersion]				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NULL,

							[strIMTableAction]						NVARCHAR(20) COLLATE Latin1_General_CI_AS	NULL,
							[strIMRecordAction]						NVARCHAR(20) COLLATE Latin1_General_CI_AS	NULL,

							[strITTDetailRecordActionType]			NVARCHAR(20) COLLATE Latin1_General_CI_AS	NULL,
	
							[strICPOSCodeFormatFormat]				NVARCHAR(10) COLLATE Latin1_General_CI_AS	NULL,
							[strICPOSCode]							NVARCHAR(20) COLLATE Latin1_General_CI_AS	NULL,
							[strICPOSCodeModifier]					NVARCHAR(5) COLLATE Latin1_General_CI_AS	NULL,

							[strITTDataActiveFlgValue]				NVARCHAR(5) COLLATE Latin1_General_CI_AS	NULL,
							[dblITTDataInventoryValuePrice]			NUMERIC(18, 2)								NULL,
							--[intITTDataMerchandiseCode]			INT										NULL,
							[strITTDataMerchandiseCode]				NVARCHAR(20) COLLATE Latin1_General_CI_AS	NULL,
							[dblITTDataRegularSellPrice]			NUMERIC(18, 2)								NULL,
							[strITTDataDescription]					NVARCHAR(150) COLLATE Latin1_General_CI_AS	NULL,
							[strITTDataLinkCode]					NVARCHAR(20) COLLATE Latin1_General_CI_AS	NULL,
							[strITTDataPaymentSystemsProductCode]	NVARCHAR(10) COLLATE Latin1_General_CI_AS	NULL,
							[dblITTDataSellingUnits]				DECIMAL(18, 2),
							[intITTDataTaxStrategyId]				INT											NULL,
							[intITTDataPriceMethodCode]				INT											NULL,
							[strITTDataReceiptDescription]			NVARCHAR(100) COLLATE Latin1_General_CI_AS	NULL,
							[ysnITTDataFoodStampableFlg]			BIT											NULL,
							[ysnITTDataQuantityRequiredFlg]			BIT											NULL,
							[dblTransactionQtyLimit]				DECIMAL(18, 2)								NULL					--ST-1871 Jull Requirements
						)


						INSERT INTO @tblTempPassportITT 
						( 
							[strTHRegisterVersion],

							[strTHStoreLocationID],
							[strTHVendorName],
							[strTHVendorModelVersion],

							[strIMTableAction],
							[strIMRecordAction],

							[strITTDetailRecordActionType],
	
							[strICPOSCodeFormatFormat],
							[strICPOSCode],
							[strICPOSCodeModifier],

							[strITTDataActiveFlgValue],
							[dblITTDataInventoryValuePrice],
							[strITTDataMerchandiseCode],
							[dblITTDataRegularSellPrice],
							[strITTDataDescription],
							[strITTDataLinkCode],
							[strITTDataPaymentSystemsProductCode],
							[dblITTDataSellingUnits],
							[intITTDataTaxStrategyId],
							[intITTDataPriceMethodCode],
							[strITTDataReceiptDescription],
							[ysnITTDataFoodStampableFlg],
							[ysnITTDataQuantityRequiredFlg],
							[dblTransactionQtyLimit]
						)
						SELECT DISTINCT
							[strTHRegisterVersion]				= register.strXmlVersion,

							[strTHStoreLocationID]				= ST.intStoreNo,
							[strTHVendorName]					= 'iRely',
							[strTHVendorModelVersion]			= (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),

							[strIMTableAction]					= 'update',
							[strIMRecordAction]					= 'addchange',

							[strITTDetailRecordActionType]		= CASE
																	WHEN item.strStatus = 'Active' 
																		THEN 'addchange' 
																	WHEN item.strStatus = 'Phased Out' 
																		THEN 'delete' 
																	ELSE 'addchange' 
																END,
	
							[strICPOSCodeFormatFormat]			= PCF.strPosCodeFormat,
							[strICPOSCode]						= PCF.strUPCwthOrwthOutCheckDigit, --IUOM.strLongUPCCode, -- IF PASSPORT DO NOT include check digit
							[strICPOSCodeModifier]				= '0',

							[strITTDataActiveFlgValue]			= CASE 
																	WHEN item.strStatus = 'Active' 
																		THEN 'yes' 
																	ELSE 'no' 
																END,
							[dblITTDataInventoryValuePrice]		= CASE
																	WHEN (GETDATE() BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
																		THEN SplPrc.dblUnitAfterDiscount 
																	WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = IL.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC))
																		THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = IL.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
																	ELSE Prc.dblSalePrice
																END, 
							[strITTDataMerchandiseCode]			= CatLoc.strCashRegisterDepartment,
							[dblITTDataRegularSellPrice]		= CASE 
																	WHEN (GETDATE() BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
																		THEN SplPrc.dblUnitAfterDiscount 
																	WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																							WHERE EIP.intItemLocationId = IL.intItemLocationId
																							AND GETDATE() >= dtmEffectiveRetailPriceDate
																							ORDER BY dtmEffectiveRetailPriceDate ASC))
																		THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = IL.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
																	ELSE Prc.dblSalePrice 
																END,
							[strITTDataDescription]				= item.strDescription,
							[strITTDataLinkCode]				= CASE
																	WHEN uomDepositPlu.intItemUOMId IS NOT NULL
																		THEN uomDepositPlu.strLongUPCCode
																	ELSE NULL
																END,
							[strITTDataPaymentSystemsProductCode] = CASE 
																		WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = '0'
																			THEN '7' 
																		ELSE SubCat.strRegProdCode 
																	END,
							[dblITTDataSellingUnits]			= CAST(IUOM.dblUnitQty AS NUMERIC(18,2)),
							[intITTDataTaxStrategyId]			= CASE	
																	WHEN IL.ysnTaxFlag1 = 1 
																		THEN register.intTaxStrategyIdForTax1 
																	WHEN IL.ysnTaxFlag2 = 1 
																		THEN register.intTaxStrategyIdForTax2 
																	WHEN IL.ysnTaxFlag3 = 1 
																		THEN register.intTaxStrategyIdForTax3 
																	WHEN IL.ysnTaxFlag4 = 1 
																		THEN register.intTaxStrategyIdForTax4
																	ELSE register.intNonTaxableStrategyId
																END,
							[intITTDataPriceMethodCode]			= 0,
							[strITTDataReceiptDescription]		= CASE
																	WHEN ISNULL(item.strShortName, '') != ''
																		THEN item.strShortName
																	ELSE item.strDescription
																END,
							[ysnITTDataFoodStampableFlg]		= ISNULL(IL.ysnFoodStampable, 0),
							[ysnITTDataQuantityRequiredFlg]		= ISNULL(IL.ysnQuantityRequired, 0),
							[dblTransactionQtyLimit]			= IL.dblTransactionQtyLimit													--ST-1871 Jull Requirements
						FROM tblICItem item
						INNER JOIN tblICCategory Cat 
							ON Cat.intCategoryId = item.intCategoryId
						INNER JOIN dbo.tblICCategoryLocation AS CatLoc 
							ON CatLoc.intCategoryId = Cat.intCategoryId 
						INNER JOIN 
						(
							SELECT DISTINCT intItemId FROM @tempTableItems 
						) AS tmpItem 
							ON tmpItem.intItemId = item.intItemId 
						INNER JOIN tblICItemLocation IL 
							ON IL.intItemId = item.intItemId
						LEFT JOIN tblSTSubcategoryRegProd SubCat 
							ON SubCat.intRegProdId = IL.intProductCodeId
						INNER JOIN tblSTStore ST 
							ON IL.intLocationId = ST.intCompanyLocationId
							AND CatLoc.intLocationId = ST.intCompanyLocationId
						INNER JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = ST.intCompanyLocationId
						INNER JOIN tblICItemUOM AS IUOM 
							ON IUOM.intItemId = item.intItemId 
						INNER JOIN vyuSTItemUOMPosCodeFormat PCF
							ON IUOM.intItemUOMId = PCF.intItemUOMId
						INNER JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						INNER JOIN tblSTRegister	register 
							ON register.intRegisterId = ST.intRegisterId
						INNER JOIN tblICItemPricing Prc 
							ON Prc.intItemLocationId = IL.intItemLocationId
						LEFT JOIN tblICItemSpecialPricing SplPrc 
							ON SplPrc.intItemId = item.intItemId
						LEFT JOIN tblICItemUOM uomDepositPlu
							ON IL.intDepositPLUId = uomDepositPlu.intItemUOMId
						WHERE item.ysnFuelItem = CAST(0 AS BIT) 
							AND ST.intStoreId = @intStoreId
							AND IUOM.strLongUPCCode IS NOT NULL
							AND IUOM.strLongUPCCode NOT LIKE '%[^0-9]%'
							AND ISNULL(SUBSTRING(IUOM.strLongUPCCode, PATINDEX('%[^0]%',IUOM.strLongUPCCode), LEN(IUOM.strLongUPCCode)), 0) NOT IN ('')
							AND (
									(
										(@ysnExportEntirePricebookFile = CAST(0 AS BIT)  AND  @strCategoryCode <> 'whitespaces')
										AND
										(
											Cat.intCategoryId IN(SELECT * FROM dbo.fnSplitString(@strCategoryCode,','))
										)
										OR
										(@ysnExportEntirePricebookFile = CAST(0 AS BIT)  AND  @strCategoryCode = 'whitespaces')
										AND
										(
											Cat.intCategoryId = Cat.intCategoryId
										)
										OR 
										(@ysnExportEntirePricebookFile = CAST(1 AS BIT))
										AND
										(
											1=1
										)
									)
								)
								


----TEST 
--SELECT '@tblTempPassportITT', * FROM @tblTempPassportITT								
								

								IF EXISTS(SELECT TOP 1 1 FROM @tblTempPassportITT)
									BEGIN
										
										SELECT @xml =
										(
											SELECT 
												itt.strTHStoreLocationID			AS 'TransmissionHeader/StoreLocationID',
												itt.strTHVendorName					AS 'TransmissionHeader/VendorName',
												itt.strTHVendorModelVersion			AS 'TransmissionHeader/VendorModelVersion',
												(
													SELECT
														'update'					AS 'TableAction/@type',
														'addchange'					AS 'RecordAction/@type',
														(	
															SELECT
																ITTDetail.strITTDetailRecordActionType			AS [RecordAction/@type],
																(
																	SELECT
																		ItemCode.strICPOSCodeFormatFormat		AS [POSCodeFormat/@format],
																		ItemCode.strICPOSCode					AS [POSCode],
																		ItemCode.strICPOSCodeModifier			AS [POSCodeModifier]
																	FROM 
																	(
																		SELECT DISTINCT
																			[strICPOSCodeFormatFormat],
																			[strICPOSCode],
																			[strICPOSCodeModifier]
																		FROM @tblTempPassportITT
																	) ItemCode
																	WHERE ItemCode.strICPOSCode = ITTDetail.strICPOSCode
																	FOR XML PATH('ItemCode'), TYPE
																),
																(
																	SELECT
																		ITTData.strITTDataActiveFlgValue			AS [ActiveFlg/@value],
																		ITTData.dblITTDataInventoryValuePrice		AS [InventoryValuePrice],
																		ITTData.strITTDataMerchandiseCode			AS [MerchandiseCode],
																		ITTData.dblITTDataRegularSellPrice			AS [RegularSellPrice],
																		ITTData.strITTDataDescription				AS [Description],
																		ITTData.strITTDataLinkCode					AS [LinkCode],
																		ITTData.strITTDataPaymentSystemsProductCode	AS [PaymentSystemsProductCode],
																		ITTData.dblITTDataSellingUnits				AS [SellingUnits],
																		ITTData.intITTDataTaxStrategyId				AS [TaxStrategyId],
																		ITTData.intITTDataPriceMethodCode			AS [PriceMethodCode],
																		ITTData.strITTDataReceiptDescription		AS [ReceiptDescription],
																		ITTData.ysnITTDataFoodStampableFlg			AS [FoodStampableFlg],
																		ITTData.ysnITTDataQuantityRequiredFlg		AS [QuantityRequiredFlg],
																		(
																			SELECT
																				ItemTransactionLimit.dblTransactionQtyLimit		AS [TransactionLimit]
																			FROM 
																			(
																				SELECT DISTINCT
																					[strICPOSCode],
																					[dblTransactionQtyLimit]
																				FROM @tblTempPassportITT
																			) ItemTransactionLimit
																			WHERE ItemTransactionLimit.strICPOSCode = ITTDetail.strICPOSCode
																			FOR XML PATH('SalesRestriction'), TYPE
																		)
																	FROM 
																	(
																		SELECT DISTINCT
																			[strICPOSCode],
																			[strITTDataActiveFlgValue],
																			[dblITTDataInventoryValuePrice],
																			[strITTDataMerchandiseCode],
																			[dblITTDataRegularSellPrice],
																			[strITTDataDescription],
																			[strITTDataLinkCode],
																			[strITTDataPaymentSystemsProductCode],
																			[dblITTDataSellingUnits],
																			[intITTDataTaxStrategyId],
																			[intITTDataPriceMethodCode],
																			[strITTDataReceiptDescription],
																			[ysnITTDataFoodStampableFlg],
																			[ysnITTDataQuantityRequiredFlg],
																			[dblTransactionQtyLimit]
																		FROM @tblTempPassportITT
																	) ITTData
																	WHERE ITTData.strICPOSCode = ITTDetail.strICPOSCode
																	FOR XML PATH('ITTData'), TYPE
																)
															FROM 
															(
																SELECT DISTINCT
																	[strITTDetailRecordActionType],
																	[strICPOSCode]
																FROM @tblTempPassportITT
															) ITTDetail
															ORDER BY ITTDetail.strICPOSCode ASC
															FOR XML PATH('ITTDetail'), TYPE
														)
													FOR XML PATH('ItemMaintenance'), TYPE
												)
											FROM 
											(
												SELECT DISTINCT
													[strTHStoreLocationID],
													[strTHVendorName],
													[strTHVendorModelVersion]
												FROM @tblTempPassportITT
											) itt
											FOR XML PATH('NAXML-MaintenanceRequest'), TYPE
										);

										DECLARE @strVersion NVARCHAR(50) = '3.4'

										-- INSERT Attributes 'page' and 'ofpages' to Root header
										SET @xml.modify('insert 
														(
															attribute version { 
																				sql:variable("@strVersion")
																			  }		   
														) into (/*:NAXML-MaintenanceRequest)[1]');


										SET @strXML = CAST(@xml AS NVARCHAR(MAX))
										SET @strGeneratedXML = REPLACE(@strXML, '><', '>' + CHAR(13) + '<')
										SET @ysnSuccessResult = CAST(1 AS BIT)




										-- INSERT TO UPDATE REGISTER PREVIEW TABLE
										INSERT INTO tblSTUpdateRegisterItemReport
										(
											strGuid, 
											intStoreId,
											strActionType,
											strUpcCode,
											strDescription,
											dblSalePrice,
											ysnSalesTaxed,
											ysnIdRequiredLiquor,
											ysnIdRequiredCigarette,
											strRegProdCode,
											intItemId,
											intConcurrencyId
										)
										SELECT 
											strGuid = @strGuid,
											intStoreId = (SELECT intStoreNo FROM tblSTStore WHERE intStoreId = @intStoreId),
											strActionType = t1.strActionType,
											strUpcCode = t1.strUpcCode,
											strDescription = t1.strDescription,
											dblSalePrice = CASE
																	WHEN (GETDATE() BETWEEN t1.dtmBeginDate AND t1.dtmEndDate)
																		THEN t1.dblUnitAfterDiscount 
																	WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = t1.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC))
																		THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = t1.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
																	ELSE t1.dblSalePrice
																END,

											ysnSalesTaxed = t1.ysnSalesTaxed,
											ysnIdRequiredLiquor = t1.ysnIdRequiredLiquor,
											ysnIdRequiredCigarette = t1.ysnIdRequiredCigarette,
											strRegProdCode = t1.strRegProdCode,
											intItemId = t1.intItemId,
											intConcurrencyId = 1
										FROM  
										(
										SELECT *,
												rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
											FROM 
												(
													SELECT DISTINCT
														CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
														, IUOM.strLongUPCCode AS strUpcCode
														, I.strDescription AS strDescription
														, Prc.dblSalePrice AS dblSalePrice
														, IL.intItemLocationId AS intItemLocationId
														, IL.ysnTaxFlag1 AS ysnSalesTaxed
														, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
														, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
														, SubCat.strRegProdCode AS strRegProdCode
														, I.intItemId AS intItemId
														, SplPrc.dtmBeginDate AS dtmBeginDate
														, SplPrc.dtmEndDate AS dtmEndDate
														, SplPrc.dblUnitAfterDiscount AS dblUnitAfterDiscount
													FROM tblICItem I
													JOIN tblICCategory Cat 
														ON Cat.intCategoryId = I.intCategoryId
													JOIN @tempTableItems tmpItem 
														ON tmpItem.intItemId = I.intItemId
													JOIN tblICItemLocation IL 
														ON IL.intItemId = I.intItemId
													LEFT JOIN tblSTSubcategoryRegProd SubCat 
														ON SubCat.intRegProdId = IL.intProductCodeId
													JOIN tblSTStore ST 
														--ON ST.intStoreId = SubCat.intStoreId
														ON IL.intLocationId = ST.intCompanyLocationId
													JOIN tblSMCompanyLocation L 
														ON L.intCompanyLocationId = IL.intLocationId
													JOIN tblICItemUOM IUOM 
														ON IUOM.intItemId = I.intItemId
													JOIN tblICUnitMeasure IUM 
														ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
													JOIN tblSTRegister R 
														ON R.intStoreId = ST.intStoreId
													JOIN tblICItemPricing Prc 
														ON Prc.intItemLocationId = IL.intItemLocationId
													LEFT JOIN tblICItemSpecialPricing SplPrc 
														ON SplPrc.intItemId = I.intItemId
													WHERE I.ysnFuelItem = CAST(0 AS BIT) 
														AND ST.intStoreId = @intStoreId
														AND IUOM.strLongUPCCode IS NOT NULL
														AND IUOM.strLongUPCCode NOT LIKE '%[^0-9]%'
														AND ISNULL(SUBSTRING(IUOM.strLongUPCCode, PATINDEX('%[^0]%',IUOM.strLongUPCCode), LEN(IUOM.strLongUPCCode)), 0) NOT IN ('') -- NOT IN ('0', '')
												) as t
										) t1
										WHERE rn = 1

									END
								ELSE
									BEGIN
										SET @strGeneratedXML = ''
										SET @ysnSuccessResult = CAST(0 AS BIT)
										SET @strMessageResult = @strMessageResult + 'No result found to generate Pricebook - ' + @strFilePrefix + ' Outbound file. '

										GOTO ExitWithRollback
									END




								
					END
			END
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				--Insert data into Procebook staging table	
				IF(@ysnExportEntirePricebookFile = CAST(1 AS BIT))
					BEGIN
						INSERT INTO tblSTstgPricebookSendFile
						SELECT DISTINCT
							ST.intStoreNo [StoreLocationID]
							, 'iRely' [VendorName]  	
							, 'Rel. 13.2.0' [VendorModelVersion]
							, 'update' [TableActionType]
							, 'addchange' [RecordActionType] 
							, CONVERT(nvarchar(10), GETDATE(), 21) [RecordActionEffectiveDate]
							, CASE I.strStatus WHEN 'Active' THEN 'addchange' WHEN 'Phased Out' THEN 'delete' ELSE 'addchange' END as [ITTDetailRecordActionType] 
							, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN 'plu' ELSE 'upcA' END [POSCodeFormat]
							, CASE	WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
									ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
								END [POSCode]
							, IUM.strUnitMeasure [PosCodeModifierName] 
							, '0' [PosCodeModifierValue] 
							, CASE I.strStatus WHEN 'Active' THEN 'yes' ELSE 'no' END as [ActiveFlagValue]
							, CASE WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																							WHERE EIP.intItemLocationId = IL.intItemLocationId
																							AND GETDATE() >= dtmEffectiveRetailPriceDate
																							ORDER BY dtmEffectiveRetailPriceDate ASC))
																		THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = IL.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
																ELSE Prc.dblSalePrice
								END AS [InventoryValuePrice]
							, Cat.strCategoryCode [MerchandiseCode]
							, CASE WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate 
									THEN SplPrc.dblUnitAfterDiscount 
								   WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																						WHERE EIP.intItemLocationId = IL.intItemLocationId
																						AND GETDATE() >= dtmEffectiveRetailPriceDate
																						ORDER BY dtmEffectiveRetailPriceDate ASC))
																	THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																							WHERE EIP.intItemLocationId = IL.intItemLocationId
																							AND GETDATE() >= dtmEffectiveRetailPriceDate
																							ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
								ELSE 
									Prc.dblSalePrice 
							END  [RegularSellPrice]
							, I.strDescription [Description]
							, 'item' [LinkCodeType]
							, NULL [LinkCodeValue]
							, CASE WHEN IL.intItemTypeCode = 0 THEN 1 WHEN (@XMLGatewayVersion = '3.30' AND IL.ysnCarWash = 1) 
								THEN 10 ElSE ISNULL(IL.intItemTypeCode,1) END [ItemTypeCode]
							, CASE WHEN IL.intItemTypeCode = 0 THEN 1 WHEN (@XMLGatewayVersion = '3.30' AND IL.ysnCarWash = 1) 
								THEN 1 ElSE ISNULL(IL.intItemTypeSubCode,1) END [ItemTypeSubCode]
							, CASE WHEN R.strRegisterClass = @strRegisterClass 
										THEN CASE WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = 0 THEN 7 
											ELSE SubCat.strRegProdCode 
										END 
									ELSE  ISNULL(SubCat.strRegProdCode, '40') 
								END [PaymentSystemsProductCode]
							, CASE	WHEN IL.ysnFoodStampable = 1 THEN 4096 WHEN IL.ysnFoodStampable = 0 THEN 2048 
									WHEN IL.ysnIdRequiredLiquor = 1 THEN 4 WHEN IL.ysnIdRequiredCigarette = 1 THEN 2 
									WHEN IL.ysnOpenPricePLU = 1 THEN 128
									ELSE 2048
								END [SalesRestrictCode]
							, IUOM.dblUnitQty [SellingUnits]
							, CASE	WHEN IL.ysnTaxFlag1 = 1 THEN R.intTaxStrategyIdForTax1 WHEN IL.ysnTaxFlag2 = 1 THEN R.intTaxStrategyIdForTax2 
									WHEN IL.ysnTaxFlag3 = 1 THEN R.intTaxStrategyIdForTax3 WHEN IL.ysnTaxFlag4 = 1 THEN R.intTaxStrategyIdForTax4
									ELSE R.intNonTaxableStrategyId
								END [TaxStrategyID]	
							, 'ICR' [ProhibitSaleLocationType]	
							, CASE WHEN (@XMLGatewayVersion = '3.30' AND ISNULL(SubCat.strRegProdCode, '40') = '102') THEN 'No' 
									WHEN (@XMLGatewayVersion = '3.30' AND ISNULL(SubCat.strRegProdCode, '40') <> '102') THEN 'Yes' 
									WHEN (@XMLGatewayVersion = '3.41' AND IL.ysnCarWash = 1) THEN 'No' 
									WHEN (@XMLGatewayVersion = '3.41' AND IL.ysnCarWash = 0) THEN 'Yes' 
									ELSE 'Yes'
								END [ProhibitSaleLocationValue]	
							, CASE WHEN IL.ysnApplyBlueLaw1 = 1 THEN 110 ELSE NULL END [SalesRestrictionStrategyID]
							, 0 [PriceMethodCode]
							, IL.strDescription [ReceiptDescription]
							, IL.ysnFoodStampable [FoodStampableFlg]
							, IL.ysnPromotionalItem [DiscountableFlg]
							, IL.ysnQuantityRequired [QuantityRequiredFlg]
							, CASE WHEN R.strRegisterClass = @strRegisterClass
										THEN CASE WHEN R.strRegisterName = 'Sapphire' THEN RIGHT('0000000000000'+ISNULL(IUOM.strLongUPCCode,''),13) 
											WHEN R.strRegisterName = 'Commander' THEN 
												CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
													THEN IUOM.strUpcCode 
													ELSE RIGHT('0000000000000'+ISNULL(IUOM.strLongUPCCode,''),13) 
												END
										END 
									ELSE  NULL 
								END [UPCValue]
							, 'absent' [UPCCheckDigit]
							, 'keyboard' [UPCSource]
							, IL.intDepositPLUId [Fee]	
							, CASE WHEN IL.ysnPromotionalItem = 1 THEN '1' ELSE NULL END [FlagSysId1]
							, CASE WHEN IL.ysnSaleable = 0 THEN '2' ELSE NULL END [FlagSysId2]
							, CASE WHEN IL.ysnReturnable = 0 THEN '3' ELSE NULL END [FlagSysId3]
							, CASE WHEN IL.ysnFoodStampable = 1 THEN '4' ELSE NULL END [FlagSysId4]
							, CASE WHEN IL.ysnTaxFlag1 = 1 THEN '1' ELSE NULL END [TaxRateSysId1]
							, CASE WHEN IL.ysnTaxFlag2 = 1 THEN '2' ELSE NULL END [TaxRateSysId2]
							, CASE WHEN IL.ysnTaxFlag3 = 1 THEN '3' ELSE NULL END [TaxRateSysId3]
							, CASE WHEN IL.ysnTaxFlag4 = 1 THEN '4' ELSE NULL END [TaxRateSysId4]
							, CASE WHEN IL.ysnIdRequiredLiquor = 1 THEN '1' ELSE NULL END [IdCheckSysId1]
							, CASE WHEN IL.ysnIdRequiredCigarette = 1 THEN '2' ELSE NULL END [IdCheckSysId2]
							, CASE WHEN IL.ysnApplyBlueLaw1 = 1 THEN '1' ELSE NULL END [BlueLawSysId1]
							, CASE WHEN IL.ysnApplyBlueLaw2 = 1 THEN '2' ELSE NULL END [BlueLawSysId2]
						FROM tblICItem I
						JOIN tblICCategory Cat 
							ON Cat.intCategoryId = I.intCategoryId
						JOIN 
						(
							SELECT DISTINCT intItemId FROM @tempTableItems 
						) AS tmpItem 
							ON tmpItem.intItemId = I.intItemId 
						JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						LEFT JOIN tblSTSubcategoryRegProd SubCat 
							ON SubCat.intRegProdId = IL.intProductCodeId
						JOIN tblSTStore ST 
							ON IL.intLocationId = ST.intCompanyLocationId
						JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = IL.intLocationId
						JOIN tblICItemUOM IUOM 
							ON IUOM.intItemId = I.intItemId 
						JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						JOIN tblSTRegister R 
							ON R.intRegisterId = ST.intRegisterId
						JOIN tblICItemPricing Prc 
							ON Prc.intItemLocationId = IL.intItemLocationId
						LEFT JOIN tblICItemSpecialPricing SplPrc 
							ON SplPrc.intItemId = I.intItemId
						WHERE I.ysnFuelItem = CAST(0 AS BIT) 
						AND R.intRegisterId = @intRegisterId 
						AND ST.intStoreId = @intStoreId

						--JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						--JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
						--JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
						--JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						--JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
						--JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
						--LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId
						--JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
						--JOIN tblICItemPricing Prc ON Prc.intItemId = I.intItemId
						--JOIN tblICItemSpecialPricing SplPrc ON SplPrc.intItemId = I.intItemId
						--JOIN @Tab_UpdatedItems tmpItem ON tmpItem.intItemId = I.intItemId 
						--AND ((@Category <>'whitespaces' AND Cat.intCategoryId IN(select * from dbo.fnSplitString(@Category,',')))
						--OR (@Category ='whitespaces'  AND Cat.intCategoryId = Cat.intCategoryId))

					END
				ELSE IF(@ysnExportEntirePricebookFile = CAST(0 AS BIT))
					BEGIN
						INSERT INTO tblSTstgPricebookSendFile
						SELECT DISTINCT
							ST.intStoreNo [StoreLocationID]
							, 'iRely' [VendorName]  	
							, 'Rel. 13.2.0' [VendorModelVersion]
							, 'update' [TableActionType]
							, 'addchange' [RecordActionType] 
							, CONVERT(nvarchar(10), GETDATE(), 21) [RecordActionEffectiveDate]
							, CASE I.strStatus WHEN 'Active' THEN 'addchange' WHEN 'Phased Out' THEN 'delete' ELSE 'addchange' END as [ITTDetailRecordActionType] 
							, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN 'plu' ELSE 'upcA' END [POSCodeFormat]
							, CASE	WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
									ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
								END [POSCode]
							, IUM.strUnitMeasure [PosCodeModifierName] 
							, '0' [PosCodeModifierValue] 
							, CASE I.strStatus WHEN 'Active' THEN 'yes' ELSE 'no' END as [ActiveFlagValue]
							, CASE WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																							WHERE EIP.intItemLocationId = IL.intItemLocationId
																							AND GETDATE() >= dtmEffectiveRetailPriceDate
																							ORDER BY dtmEffectiveRetailPriceDate ASC))
																		THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = IL.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
									ELSE Prc.dblSalePrice
								END AS[InventoryValuePrice]
							, Cat.strCategoryCode [MerchandiseCode]
							, CASE WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate THEN SplPrc.dblUnitAfterDiscount 
								   WHEN (GETDATE() < (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																									WHERE EIP.intItemLocationId = IL.intItemLocationId
																									AND GETDATE() <= dtmEffectiveRetailPriceDate
																									ORDER BY dtmEffectiveRetailPriceDate ASC))
																				THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																										WHERE EIP.intItemLocationId = IL.intItemLocationId
																										AND GETDATE() <= dtmEffectiveRetailPriceDate
																										ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
									ELSE Prc.dblSalePrice 
								END  [RegularSellPrice]
							, I.strDescription [Description]
							, 'item' [LinkCodeType]
							, NULL [LinkCodeValue]
							, CASE WHEN IL.intItemTypeCode = 0 THEN 1 WHEN (@XMLGatewayVersion = '3.30' AND IL.ysnCarWash = 1) 
								THEN 10 ElSE ISNULL(IL.intItemTypeCode,1) END [ItemTypeCode]
							, CASE WHEN IL.intItemTypeCode = 0 THEN 1 WHEN (@XMLGatewayVersion = '3.30' AND IL.ysnCarWash = 1) 
								THEN 1 ElSE ISNULL(IL.intItemTypeSubCode,1) END [ItemTypeSubCode]
							, CASE WHEN R.strRegisterClass = @strRegisterClass
										THEN CASE WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = 0 THEN 7 
											ELSE SubCat.strRegProdCode 
										END 
									ELSE  ISNULL(SubCat.strRegProdCode, '40') 
								END [PaymentSystemsProductCode]
							, CASE	WHEN IL.ysnFoodStampable = 1 THEN 4096 WHEN IL.ysnFoodStampable = 0 THEN 2048 
									WHEN IL.ysnIdRequiredLiquor = 1 THEN 4 WHEN IL.ysnIdRequiredCigarette = 1 THEN 2 
									WHEN IL.ysnOpenPricePLU = 1 THEN 128
									ELSE 2048
								END [SalesRestrictCode]
							, IUOM.dblUnitQty [SellingUnits]
							, CASE	WHEN IL.ysnTaxFlag1 = 1 THEN R.intTaxStrategyIdForTax1 WHEN IL.ysnTaxFlag2 = 1 THEN R.intTaxStrategyIdForTax2 
									WHEN IL.ysnTaxFlag3 = 1 THEN R.intTaxStrategyIdForTax3 WHEN IL.ysnTaxFlag4 = 1 THEN R.intTaxStrategyIdForTax4
									ELSE R.intNonTaxableStrategyId
								END [TaxStrategyID]	
							, 'ICR' [ProhibitSaleLocationType]	
							, CASE WHEN (@XMLGatewayVersion = '3.30' AND ISNULL(SubCat.strRegProdCode, '40') = '102') THEN 'No' 
									WHEN (@XMLGatewayVersion = '3.30' AND ISNULL(SubCat.strRegProdCode, '40') <> '102') THEN 'Yes' 
									WHEN (@XMLGatewayVersion = '3.41' AND IL.ysnCarWash = 1) THEN 'No' 
									WHEN (@XMLGatewayVersion = '3.41' AND IL.ysnCarWash = 0) THEN 'Yes' 
									ELSE 'Yes'
								END [ProhibitSaleLocationValue]	
							, CASE WHEN IL.ysnApplyBlueLaw1 = 1 THEN 110 ELSE NULL END [SalesRestrictionStrategyID]
							, 0 [PriceMethodCode]
							, IL.strDescription [ReceiptDescription]
							, IL.ysnFoodStampable [FoodStampableFlg]
							, IL.ysnPromotionalItem [DiscountableFlg]
							, IL.ysnQuantityRequired [QuantityRequiredFlg]
							, CASE WHEN R.strRegisterClass = @strRegisterClass 
										THEN CASE WHEN R.strRegisterName = 'Sapphire' THEN RIGHT('0000000000000'+ISNULL(IUOM.strLongUPCCode,''),13) 
											WHEN R.strRegisterName = 'Commander' THEN 
												CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
													THEN IUOM.strUpcCode 
													ELSE RIGHT('0000000000000'+ISNULL(IUOM.strLongUPCCode,''),13) 
												END
										END 
									ELSE  NULL 
								END [UPCValue]
							, 'absent' [UPCCheckDigit]
							, 'keyboard' [UPCSource]
							, IL.intDepositPLUId [Fee]	
							, CASE WHEN IL.ysnPromotionalItem = 1 THEN '1' ELSE NULL END [FlagSysId1]
							, CASE WHEN IL.ysnSaleable = 0 THEN '2' ELSE NULL END [FlagSysId2]
							, CASE WHEN IL.ysnReturnable = 0 THEN '3' ELSE NULL END [FlagSysId3]
							, CASE WHEN IL.ysnFoodStampable = 1 THEN '4' ELSE NULL END [FlagSysId4]
							, CASE WHEN IL.ysnTaxFlag1 = 1 THEN '1' ELSE NULL END [TaxRateSysId1]
							, CASE WHEN IL.ysnTaxFlag2 = 1 THEN '2' ELSE NULL END [TaxRateSysId2]
							, CASE WHEN IL.ysnTaxFlag3 = 1 THEN '3' ELSE NULL END [TaxRateSysId3]
							, CASE WHEN IL.ysnTaxFlag4 = 1 THEN '4' ELSE NULL END [TaxRateSysId4]
							, CASE WHEN IL.ysnIdRequiredLiquor = 1 THEN '1' ELSE NULL END [IdCheckSysId1]
							, CASE WHEN IL.ysnIdRequiredCigarette = 1 THEN '2' ELSE NULL END [IdCheckSysId2]
							, CASE WHEN IL.ysnApplyBlueLaw1 = 1 THEN '1' ELSE NULL END [BlueLawSysId1]
							, CASE WHEN IL.ysnApplyBlueLaw2 = 1 THEN '2' ELSE NULL END [BlueLawSysId2]
						from tblICItem I
						JOIN tblICCategory Cat 
							ON Cat.intCategoryId = I.intCategoryId
						JOIN 
						(
							SELECT DISTINCT intItemId FROM @tempTableItems 
						) AS tmpItem 
							ON tmpItem.intItemId = I.intItemId 
						JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						LEFT JOIN tblSTSubcategoryRegProd SubCat 
							ON SubCat.intRegProdId = IL.intProductCodeId
						JOIN tblSTStore ST 
							--ON ST.intStoreId = SubCat.intStoreId
							ON IL.intLocationId = ST.intCompanyLocationId
						JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = IL.intLocationId
						JOIN tblICItemUOM IUOM 
							ON IUOM.intItemId = I.intItemId 
						JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						JOIN tblSTRegister R 
							ON R.intRegisterId = ST.intRegisterId
						JOIN tblICItemPricing Prc 
							ON Prc.intItemLocationId = IL.intItemLocationId
						LEFT JOIN tblICItemSpecialPricing SplPrc 
							ON SplPrc.intItemId = I.intItemId
						WHERE I.ysnFuelItem = CAST(0 AS BIT) 
						AND R.intRegisterId = @intRegisterId 
						AND ST.intStoreId = @intStoreId
						AND (
								(
									@strCategoryCode <>'whitespaces' 
									AND 
									Cat.intCategoryId IN(
															SELECT * 
															FROM dbo.fnSplitString(@strCategoryCode,',')
														)
								)
								OR 
								(
									@strCategoryCode ='whitespaces'  
									AND 
									Cat.intCategoryId = Cat.intCategoryId
								)
						)

						--JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						--JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
						--JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
						--JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						--JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
						--JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
						--LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId
						--JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
						--JOIN tblICItemPricing Prc ON Prc.intItemId = I.intItemId
						--JOIN tblICItemSpecialPricing SplPrc ON SplPrc.intItemId = I.intItemId
						--JOIN @Tab_UpdatedItems tmpItem ON tmpItem.intItemId = I.intItemId

					END



				IF EXISTS(SELECT StoreLocationID FROM tblSTstgPricebookSendFile)
					BEGIN
							-- Generate XML for the pricebook data availavle in staging table
							Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPricebookSendFile~intPricebookSendFile > 0', 0, @strGeneratedXML OUTPUT

							--Once XML is generated delete the data from pricebook  staging table.
							DELETE FROM dbo.tblSTstgPricebookSendFile
					END
				ELSE 
					BEGIN
							-- Posible fix for (ITT) if has no result
							-- 1. Go to Store -> Register Product -> Product Code
							--     Make sure that there is Product Code setup and Location Code
							--    Now go to Item -> Item Location -> Product Code
							--     Make sure that there is Location Code setup same to Store
							--      and there is Product Code setup same to Store
							-- 2. Does not have Newly added items or modified items on selected date range

							SET @ysnSuccessResult = CAST(0 AS BIT)
							SET @strMessageResult = 'No result found to generate Pricebook - ' + @strFilePrefix + ' Outbound file'
					END	
			END
		ELSE IF(@strRegisterClass = 'SAPPHIRE/COMMANDER')
			BEGIN
				-- NO versioning for Register Class 'SAPPHIRE/COMMANDER'
				-- XML prefix is 'uPLUs'

				-- Create Temp Table
				DECLARE @tblTempSapphireCommanderUPLUs TABLE 
				(
					[intCommanderOutboundPLUsId] INT, 
					[intItemLocationId] INT, 
					[strSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[strUpc] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strUpcModifier] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
					[strDepartment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
					[strFee] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strPCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[dblPrice] DECIMAL(18, 2) NULL,
					[dblTransactionQtyLimit] DECIMAL(18, 2) NULL,

					[strFlagColumnType] NVARCHAR(50),
					[intFlagSysid] INT NULL, 

					[strTaxRateColumnType] NVARCHAR(50),
					[intTaxRateSysid] INT NULL, 

					[intIdCheckSysId] INT NULL,

					[intBlueLawsSysId] INT NULL,

					[dblSellUnit] DECIMAL(18, 6) NULL
				)

				-- Insert values to Temp table
				-- Refference http://inet.irelyserver.com/display/ST/Commander+-+XML+Pricebook+Export+Map+to+i21+Database
				INSERT INTO @tblTempSapphireCommanderUPLUs
				SELECT DISTINCT
					[intCommanderOutboundPLUsId]	=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))
					, [intItemLocationId]			=	ItemLoc.intItemLocationId
					, [strSource]					=	'keyboard'
					, [strUpc]						=	PCF.strUPCwthOrwthOutCheckDigit -- IF COMMANDER/SAPPHIRE include check digit
					, [strUpcModifier]				=	CAST(ISNULL(UOM.intModifier, '000') AS VARCHAR(100))
					, [strDescription]				=	LEFT(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(UOM.strUPCDescription, ''), Item.strDescription), '''', ''), '"', ''), '/', ''), '\', '')   , 40) 
					, [strDepartment]				=	CAST(CategoryLoc.strCashRegisterDepartment AS NVARCHAR(50))
					, [strFee]						=	CAST(ItemLoc.intBottleDepositNo AS NVARCHAR(10)) -- CAST(ISNULL(ItemLoc.intBottleDepositNo, '') AS NVARCHAR(10)) --'00'
					, [strPCode]					=	ISNULL(StorePCode.strRegProdCode, '') -- ISNULL(StorePCode.strRegProdCode, '')
					, [dblPrice]					=	itemPricing.dblSalePrice
					, [dblTransactionQtyLimit]		=	ItemLoc.dblTransactionQtyLimit
					, [strFlagColumnType]			=	UNPIVOTItemLoc.strColumnName
					, [intFlagSysid]				=	CASE
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnPromotionalItem' -- Always INCLUDE
																THEN 1
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnReturnable' AND UNPIVOTItemLoc.ysnValue = 1
																THEN 3
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnFoodStampable'  AND UNPIVOTItemLoc.ysnValue = 1
																THEN 4
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnOpenPricePLU'  AND UNPIVOTItemLoc.ysnValue = 1
																THEN 6
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnScaleItem' AND UNPIVOTItemLoc.ysnValue = 1
																THEN 8
														END
					, [strTaxRateColumnType]		=   UNPIVOTItemLoc.strColumnName
					, [intTaxRateSysid]				=	CASE
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnTaxFlag1' AND UNPIVOTItemLoc.ysnValue = 1
																THEN 1
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnTaxFlag2' AND UNPIVOTItemLoc.ysnValue = 1
																THEN 2
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnTaxFlag3'  AND UNPIVOTItemLoc.ysnValue = 1
																THEN 3
															WHEN UNPIVOTItemLoc.strColumnName = 'ysnTaxFlag4'  AND UNPIVOTItemLoc.ysnValue = 1
																THEN 4
														END
					, [intIdCheckSysId]				=	CASE
															WHEN (UNPIVOTItemLoc.strColumnName = 'ysnIdRequiredLiquor') AND  UNPIVOTItemLoc.ysnValue = 1
																THEN 1
															WHEN (UNPIVOTItemLoc.strColumnName = 'ysnIdRequiredCigarette') AND  UNPIVOTItemLoc.ysnValue = 1
																THEN 2
														END
					, [intBlueLawsSysId]			=	CASE
															WHEN (UNPIVOTItemLoc.strColumnName = 'ysnApplyBlueLaw1') AND  UNPIVOTItemLoc.ysnValue = 1
																THEN 1
															WHEN (UNPIVOTItemLoc.strColumnName = 'ysnApplyBlueLaw2') AND  UNPIVOTItemLoc.ysnValue = 1
																THEN 2
														END
					, [dblSellUnit]					=	1
				FROM tblICItem Item
				INNER JOIN 
				(
					SELECT DISTINCT intItemId
					FROM @tempTableItems
				) tempItem
					ON Item.intItemId = tempItem.intItemId
				INNER JOIN tblICItemUOM UOM
					ON Item.intItemId = UOM.intItemId
				INNER JOIN tblICCategory Category
					ON Item.intCategoryId = Category.intCategoryId
				INNER JOIN dbo.tblICCategoryLocation CategoryLoc 
					ON Category.intCategoryId = CategoryLoc.intCategoryId
				INNER JOIN tblSTStore Store
					ON CategoryLoc.intLocationId = Store.intCompanyLocationId
				INNER JOIN tblICItemLocation ItemLoc
					ON Item.intItemId = ItemLoc.intItemId
					AND Store.intCompanyLocationId = ItemLoc.intLocationId
				INNER JOIN tblSTSubcategoryRegProd StorePCode
					ON StorePCode.intRegProdId = ItemLoc.intProductCodeId
				INNER JOIN 
				(
						SELECT 
						   intPrimaryId
						   , strColumnName
						   , ysnValue
						FROM 
						(
							SELECT
								intItemLocationId

								-- Flags
							   , ISNULL(ysnPromotionalItem, 0) AS ysnPromotionalItem 
							   , ysnReturnable
							   , ysnFoodStampable
							   , ysnOpenPricePLU
							   , ysnScaleItem

							   -- taxRates
							   , ysnTaxFlag1			-- [sysid=1]
							   , ysnTaxFlag2			-- [sysid=2]
							   , ysnTaxFlag3			-- [sysid=3]
							   , ysnTaxFlag4			-- [sysid=4]

							   -- idChecks
							   , ysnIdRequiredLiquor	-- [sysid=1]
							   , ysnIdRequiredCigarette -- [sysid=2]

							   -- blueLaws
							   , ysnApplyBlueLaw1		-- [sysid=1]
							   , ysnApplyBlueLaw2		-- [sysid=2]
							FROM tblICItemLocation
						) t
						UNPIVOT
						(
							intPrimaryId FOR intItemLocationIds IN (intItemLocationId)
						) o
						UNPIVOT
						(
							ysnValue FOR strColumnName IN (
															-- Flags
														   ysnPromotionalItem	 
														   , ysnReturnable
														   , ysnFoodStampable
														   , ysnOpenPricePLU
														   , ysnScaleItem

														   -- taxRates
														   , ysnTaxFlag1			-- [sysid=1]
														   , ysnTaxFlag2			-- [sysid=2]
														   , ysnTaxFlag3			-- [sysid=3]
														   , ysnTaxFlag4			-- [sysid=4]

														   -- idChecks
														   , ysnIdRequiredLiquor	-- [sysid=1]
														   , ysnIdRequiredCigarette -- [sysid=2]

														   -- blueLaws
														   , ysnApplyBlueLaw1		-- [sysid=1]
														   , ysnApplyBlueLaw2		-- [sysid=2]
														  )
						) n
						WHERE n.ysnValue = 1
							OR n.strColumnName = 'ysnPromotionalItem'
				) UNPIVOTItemLoc
					ON ItemLoc.intItemLocationId = UNPIVOTItemLoc.intPrimaryId
				INNER JOIN vyuSTItemUOMPosCodeFormat PCF
					ON Item.intItemId = PCF.intItemId
					AND UOM.intItemUOMId = PCF.intItemUOMId
					AND ItemLoc.intLocationId = PCF.intLocationId
				JOIN vyuSTItemHierarchyPricing itemPricing
					ON Item.intItemId = itemPricing.intItemId
					AND ItemLoc.intItemLocationId = itemPricing.intItemLocationId
					AND UOM.intItemUOMId = itemPricing.intItemUOMId
				WHERE Store.intStoreId = @intStoreId
					AND UOM.strLongUPCCode IS NOT NULL
					AND UOM.strLongUPCCode NOT LIKE '%[^0-9]%'
					AND ISNULL(SUBSTRING(PCF.strUPCwthOrwthOutCheckDigit, PATINDEX('%[^0]%', PCF.strUPCwthOrwthOutCheckDigit), LEN(PCF.strUPCwthOrwthOutCheckDigit)), 0) NOT IN ('')
				ORDER BY PCF.strUPCwthOrwthOutCheckDigit ASC


				IF EXISTS(SELECT TOP 1 1 FROM @tblTempSapphireCommanderUPLUs)
					BEGIN
						
						-- -----------------------------------------------------------------------------
						-- [Start] - Create Preview
						-- -----------------------------------------------------------------------------
						-- INSERT TO UPDATE REGISTER PREVIEW TABLE
						INSERT INTO tblSTUpdateRegisterItemReport
						(
							strGuid, 
							intStoreId,
							strActionType,
							strUpcCode,
							strDescription,
							strUnitMeasure,
							dblSalePrice,
							ysnSalesTaxed,
							ysnIdRequiredLiquor,
							ysnIdRequiredCigarette,
							strRegProdCode,
							intItemId,
							intConcurrencyId
						)
						SELECT 
							strGuid = @strGuid,
							intStoreId = (SELECT intStoreNo FROM tblSTStore WHERE intStoreId = @intStoreId),
							strActionType = t1.strActionType,
							strUpcCode = t1.strUpcCode,
							strDescription = t1.strDescription,
							strUnitMeasure = t1.strUnitMeasure,
							dblSalePrice = t1.dblSalePrice,
							ysnSalesTaxed = t1.ysnSalesTaxed,
							ysnIdRequiredLiquor = t1.ysnIdRequiredLiquor,
							ysnIdRequiredCigarette = t1.ysnIdRequiredCigarette,
							strRegProdCode = t1.strRegProdCode,
							intItemId = t1.intItemId,
							intConcurrencyId = 1
						FROM  
						(
							SELECT *,
									rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId, t.strUnitMeasure ORDER BY (SELECT NULL))
							FROM 
							(
								SELECT DISTINCT
									CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
									, IUOM.strLongUPCCode AS strUpcCode
									, ISNULL(NULLIF(IUOM.strUPCDescription, ''), I.strDescription) AS strDescription
									, IUM.strUnitMeasure AS strUnitMeasure
									, CASE  WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate THEN SplPrc.dblUnitAfterDiscount 
											WHEN (GETDATE() > (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
																							WHERE EIP.intItemLocationId = IL.intItemLocationId
																							AND GETDATE() >= dtmEffectiveRetailPriceDate
																							ORDER BY dtmEffectiveRetailPriceDate ASC))
																		THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
																								WHERE EIP.intItemLocationId = IL.intItemLocationId
																								AND GETDATE() >= dtmEffectiveRetailPriceDate
																								ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
										ELSE Prc.dblSalePrice 
									END AS dblSalePrice
									, IL.ysnTaxFlag1 AS ysnSalesTaxed
									, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
									, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
									, SubCat.strRegProdCode AS strRegProdCode
									, I.intItemId AS intItemId
								FROM tblICItem I
								JOIN tblICCategory Cat 
									ON Cat.intCategoryId = I.intCategoryId
								JOIN @tempTableItems tmpItem 
									ON tmpItem.intItemId = I.intItemId
								JOIN tblICItemLocation IL 
									ON IL.intItemId = I.intItemId
								LEFT JOIN tblSTSubcategoryRegProd SubCat 
									ON SubCat.intRegProdId = IL.intProductCodeId
								JOIN tblSTStore ST 
									--ON ST.intStoreId = SubCat.intStoreId
									ON IL.intLocationId = ST.intCompanyLocationId
								JOIN tblSMCompanyLocation L 
									ON L.intCompanyLocationId = IL.intLocationId
								JOIN tblICItemUOM IUOM 
									ON IUOM.intItemId = I.intItemId
								JOIN tblICUnitMeasure IUM 
									ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
								JOIN tblSTRegister R 
									ON R.intStoreId = ST.intStoreId
								JOIN tblICItemPricing Prc 
									ON Prc.intItemLocationId = IL.intItemLocationId
								LEFT JOIN tblICItemSpecialPricing SplPrc 
									ON SplPrc.intItemId = I.intItemId
								WHERE I.ysnFuelItem = CAST(0 AS BIT) 
									AND ST.intStoreId = @intStoreId
									AND IUOM.strLongUPCCode IS NOT NULL
									--AND IUOM.strLongUPCCode <> ''
									--AND IUOM.strLongUPCCode <> '0'
									AND IUOM.strLongUPCCode NOT LIKE '%[^0-9]%'
									AND ISNULL(SUBSTRING(IUOM.strLongUPCCode, PATINDEX('%[^0]%',IUOM.strLongUPCCode), LEN(IUOM.strLongUPCCode)), 0) NOT IN ('') -- NOT IN ('0', '')
							) as t
						) t1
						WHERE rn = 1
						-- -----------------------------------------------------------------------------
						-- [END] - Create Preview
						-- -----------------------------------------------------------------------------






						-- Add namespaces of 'xmlns'
						;WITH XMLNAMESPACES (
												'http://www.w3.org/2001/XMLSchema-instance' AS xsi
												, 'urn:vfi-sapphire:np.domain.2001-07-01' AS domain
											 )
				
						SELECT @xml =
						(
							SELECT
								plu.[strSource]						AS 'upc/@source'
								, plu.[strUpc]						AS 'upc'
								, plu.[strUpcModifier]				AS 'upcModifier'
								, plu.[strDescription]				AS 'description'
								, plu.[strDepartment]				AS 'department'
								, plu.[strFee]						AS 'fee'
								, plu.[strPCode]					AS 'pcode'
								, plu.[dblPrice]					AS 'price'
								, plu.[dblTransactionQtyLimit]		AS 'maxQtyPerTrans'
								,(	
											SELECT
												plus.intFlagSysid AS [@sysid]
											FROM @tblTempSapphireCommanderUPLUs plus
											WHERE plus.intItemLocationId = plu.intItemLocationId
												AND plus.intFlagSysid IS NOT NULL
											FOR XML PATH('domain:flag'),
											ROOT('flags'), TYPE			
								)
								,(	
											SELECT
												plus.intTaxRateSysid AS [@sysid]
											FROM @tblTempSapphireCommanderUPLUs plus
											WHERE plus.intItemLocationId = plu.intItemLocationId
												AND plus.intTaxRateSysid IS NOT NULL
											FOR XML PATH('domain:taxRate'),
											ROOT('taxRates'), TYPE
			
								)
								,(	
											SELECT
												plus.intIdCheckSysId AS [@sysid]
											FROM @tblTempSapphireCommanderUPLUs plus
											WHERE plus.intItemLocationId = plu.intItemLocationId
												AND plus.intIdCheckSysId IS NOT NULL
											FOR XML PATH('domain:idCheck'),
											ROOT('idChecks'), TYPE			
								)
								,(	
											SELECT
												plus.intBlueLawsSysId AS [@sysid]
											FROM @tblTempSapphireCommanderUPLUs plus
											WHERE plus.intItemLocationId = plu.intItemLocationId
												AND plus.intBlueLawsSysId IS NOT NULL
											FOR XML PATH('domain:blueLaw'),
											ROOT('blueLaws'), TYPE			
								)
								, 1 AS 'SellUnit'
							--FROM @tblTempSapphireCommanderUPLUs plu
							FROM 
							(
								SELECT DISTINCT
									intItemLocationId
									, strSource
									, strUpc
									, strUpcModifier
									, strDescription
									, strDepartment
									, strFee
									, strPCode
									, dblPrice
									, dblTransactionQtyLimit
								FROM @tblTempSapphireCommanderUPLUs
							) plu
							FOR XML PATH('domain:PLU'), 
							ROOT('domain:PLUs'), TYPE
						);


						DECLARE @intPage INT = 1
								, @intOfPages INT = 1
								, @strSchemaLocation NVARCHAR(100) = 'urn:vfi-sapphire:np.domain.2001-07-01 /SapphireVM1/xml/SapphireV1.1/vsmsPLUs.xsd'

						DECLARE @strNamesSpace AS NVARCHAR(150) = 'domain:PLU xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
								, @strDomainPlu AS NVARCHAR(50) = 'domain:PLU'

						-- INSERT Attributes 'page' and 'ofpages' to Root header
						SET @xml.modify('insert 
									   (
											attribute xsi:schemaLocation { 
																			 sql:variable("@strSchemaLocation")
																		 }
											,		  attribute page { 
																		sql:variable("@intPage") 
																	 }
										   ,       attribute ofpages { 
																		sql:variable("@intOfPages")
																	 }
				   
										) into (/*:PLUs)[1]');

						SET @strXML = CAST(@xml AS NVARCHAR(MAX))
						SET @strXML = REPLACE(@strXML, 'flags xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 'flags')
						SET @strXML = REPLACE(@strXML, 'taxRates xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 'taxRates')
						SET @strXML = REPLACE(@strXML, 'idChecks xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 'idChecks')
						SET @strXML = REPLACE(@strXML, 'blueLaws xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 'blueLaws')
						
						SET @strGeneratedXML = @strXML
						SET @ysnSuccessResult = CAST(1 AS BIT)

					END
				ELSE
					BEGIN
						SET @strGeneratedXML = ''
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = @strMessageResult + 'No result found to generate Pricebook - ' + @strFilePrefix + ' Outbound file. '

						GOTO ExitWithRollback
					END

				
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