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

		--IF(UPPER(@strRegisterClass) = UPPER('SAPPHIRE') or UPPER(@strRegisterClass) = UPPER('COMMANDER'))
		--IF(UPPER(@strRegisterClass) IN ('SAPPHIRE/COMMANDER'))
		--	BEGIN
		--		IF EXISTS(SELECT IFH.intImportFileHeaderId 
		--				  FROM dbo.tblSMImportFileHeader IFH
		--				  JOIN dbo.tblSTRegisterFileConfiguration FC 
		--						ON FC.intImportFileHeaderId = IFH.intImportFileHeaderId
		--				  WHERE IFH.strLayoutTitle = 'Pricebook Send Sapphire' 
		--				  AND IFH.strFileType = 'XML' 
		--				  AND FC.intRegisterId = @intRegisterId)
		--			BEGIN
		--				SELECT @intImportFileHeaderId = IFH.intImportFileHeaderId 
		--				FROM dbo.tblSMImportFileHeader IFH
		--				JOIN dbo.tblSTRegisterFileConfiguration FC 
		--					ON FC.intImportFileHeaderId = IFH.intImportFileHeaderId
		--				WHERE IFH.strLayoutTitle = 'Pricebook Send Sapphire' 
		--				AND IFH.strFileType = 'XML' 
		--				AND FC.intRegisterId = @intRegisterId
		--			END
		--		ELSE
		--			BEGIN
		--				SET @intImportFileHeaderId = 0
		--			END	
		
		--	END
		--ELSE
		--	BEGIN
		--		IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
		--			BEGIN
		--				SELECT @intImportFileHeaderId = intImportFileHeaderId 
		--				FROM tblSTRegisterFileConfiguration 
		--				WHERE intRegisterId = @intRegisterId 
		--				AND strFilePrefix = @strFilePrefix
		--			END
		--		ELSE
		--			BEGIN
		--				SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
		--				SET @strGeneratedXML = ''
		--				SET @intImportFileHeaderId = 0
		--				SET @strMessageResult = 'Register ' + @strRegisterClass + ' has no Outbound setup for Pricebook File (' + @strFilePrefix + ')'

		--				RETURN
		--			END	
		--	END

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
				SET @strMessageResult = 'Register ' + @strRegisterClass + ' has no Outbound setup for Pricebook File (' + @strFilePrefix + ')'

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
		AND intCompanyLocationId = 
		(
			SELECT intCompanyLocationId 
			FROM tblSTStore
			WHERE intStoreId = @intStoreId
		)
		--------------------------------------------------------------------------------------------------------------
		----------------- End Get Inventory Items that has modified/added date between date range --------------------
		--------------------------------------------------------------------------------------------------------------
