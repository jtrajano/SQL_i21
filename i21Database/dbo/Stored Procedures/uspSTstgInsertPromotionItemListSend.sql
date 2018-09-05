﻿CREATE PROCEDURE [dbo].[uspSTstgInsertPromotionItemListSend]
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

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'ILT'

		---- =========================================================================================================
		---- CONVERT DATE's to UTC
		---- =========================================================================================================
		--DECLARE @dtmBeginningChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmBeginningChangeDate)
		--DECLARE @dtmEndingChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmEndingChangeDate)
		---- =========================================================================================================
		---- END CONVERT DATE's to UTC
		---- =========================================================================================================

		---- Use table to get the list of items modified during change date range
		--DECLARE @Tab_UpdatedItems TABLE(intItemId int)

		---- Get those Item using given date range
		--INSERT INTO @Tab_UpdatedItems
		--SELECT DISTINCT ITR.intItemId
		--FROM vyuSTItemsToRegister ITR
		--WHERE (
		--		ITR.dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		--		OR 
		--		ITR.dtmDateCreated BETWEEN @dtmEndingChangeDateUTC AND @dtmEndingChangeDateUTC
		--	  )
		--	AND intCompanyLocationId = 
		--	(
		--		SELECT TOP (1) intCompanyLocationId 
		--		FROM tblSTStore
		--		WHERE intStoreId = @intStoreId
		--	)

		---- =========================================================================================================

		-- Check if register has intImportFileHeaderId
		DECLARE @strRegisterName nvarchar(200)
				, @strRegisterClass NVARCHAR(200)
				, @dblXmlVersion NUMERIC(4, 2)

		SELECT @strRegisterName = strRegisterName 
			   , @strRegisterClass = strRegisterClass
			   , @dblXmlVersion = dblXmlVersion
		FROM dbo.tblSTRegister 
		Where intRegisterId = @intRegisterId

		IF EXISTS(SELECT intImportFileHeaderId FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
				SELECT @intImportFileHeaderId = intImportFileHeaderId 
				FROM tblSTRegisterFileConfiguration 
				WHERE intRegisterId = @intRegisterId 
				AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
				SET @strGeneratedXML = ''
				SET @intImportFileHeaderId = 0
				SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
				SET @strMessageResult = 'Register ' + @strRegisterClass + ' has no Outbound setup for Promotion Item List File (' + @strFilePrefix + ')'

				RETURN
			END	
		-- =========================================================================================================



		DECLARE @XMLGatewayVersion nvarchar(100)
		SELECT @XMLGatewayVersion = dblXmlVersion FROM dbo.tblSTRegister WHERE intRegisterId = @intRegisterId

		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				IF(@dblXmlVersion = 3.40)
					BEGIN
						-- Create Unique Identifier
						-- Handles multiple Update of registers by different Stores
						DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

						-- Table and Condition
						DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookItemListILT33~strUniqueGuid=''' + @strUniqueGuid + ''''

						INSERT INTO tblSTstgPassportPricebookItemListILT33
						(
							[StoreLocationID] , 
							[VendorName], 
							[VendorModelVersion], 
							[RecordActionType], 
							[ItemListMaintenanceRecordActionType], 
							[ItemListID], 
							[ItemListDescription], 
							[POSCodeFormatFormat], 
							[POSCode],
							[strUniqueGuid]
						)
						SELECT DISTINCT
							ST.intStoreNo AS [StoreLocationID]
							, 'iRely' AS [VendorName]  	
							, 'Rel. 13.2.0' AS [VendorModelVersion]
							, 'addchange' AS [RecordActionType] 
							, CASE PIL.ysnDeleteFromRegister 
								WHEN 0 
									THEN 'addchange' 
								WHEN 1 
									THEN 'delete' 
								ELSE 'addchange' 
							END as [ItemListMaintenanceRecordActionType] 
							, PIL.intPromoItemListNo AS [ItemListID]
							, PIL.strPromoItemListDescription AS [ItemListDescription]
							, CASE 
								WHEN ISNUMERIC(IUOM.strUpcCode) = 0
									THEN 'upcA'
								WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) 
									THEN 'PLU' 
								ELSE 'upcA' 
							END [POSCodeFormatFormat]
							, CASE	
								WHEN ISNUMERIC(IUOM.strUpcCode) = 0
									THEN RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
								WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) 
									THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
								ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
							END [POSCode],
							@strUniqueGuid AS [strUniqueGuid]
						FROM tblICItem I
						--JOIN @Tab_UpdatedItems tmpItem 
						--	ON tmpItem.intItemId = I.intItemId 
						JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = IL.intLocationId
						JOIN tblICItemUOM IUOM 
							ON IUOM.intItemId = I.intItemId 
						JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						JOIN tblSTStore ST 
							ON ST.intCompanyLocationId = L.intCompanyLocationId 
						JOIN tblICCategory Cat 
							ON Cat.intCategoryId = I.intCategoryId
						LEFT JOIN tblSTSubcategoryRegProd SubCat 
							ON SubCat.intStoreId = ST.intStoreId
						JOIN tblSTRegister R 
							ON R.intStoreId = ST.intStoreId
						JOIN tblSTPromotionItemList PIL 
							ON PIL.intStoreId = ST.intStoreId 
						WHERE I.ysnFuelItem = CAST(0 AS BIT) 
						AND R.intRegisterId = @intRegisterId 
						AND ST.intStoreId = @intStoreId
						-- AND PIL.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId



						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookItemListILT33 WHERE strUniqueGuid = @strUniqueGuid)
							BEGIN
								-- Generate XML for the pricebook data availavle in staging table
								EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

								--Once XML is generated delete the data from pricebook  staging table.
								DELETE 
								FROM dbo.tblSTstgPassportPricebookItemListILT33
								WHERE strUniqueGuid = @strUniqueGuid
							END
						ELSE 
							BEGIN
								SET @ysnSuccessResult = CAST(0 AS BIT)
								SET @strMessageResult = 'No result found to generate Item List - ' + @strFilePrefix + ' Outbound file'
							END
					END
			END
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO [tblSTstgPromotionItemListSend]
				SELECT DISTINCT
				 ST.intStoreNo [StoreLocationID]
					, 'iRely' [VendorName]  	
					, 'Rel. 13.2.0' [VendorModelVersion]
					, 'update' [TableActionType]
					, 'addchange' [RecordActionType] 
					, CASE PIL.ysnDeleteFromRegister 
						WHEN 0 
							THEN 'addchange' 
						WHEN 1 
							THEN 'delete' 
						ELSE 'addchange' 
					END as [ILTDetailRecordActionType] 
					, PIL.intPromoItemListNo [ItemListID]
					, PIL.strPromoItemListDescription [ItemListDescription]
					, CASE 
						WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) 
							THEN 'PLU' 
						ELSE 'upcA' 
					END [POSCodeFormat]
					, CASE	
						WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) 
							THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
						ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
					END [POSCode]
					, IUM.strUnitMeasure [PosCodeModifierName] 
					, '0' [PosCodeModifierValue] 
					, Cat.strCategoryCode [MerchandiseCode]	
				FROM tblICItem I
				--JOIN @Tab_UpdatedItems tmpItem 
				--	ON tmpItem.intItemId = I.intItemId 
				JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN tblSMCompanyLocation L 
					ON L.intCompanyLocationId = IL.intLocationId
				JOIN tblICItemUOM IUOM 
					ON IUOM.intItemId = I.intItemId 
				JOIN tblICUnitMeasure IUM 
					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
				JOIN tblSTStore ST 
					ON ST.intCompanyLocationId = L.intCompanyLocationId 
				JOIN tblICCategory Cat 
					ON Cat.intCategoryId = I.intCategoryId
				LEFT JOIN tblSTSubcategoryRegProd SubCat 
					ON SubCat.intStoreId = ST.intStoreId
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intStoreId = ST.intStoreId 
				WHERE I.ysnFuelItem = CAST(0 AS BIT) 
				AND R.intRegisterId = @intRegisterId 
				AND ST.intStoreId = @intStoreId 
				-- AND SaleList.strPromoType = 'M'
				-- AND PIL.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId
	


				IF EXISTS(SELECT StoreLocationID FROM tblSTstgPromotionItemListSend)
					BEGIN
						--Generate XML for the pricebook data availavle in staging table
						Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPromotionItemListSend~intPromotionItemListSend > 0', 0, @strGeneratedXML OUTPUT

						--Once XML is generated delete the data from pricebook  staging table.
						DELETE FROM [tblSTstgPromotionItemListSend]	
					END
				ELSE 
					BEGIN
						SET @ysnSuccessResult = CAST(0 AS BIT)
						SET @strMessageResult = 'No result found to generate Item List - ' + @strFilePrefix + ' Outbound file'
					END
			END

	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
END