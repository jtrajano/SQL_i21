﻿CREATE PROCEDURE [dbo].[uspSTstgInsertPricebookSendFile]
	@strFilePrefix NVARCHAR(50)
	, @intStoreId INT
	, @intRegisterId INT
	, @strCategoryCode NVARCHAR(MAX)
	, @dtmBeginningChangeDate DATETIME
	, @dtmEndingChangeDate DATETIME
	, @ysnExportEntirePricebookFile BIT
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
		-- Check if register has intImportFileHeaderId
		DECLARE @strRegisterName NVARCHAR(200)
				, @strRegisterClass NVARCHAR(200)
				, @dblXmlVersion NUMERIC(4, 2)

		SELECT @strRegisterClass = strRegisterClass
			   , @strRegisterName = strRegisterName
			   , @dblXmlVersion = dblXmlVersion
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId

		IF(UPPER(@strRegisterClass) = UPPER('SAPPHIRE') or UPPER(@strRegisterClass) = UPPER('COMMANDER'))
			BEGIN
				IF EXISTS(SELECT IFH.intImportFileHeaderId 
						  FROM dbo.tblSMImportFileHeader IFH
						  JOIN dbo.tblSTRegisterFileConfiguration FC 
							ON FC.intImportFileHeaderId = IFH.intImportFileHeaderId
						  WHERE IFH.strLayoutTitle = 'Pricebook Send Sapphire' 
						  AND IFH.strFileType = 'XML' 
						  AND FC.intRegisterId = @intRegisterId)
					BEGIN
						SELECT @intImportFileHeaderId = IFH.intImportFileHeaderId 
						FROM dbo.tblSMImportFileHeader IFH
						JOIN dbo.tblSTRegisterFileConfiguration FC 
							ON FC.intImportFileHeaderId = IFH.intImportFileHeaderId
						WHERE IFH.strLayoutTitle = 'Pricebook Send Sapphire' 
						AND IFH.strFileType = 'XML' 
						AND FC.intRegisterId = @intRegisterId
					END
				ELSE
					BEGIN
						SET @intImportFileHeaderId = 0
					END	
		
			END
		ELSE
			BEGIN
				IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
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
			END
		-- =========================================================================================================




		DECLARE @XMLGatewayVersion nvarchar(100)

		SELECT @XMLGatewayVersion = dblXmlVersion 
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId

		SET @XMLGatewayVersion = ISNULL(@XMLGatewayVersion, '')
	

		-- Use table to get the list of items modified during change date range
		DECLARE @Tab_UpdatedItems TABLE(intItemId int)


		-- Get those Item using given date range
		INSERT INTO @Tab_UpdatedItems
		SELECT DISTINCT ITR.intItemId
		FROM vyuSTItemsToRegister ITR
		WHERE (
			ITR.dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
			OR 
			ITR.dtmDateCreated BETWEEN @dtmEndingChangeDateUTC AND @dtmEndingChangeDateUTC
		)
		AND intCompanyLocationId = 
		(
			SELECT TOP (1) intCompanyLocationId 
			FROM tblSTStore
			WHERE intStoreId = @intStoreId
		)


		-- PASSPORT
		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				-- Create Unique Identifier
				-- Handles multiple Update of registers by different Stores
				DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

				-- Table and Condition
				DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookITT33~strUniqueGuid=''' + @strUniqueGuid + ''''

				IF(@dblXmlVersion = 3.40)
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
									'Rel. 13.2.0' AS [VendorModelVersion], 
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
									CASE 
										WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
											THEN 'PLU' 
										ELSE 'upcA' 
									END AS [POSCodeFormatFormat], 
									CASE 
										WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
											THEN RIGHT('0000' + ISNULL(IUOM.strUpcCode,''),4) 
										ELSE RIGHT('00000000000' + ISNULL(IUOM.strLongUPCCode,''),11) 
									END [POSCode], 
									'0' AS [PosCodeModifier],
									CASE 
										WHEN I.strStatus = 'Active' 
											THEN 'yes' 
										ELSE 'no' 
									END as [ActiveFlagValue], 
									Prc.dblSalePrice AS [InventoryValuePrice],
									Cat.strCategoryCode AS [MerchandiseCode], 
									CASE 
										WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate 
											THEN SplPrc.dblUnitAfterDiscount 
										ELSE Prc.dblSalePrice 
									END AS [RegularSellPrice], 
									I.strDescription AS [Description],
									CASE 
										WHEN R.strRegisterClass = @strRegisterClass 
											THEN 
												CASE 
													WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = 0 
														THEN 7 
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
									IL.strDescription AS [ReceiptDescription],
									IL.ysnFoodStampable AS [FoodStampableFlg],
									IL.ysnQuantityRequired AS [QuantityRequiredFlg],
									@strUniqueGuid AS [strUniqueGuid]
								FROM tblICItem I
								JOIN tblICCategory Cat 
									ON Cat.intCategoryId = I.intCategoryId
								JOIN @Tab_UpdatedItems tmpItem 
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
								JOIN tblICItemSpecialPricing SplPrc 
									ON SplPrc.intItemId = I.intItemId
								WHERE I.ysnFuelItem = CAST(0 AS BIT) 
								AND R.intRegisterId = @intRegisterId 
								AND ST.intStoreId = @intStoreId

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
									'Rel. 13.2.0' AS [VendorModelVersion], 
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
									CASE 
										WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
											THEN 'PLU' 
										ELSE 'upcA' 
									END AS [POSCodeFormatFormat], 
									CASE 
										WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) 
											THEN RIGHT('0000' + ISNULL(IUOM.strUpcCode,''),4) 
										ELSE RIGHT('00000000000' + ISNULL(IUOM.strLongUPCCode,''),11) 
									END [POSCode], 
									'0' AS [PosCodeModifier],
									CASE 
										WHEN I.strStatus = 'Active' 
											THEN 'yes' 
										ELSE 'no' 
									END as [ActiveFlagValue], 
									Prc.dblSalePrice AS [InventoryValuePrice],
									Cat.strCategoryCode AS [MerchandiseCode], 
									CASE 
										WHEN GETDATE() between SplPrc.dtmBeginDate AND SplPrc.dtmEndDate 
											THEN SplPrc.dblUnitAfterDiscount 
										ELSE Prc.dblSalePrice 
									END AS [RegularSellPrice], 
									I.strDescription AS [Description],
									CASE 
										WHEN R.strRegisterClass = @strRegisterClass
											THEN 
												CASE 
													WHEN ISNULL(SubCat.strRegProdCode, '') = '' OR SubCat.strRegProdCode = 0 
														THEN 7 
													ELSE SubCat.strRegProdCode 
												END 
										ELSE  ISNULL(SubCat.strRegProdCode, '40') 
									END AS [PaymentSystemsProductCode],
									IUOM.dblUnitQty AS [SellingUnits],
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
									IL.strDescription AS [ReceiptDescription],
									IL.ysnFoodStampable AS [FoodStampableFlg],
									IL.ysnQuantityRequired AS [QuantityRequiredFlg],
									@strUniqueGuid AS [strUniqueGuid]
								FROM tblICItem I
								JOIN tblICCategory Cat 
									ON Cat.intCategoryId = I.intCategoryId
								JOIN @Tab_UpdatedItems tmpItem 
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
								JOIN tblICItemSpecialPricing SplPrc 
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
							END

						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookITT33)
							BEGIN
								-- Generate XML for the pricebook data availavle in staging table
								Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

								--Once XML is generated delete the data from pricebook  staging table.
								DELETE 
								FROM dbo.tblSTstgPassportPricebookITT33
								WHERE strUniqueGuid = @strUniqueGuid
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
							, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN 'PLU' ELSE 'upcA' END [POSCodeFormat]
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
						JOIN @Tab_UpdatedItems tmpItem 
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
						JOIN tblICItemSpecialPricing SplPrc 
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
							, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN 'PLU' ELSE 'upcA' END [POSCodeFormat]
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
						JOIN @Tab_UpdatedItems tmpItem 
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
						JOIN tblICItemSpecialPricing SplPrc 
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

				-- Generate XML for the pricebook data availavle in staging table
				Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPricebookSendFile~intPricebookSendFile > 0', 0, @strGeneratedXML OUTPUT

				--Once XML is generated delete the data from pricebook  staging table.
				DELETE FROM dbo.tblSTstgPricebookSendFile	
			END
	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
	
END