----TEST
--SELECT * FROM @tempTableItems



		-- PASSPORT
		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				-- Create Unique Identifier
				-- Handles multiple Update of registers by different Stores
				DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

				-- Table and Condition
				DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookITT33~strUniqueGuid=''' + @strUniqueGuid + ''''



				IF(@strXmlVersion = '3.4')
					BEGIN
						--Insert data into Procebook staging table	
						IF(@ysnExportEntirePricebookFile = CAST(1 AS BIT))
							BEGIN
								INSERT INTO tblSTstgPassportPricebookITT33
								(
									[StoreLocationID], 
									[VendorName], 
									[VendorModelVersion], 
									[TableActionType], 
									[RecordActionType], 
									[RecordActionEffectiveDate], 
									[ITTDetailRecordActionType], 
									[POSCodeFormatFormat], 
									[POSCode], 
									[POSCodeModifier],
									[ActiveFlagValue], 
									[InventoryValuePrice],
									[MerchandiseCode], 
									[RegularSellPrice], 
									[Description],
									[PaymentSystemsProductCode],
									[SellingUnits],
									[TaxStrategyID],
									[PriceMethodCode],
									[ReceiptDescription],
									[FoodStampableFlg],
									[QuantityRequiredFlg],
									[strUniqueGuid]
								)
								SELECT DISTINCT
									ST.intStoreNo AS [StoreLocationID], 
									'iRely' AS [VendorName], 
									--'Rel. 13.2.0' AS [VendorModelVersion], 
									(SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC) AS [VendorModelVersion],
									'update' AS [TableActionType], 
									'addchange' AS [RecordActionType], 
									CONVERT(NVARCHAR(10), GETDATE(), 21) AS [RecordActionEffectiveDate], 
									CASE 
										WHEN I.strStatus = 'Active' 
											THEN 'addchange' 
										WHEN I.strStatus = 'Phased Out' 
											THEN 'delete' 
										ELSE 'addchange' 
									END AS [ITTDetailRecordActionType], 
									PCF.strPosCodeFormat AS [POSCodeFormatFormat],
									PCF.strUPCwthOrwthOutCheckDigit AS [POSCode],
									--CASE 
										
									--	WHEN ISNULL(IUOM.strLongUPCCode,'') != '' AND ISNULL(IUOM.strLongUPCCode,'') NOT LIKE '%[^0-9]%'
									--		THEN CASE
									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) <= 89999 -- ISNULL(ST.intMaxPlu,0)
									--					THEN 'plu'

									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) > 89999 --ISNULL(ST.intMaxPlu,0)
									--					THEN CASE
									--							-- UPC-A
									--							WHEN LEN(IUOM.strLongUPCWOLeadingZero) = 6 
									--								THEN 'upcA'
									--							WHEN IUOM.strUPCwithCheckDigit > 89999 AND IUOM.strUPCwithCheckDigit <= 99999999999
									--								THEN 'upcA'
																
									--							-- EAN13
									--							WHEN IUOM.strUPCwithCheckDigit > 99999999999 AND IUOM.strUPCwithCheckDigit <= 999999999999
									--								THEN 'ean13'

									--							-- GTIN
									--							WHEN IUOM.strUPCwithCheckDigit > 999999999999
									--								THEN 'gtin'
									--					END
									--				ELSE ''
									--			 END
									--	ELSE 'plu' 
									--END AS [POSCodeFormatFormat], 
									--CASE 
									--	WHEN ISNULL(IUOM.strLongUPCCode,'') != '' AND ISNULL(IUOM.strLongUPCCode,'') NOT LIKE '%[^0-9]%'
									--		THEN CASE
									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) <= 89999 -- ISNULL(ST.intMaxPlu,0)
									--					THEN IUOM.strLongUPCCode -- (plu)

									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) > 89999 --ISNULL(ST.intMaxPlu,0)
									--					THEN CASE
									--							-- UPC-A
									--							WHEN LEN(IUOM.strLongUPCWOLeadingZero) = 6 
									--								-- Convert to UPC-E + Check Digit
									--								THEN RIGHT('00000000000' + ISNULL(dbo.fnSTConvertUPCeToUPCa(IUOM.strLongUPCCode),''), 11) + CAST(dbo.fnSTGenerateCheckDigit(IUOM.strLongUPCCode) AS NVARCHAR(1))
									--							WHEN IUOM.strUPCwithCheckDigit > 89999 AND IUOM.strUPCwithCheckDigit <= 99999999999
									--								THEN RIGHT('000000000000' + IUOM.strUPCwithCheckDigit, 12)
																
									--							-- EAN13
									--							WHEN IUOM.strUPCwithCheckDigit > 99999999999 AND IUOM.strUPCwithCheckDigit <= 999999999999
									--								THEN RIGHT('0000000000000' + IUOM.strUPCwithCheckDigit, 13)

									--							-- GTIN
									--							WHEN IUOM.strUPCwithCheckDigit > 999999999999
									--								THEN IUOM.strUPCwithCheckDigit
									--					END
									--				ELSE IUOM.strLongUPCCode
									--			 END
									--	ELSE '0000' 
									--END [POSCode], 
									'0' AS [PosCodeModifier],
									CASE 
										WHEN I.strStatus = 'Active' 
											THEN 'yes' 
										ELSE 'no' 
									END as [ActiveFlagValue], 
									Prc.dblSalePrice AS [InventoryValuePrice],
									--Cat.strCategoryCode AS [MerchandiseCode],
									CatLoc.intRegisterDepartmentId AS [MerchandiseCode],  
									CASE 
										WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate 
											THEN SplPrc.dblUnitAfterDiscount 
										ELSE Prc.dblSalePrice 
									END AS [RegularSellPrice], 
									I.strDescription AS [Description],
									CASE 
										WHEN R.strRegisterClass = 'PASSPORT' 
											THEN 
												CASE 
													WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = '0'
														THEN '7' 
													ELSE SubCat.strRegProdCode 
												END 
											ELSE  ISNULL(SubCat.strRegProdCode, '40') 
									END AS [PaymentSystemsProductCode],
									CAST(IUOM.dblUnitQty AS NUMERIC(18,2)) AS [SellingUnits],
									CASE	
										WHEN IL.ysnTaxFlag1 = 1 
											THEN R.intTaxStrategyIdForTax1 
										WHEN IL.ysnTaxFlag2 = 1 
											THEN R.intTaxStrategyIdForTax2 
										WHEN IL.ysnTaxFlag3 = 1 
											THEN R.intTaxStrategyIdForTax3 
										WHEN IL.ysnTaxFlag4 = 1 
											THEN R.intTaxStrategyIdForTax4
										ELSE R.intNonTaxableStrategyId
									END AS [TaxStrategyID],
									0 AS [PriceMethodCode],
									--IL.strDescription AS [ReceiptDescription],
									CASE
										WHEN ISNULL(I.strShortName, '') != ''
											THEN I.strShortName
										ELSE I.strDescription
									END AS [ReceiptDescription],
									IL.ysnFoodStampable AS [FoodStampableFlg],
									IL.ysnQuantityRequired AS [QuantityRequiredFlg],
									@strUniqueGuid AS [strUniqueGuid]
								FROM tblICItem I
								INNER JOIN tblICCategory Cat 
									ON Cat.intCategoryId = I.intCategoryId
								INNER JOIN dbo.tblICCategoryLocation AS CatLoc 
									ON CatLoc.intCategoryId = Cat.intCategoryId 
								INNER JOIN 
								(
									SELECT DISTINCT intItemId FROM @tempTableItems 
								) AS tmpItem 
									ON tmpItem.intItemId = I.intItemId 
								INNER JOIN tblICItemLocation IL 
									ON IL.intItemId = I.intItemId
								LEFT JOIN tblSTSubcategoryRegProd SubCat 
									ON SubCat.intRegProdId = IL.intProductCodeId
								INNER JOIN tblSTStore ST 
									ON ST.intStoreId = SubCat.intStoreId
									AND IL.intLocationId = ST.intCompanyLocationId
									AND CatLoc.intLocationId = ST.intCompanyLocationId
								INNER JOIN tblSMCompanyLocation L 
									ON L.intCompanyLocationId = ST.intCompanyLocationId
								INNER JOIN tblICItemUOM AS IUOM 
									ON IUOM.intItemId = I.intItemId 
								INNER JOIN vyuSTItemUOMPosCodeFormat PCF
									ON IUOM.intItemUOMId = PCF.intItemUOMId
								INNER JOIN tblICUnitMeasure IUM 
									ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
								INNER JOIN tblSTRegister R 
									ON R.intRegisterId = ST.intRegisterId
								INNER JOIN tblICItemPricing Prc 
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



								-- INSERT TO UPDATE REGISTER PREVIEW TABLE
								INSERT INTO tblSTUpdateRegisterItemReport
								(
									strGuid, 
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
									strActionType = t1.strActionType,
									strUpcCode = t1.strUpcCode,
									strDescription = t1.strDescription,
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
										rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
									FROM 
										(
											SELECT DISTINCT
												CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
												, IUOM.strLongUPCCode AS strUpcCode
												, I.strDescription AS strDescription
												, Prc.dblSalePrice AS dblSalePrice
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
												ON ST.intStoreId = SubCat.intStoreId
												AND IL.intLocationId = ST.intCompanyLocationId
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
							END


						ELSE IF(@ysnExportEntirePricebookFile = CAST(0 AS BIT))
							BEGIN
								INSERT INTO tblSTstgPassportPricebookITT33
								(
									[StoreLocationID], 
									[VendorName], 
									[VendorModelVersion], 
									[TableActionType], 
									[RecordActionType], 
									[RecordActionEffectiveDate], 
									[ITTDetailRecordActionType], 
									[POSCodeFormatFormat], 
									[POSCode], 
									[POSCodeModifier],
									[ActiveFlagValue], 
									[InventoryValuePrice],
									[MerchandiseCode], 
									[RegularSellPrice], 
									[Description],
									[PaymentSystemsProductCode],
									[SellingUnits],
									[TaxStrategyID],
									[PriceMethodCode],
									[ReceiptDescription],
									[FoodStampableFlg],
									[QuantityRequiredFlg],
									[strUniqueGuid]
								)
								SELECT DISTINCT
									ST.intStoreNo AS [StoreLocationID], 
									'iRely' AS [VendorName], 
									--'Rel. 13.2.0' AS [VendorModelVersion], 
									(SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC) AS [VendorModelVersion],
									'update' AS [TableActionType], 
									'addchange' AS [RecordActionType], 
									CONVERT(NVARCHAR(10), GETDATE(), 21) AS [RecordActionEffectiveDate], 
									CASE 
										WHEN I.strStatus = 'Active' 
											THEN 'addchange' 
										WHEN I.strStatus = 'Phased Out' 
											THEN 'delete' 
										ELSE 'addchange' 
									END AS [ITTDetailRecordActionType], 
									PCF.strPosCodeFormat AS [POSCodeFormatFormat],
									PCF.strUPCwthOrwthOutCheckDigit AS [POSCode],
									--CASE 
										
									--	WHEN ISNULL(IUOM.strLongUPCCode,'') != '' AND ISNULL(IUOM.strLongUPCCode,'') NOT LIKE '%[^0-9]%'
									--		THEN CASE
									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) <= 89999 -- ISNULL(ST.intMaxPlu,0)
									--					THEN 'plu'

									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) > 89999 --ISNULL(ST.intMaxPlu,0)
									--					THEN CASE
									--							-- UPC-A
									--							WHEN LEN(IUOM.strLongUPCWOLeadingZero) = 6 
									--								THEN 'upcA'
									--							WHEN IUOM.strUPCwithCheckDigit > 89999 AND IUOM.strUPCwithCheckDigit <= 99999999999
									--								THEN 'upcA'
																
									--							-- EAN13
									--							WHEN IUOM.strUPCwithCheckDigit > 99999999999 AND IUOM.strUPCwithCheckDigit <= 999999999999
									--								THEN 'ean13'

									--							-- GTIN
									--							WHEN IUOM.strUPCwithCheckDigit > 999999999999
									--								THEN 'gtin'
									--					END
									--				ELSE ''
									--			 END
									--	ELSE 'plu' 
									--END AS [POSCodeFormatFormat], 
									--CASE 
									--	WHEN ISNULL(IUOM.strLongUPCCode,'') != '' AND ISNULL(IUOM.strLongUPCCode,'') NOT LIKE '%[^0-9]%'
									--		THEN CASE
									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) <= 89999 -- ISNULL(ST.intMaxPlu,0)
									--					THEN IUOM.strLongUPCCode -- (plu)

									--				WHEN CONVERT(NUMERIC(32, 0),CAST(IUOM.strLongUPCCode AS FLOAT)) > 89999 --ISNULL(ST.intMaxPlu,0)
									--					THEN CASE
									--							-- UPC-A
									--							WHEN LEN(IUOM.strLongUPCWOLeadingZero) = 6 
									--								-- Convert to UPC-E + Check Digit
									--								THEN RIGHT('00000000000' + ISNULL(dbo.fnSTConvertUPCeToUPCa(IUOM.strLongUPCCode),''), 11) + CAST(dbo.fnSTGenerateCheckDigit(IUOM.strLongUPCCode) AS NVARCHAR(1))
									--							WHEN IUOM.strUPCwithCheckDigit > 89999 AND IUOM.strUPCwithCheckDigit <= 99999999999
									--								THEN RIGHT('000000000000' + IUOM.strUPCwithCheckDigit, 12)
																
									--							-- EAN13
									--							WHEN IUOM.strUPCwithCheckDigit > 99999999999 AND IUOM.strUPCwithCheckDigit <= 999999999999
									--								THEN RIGHT('0000000000000' + IUOM.strUPCwithCheckDigit, 13)

									--							-- GTIN
									--							WHEN IUOM.strUPCwithCheckDigit > 999999999999
									--								THEN IUOM.strUPCwithCheckDigit
									--					END
									--				ELSE IUOM.strLongUPCCode
									--			 END
									--	ELSE '0000' 
									--END [POSCode], 
									'0' AS [PosCodeModifier],
									CASE 
										WHEN I.strStatus = 'Active' 
											THEN 'yes' 
										ELSE 'no' 
									END as [ActiveFlagValue], 
									Prc.dblSalePrice AS [InventoryValuePrice],
									--Cat.strCategoryCode AS [MerchandiseCode],
									CatLoc.intRegisterDepartmentId AS [MerchandiseCode],  
									CASE 
										WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate 
											THEN SplPrc.dblUnitAfterDiscount 
										ELSE Prc.dblSalePrice 
									END AS [RegularSellPrice], 
									I.strDescription AS [Description],
									CASE 
										WHEN R.strRegisterClass = 'PASSPORT' 
											THEN 
												CASE 
													WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = '0'
														THEN '7' 
													ELSE SubCat.strRegProdCode 
												END 
											ELSE  ISNULL(SubCat.strRegProdCode, '40') 
									END AS [PaymentSystemsProductCode],
									CAST(IUOM.dblUnitQty AS NUMERIC(18,2)) AS [SellingUnits],
									CASE	
										WHEN IL.ysnTaxFlag1 = 1 
											THEN R.intTaxStrategyIdForTax1 
										WHEN IL.ysnTaxFlag2 = 1 
											THEN R.intTaxStrategyIdForTax2 
										WHEN IL.ysnTaxFlag3 = 1 
											THEN R.intTaxStrategyIdForTax3 
										WHEN IL.ysnTaxFlag4 = 1 
											THEN R.intTaxStrategyIdForTax4
										ELSE R.intNonTaxableStrategyId
									END AS [TaxStrategyID],
									0 AS [PriceMethodCode],
									--IL.strDescription AS [ReceiptDescription],
									CASE
										WHEN ISNULL(I.strShortName, '') != ''
											THEN I.strShortName
										ELSE I.strDescription
									END AS [ReceiptDescription],
									IL.ysnFoodStampable AS [FoodStampableFlg],
									IL.ysnQuantityRequired AS [QuantityRequiredFlg],
									@strUniqueGuid AS [strUniqueGuid]
								FROM tblICItem I
								INNER JOIN tblICCategory Cat 
									ON Cat.intCategoryId = I.intCategoryId
								INNER JOIN dbo.tblICCategoryLocation AS CatLoc 
									ON CatLoc.intCategoryId = Cat.intCategoryId 
								INNER JOIN 
								(
									SELECT DISTINCT intItemId FROM @tempTableItems 
								) AS tmpItem 
									ON tmpItem.intItemId = I.intItemId 
								INNER JOIN tblICItemLocation IL 
									ON IL.intItemId = I.intItemId
								LEFT JOIN tblSTSubcategoryRegProd SubCat 
									ON SubCat.intRegProdId = IL.intProductCodeId
								INNER JOIN tblSTStore ST 
									ON ST.intStoreId = SubCat.intStoreId
									AND IL.intLocationId = ST.intCompanyLocationId
									AND CatLoc.intLocationId = ST.intCompanyLocationId
								INNER JOIN tblSMCompanyLocation L 
									ON L.intCompanyLocationId = ST.intCompanyLocationId
								INNER JOIN tblICItemUOM AS IUOM 
									ON IUOM.intItemId = I.intItemId 
								INNER JOIN vyuSTItemUOMPosCodeFormat PCF
									ON IUOM.intItemUOMId = PCF.intItemUOMId
								INNER JOIN tblICUnitMeasure IUM 
									ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
								INNER JOIN tblSTRegister R 
									ON R.intRegisterId = ST.intRegisterId
								INNER JOIN tblICItemPricing Prc 
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

								-- INSERT TO UPDATE REGISTER PREVIEW TABLE
								INSERT INTO tblSTUpdateRegisterItemReport
								(
									strGuid, 
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
									strActionType = t1.strActionType,
									strUpcCode = t1.strUpcCode,
									strDescription = t1.strDescription,
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
										rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
									FROM 
										(
											SELECT DISTINCT
												CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
												, IUOM.strLongUPCCode AS strUpcCode
												, I.strDescription AS strDescription
												, Prc.dblSalePrice AS dblSalePrice
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
												ON ST.intStoreId = SubCat.intStoreId
												AND IL.intLocationId = ST.intCompanyLocationId
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
										) as t
								) t1
								WHERE rn = 1
							END

						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookITT33 WHERE strUniqueGuid = @strUniqueGuid)
							BEGIN
								-- Generate XML for the pricebook data availavle in staging table
								Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

								--Once XML is generated delete the data from pricebook  staging table.
								DELETE 
								FROM dbo.tblSTstgPassportPricebookITT33
								WHERE strUniqueGuid = @strUniqueGuid
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
							, Prc.dblSalePrice [InventoryValuePrice]
							, Cat.strCategoryCode [MerchandiseCode]
							, CASE WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate THEN SplPrc.dblUnitAfterDiscount 
								ELSE Prc.dblSalePrice END  [RegularSellPrice]
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
							ON ST.intStoreId = SubCat.intStoreId
							   AND IL.intLocationId = ST.intCompanyLocationId
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
							, Prc.dblSalePrice [InventoryValuePrice]
							, Cat.strCategoryCode [MerchandiseCode]
							, CASE WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate THEN SplPrc.dblUnitAfterDiscount 
								ELSE Prc.dblSalePrice END  [RegularSellPrice]
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
							ON ST.intStoreId = SubCat.intStoreId
							   AND IL.intLocationId = ST.intCompanyLocationId
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
					[strSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
					[strUpc] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strUpcModifier] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
					[strDepartment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
					[strFee] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[strPCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
					[dblPrice] DECIMAL(18, 2) NULL,
					[intFlagSysid] INT NULL, 
					[intTaxRateSysid] INT NULL, 
					[dblSellUnit] DECIMAL(18, 6) NULL
				)

				-- Insert values to Temp table
				INSERT INTO @tblTempSapphireCommanderUPLUs
				SELECT
					[intCommanderOutboundPLUsId]	= ROW_NUMBER() OVER(ORDER BY (SELECT 1))
					, [strSource]					= 'keyboard'
					, [strUpc]						= CAST(UOM.strLongUPCCode AS NVARCHAR(50))
					, [strUpcModifier]				= '000'
					, [strDescription]				= REPLACE(REPLACE(REPLACE(REPLACE(Item.strDescription, '''', ''), '"', ''), '/', ''), '\', '')
					, [strDepartment]				= CAST(CategoryLoc.intRegisterDepartmentId AS NVARCHAR(50))
					, [strFee]						= '00'
					, [strPCode]					= ISNULL(StorePCode.strRegProdCode, '')
					, [dblPrice]					= ISNULL(ItemPrice.dblSalePrice, 0)
					, [intFlagSysid]				= 1 
					, [intTaxRateSysid]				= 1
					, [dblSellUnit]					= 1
				FROM tblICItem Item
				INNER JOIN @tempTableItems tempItem
					ON Item.intItemId = tempItem.intItemId
				INNER JOIN tblICItemUOM UOM
					ON Item.intItemId = UOM.intItemId
					AND UOM.ysnStockUnit = 1
				INNER JOIN tblICCategory Category
					ON Item.intCategoryId = Category.intCategoryId
				INNER JOIN dbo.tblICCategoryLocation CategoryLoc 
					ON Category.intCategoryId = CategoryLoc.intCategoryId
				INNER JOIN tblSTStore Store
					ON CategoryLoc.intLocationId = Store.intCompanyLocationId
				INNER JOIN 
				(
					SELECT
						intStoreId
						, strRegProdCode
					FROM tblSTSubcategoryRegProd 
				) AS StorePCode
				ON Store.intStoreId = StorePCode.intStoreId
				INNER JOIN tblICItemLocation ItemLoc
					ON Item.intItemId = ItemLoc.intItemId
					AND Store.intCompanyLocationId = ItemLoc.intLocationId
				INNER JOIN tblICItemPricing ItemPrice
					ON Item.intItemId = ItemPrice.intItemId
					AND ItemLoc.intItemLocationId = ItemPrice.intItemLocationId
				WHERE Store.intStoreId = @intStoreId
					AND UOM.strLongUPCCode IS NOT NULL
					AND UOM.strLongUPCCode NOT LIKE '%[^0-9]%'
					AND ISNULL(SUBSTRING(UOM.strLongUPCCode, PATINDEX('%[^0]%',UOM.strLongUPCCode), LEN(UOM.strLongUPCCode)), 0) NOT IN ('')
				ORDER BY UOM.strLongUPCCode ASC



				IF EXISTS(SELECT TOP 1 1 FROM @tblTempSapphireCommanderUPLUs)
					BEGIN
----TEST
--SELECT * FROM @tblTempSapphireCommanderUPLUs					
						DECLARE @xml XML = N''

						-- Add namespaces of 'xmlns'
						;WITH XMLNAMESPACES (
												'http://www.w3.org/2001/XMLSchema-instance' AS xsi
												, 'urn:vfi-sapphire:np.domain.2001-07-01' AS domain
											 )
				
						SELECT @xml =
						(
							SELECT
								plu.[strSource]				AS 'upc/@source'
								, plu.[strUpc]				AS 'upc'
								, plu.[strUpcModifier]		AS 'upcModifier'
								, plu.[strDescription]		AS 'description'
								, plu.[strDepartment]		AS 'department'
								, plu.[strFee]				AS 'fee'
								, plu.[strPCode]			AS 'pcode'
								, plu.[dblPrice]			AS 'price'
								,(	
											SELECT TOP (2)
												CASE 
													WHEN ROW_NUMBER() OVER(ORDER BY (SELECT 1)) = 1 
														THEN 1
													WHEN ROW_NUMBER() OVER(ORDER BY (SELECT 1)) = 2 
														THEN 4
													ELSE CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS NVARCHAR(50))
												END AS [@sysid]
											FROM @tblTempSapphireCommanderUPLUs
											--WHERE strDepartment = a.strDepartment
											FOR XML PATH('domain:flag'),
											ROOT('flags'), TYPE
			
								)
								,(	
											SELECT TOP (1)
												1 AS [@sysid]
											FROM @tblTempSapphireCommanderUPLUs
											FOR XML PATH('domain:taxRate'),
											ROOT('taxRates'), TYPE
			
								)
								, 1 AS 'SellUnit'
							FROM @tblTempSapphireCommanderUPLUs plu
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

						DECLARE @strXML AS NVARCHAR(MAX) = CAST(@xml AS NVARCHAR(MAX))
						SET @strXML = REPLACE(@strXML, 'flags xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 'flags')
						SET @strXML = REPLACE(@strXML, 'taxRates xmlns:domain="urn:vfi-sapphire:np.domain.2001-07-01" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 'taxRates')
						
						SET @strGeneratedXML = @strXML
						SET @ysnSuccessResult = CAST(1 AS BIT)
						SET @strMessageResult = ''
					END
				ELSE
					BEGIN
						SET @strGeneratedXML = ''
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = 'No result found to generate Pricebook - ' + @strFilePrefix + ' Outbound file'
					END

				
			END
	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
	
END