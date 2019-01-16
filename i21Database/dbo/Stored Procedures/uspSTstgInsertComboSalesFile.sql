CREATE PROCEDURE [dbo].[uspSTstgInsertComboSalesFile]
	@strFilePrefix NVARCHAR(50)
	, @intStoreId INT
	, @intRegisterId INT
	, @ysnClearRegisterPromotion BIT
	, @strGeneratedXML NVARCHAR(MAX) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @ysnSuccessResult BIT OUTPUT
	, @strMessageResult NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @ysnSuccessResult = CAST(1 AS BIT) -- Set to true
		SET @strMessageResult = ''

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'CBT'

		DECLARE @strRegister NVARCHAR(200)
				, @strRegisterClass NVARCHAR(200)
				, @strXmlVersion NVARCHAR(10)

		SELECT @strRegister = strRegisterName 
				, @strRegisterClass = strRegisterClass
				, @strXmlVersion = strXmlVersion
		FROM dbo.tblSTRegister 
		WHERE intRegisterId = @intRegisterId


		-- =========================================================================================================
		-- Check if register has intImportFileHeaderId
		IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @intRegisterId AND strFilePrefix = @strFilePrefix)
			BEGIN
					SELECT TOP 1 @intImportFileHeaderId = intImportFileHeaderId 
					FROM tblSTRegisterFileConfiguration 
					WHERE intRegisterId = @intRegisterId 
					AND strFilePrefix = @strFilePrefix
			END
		ELSE
			BEGIN
					SET @ysnSuccessResult = CAST(0 AS BIT) -- Set to false
					SET @strGeneratedXML = ''
					SET @intImportFileHeaderId = 0
					SET @strMessageResult = 'Register ' + @strRegister + ' has no Outbound setup for Promotion Sales List - Combo (' + @strFilePrefix + ')'

					RETURN
			END
		-- =========================================================================================================


		-- PASSPORT
		IF(@strRegisterClass = 'PASSPORT')
			BEGIN
				-- Create Unique Identifier
				-- Handles multiple Update of registers by different Stores
				DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

				-- Table and Condition
				DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookComboCBT33~strUniqueGuid=''' + @strUniqueGuid + ''''

				IF(@strXmlVersion = '3.4')
					BEGIN					
						INSERT INTO tblSTstgPassportPricebookComboCBT33
						(
							[StoreLocationID], 
							[VendorName], 
							[VendorModelVersion], 
							[TableActionType], 
							[RecordActionType], 
							[CBTDetailRecordActionType], 
							[PromotionID], 
							[PromotionReason], 
							[ComboDescription],
							[ComboPrice],
							[ItemListID],
							[ComboItemQuantity],
							[ComboItemUnitPrice],
							[StartDate],
							[StartTime],
							[StopDate],
							[StopTime],
							[strUniqueGuid]
						)
						SELECT DISTINCT
							ST.intStoreNo AS [StoreLocationID]
							, 'iRely' AS [VendorName] 
							, 'Rel. 10.2.0' AS [VendorModelVersion] 
							, CASE
									WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
									WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
							END AS [TableActionType]
							, 'addchange' AS [RecordActionType] 
							, CASE 
								WHEN PSL.ysnDeleteFromRegister = CAST(0 AS BIT) 
									THEN 'addchange' 
								WHEN PSL.ysnDeleteFromRegister = CAST(1 AS BIT)  
									THEN 'delete' 
								ELSE 'addchange' 
							END [CBTDetailRecordActionType] 
							, PSL.intPromoSalesId AS [PromotionID]
							, PSL.strPromoReason AS [PromotionReason]
							, PSL.strPromoSalesDescription AS [ComboDescription]
							, PSL.dblPromoPrice AS [ComboPrice]
							, PIL.intPromoItemListNo AS [ItemListID]
							, PSLD.intQuantity AS [ComboItemQuantity]
							, PSLD.dblPrice AS [ComboItemUnitPrice]
							, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) AS [StartDate]
							, CONVERT(varchar, CAST('0:00:01' AS TIME), 108) AS [StartTime]
							, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) AS [StopDate]
							, CONVERT(varchar, CAST('23:59:59' AS TIME), 108) AS [StopTime] 
							, @strUniqueGuid AS [strUniqueGuid]
						FROM tblICItem I
						JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = IL.intLocationId 
						JOIN tblSTStore ST 
							ON ST.intCompanyLocationId = L.intCompanyLocationId 
						JOIN tblSTRegister R 
							ON R.intStoreId = ST.intStoreId
						JOIN tblSTPromotionSalesList PSL 
							ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
						JOIN tblSTPromotionSalesListDetail PSLD 
							ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
						JOIN tblSTPromotionItemList PIL 
							ON PIL.intPromoItemListId = PSLD.intPromoItemListId
						JOIN tblSTPromotionItemListDetail PILD 
							ON PILD.intPromoItemListId = PIL.intPromoItemListId
						JOIN tblICItemUOM IUOM 
							ON IUOM.intItemUOMId = PILD.intItemUOMId 
						JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						WHERE R.intRegisterId = @intRegisterId
						AND ST.intStoreId = @intStoreId
						AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
						-- AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId



						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookComboCBT33 WHERE strUniqueGuid = @strUniqueGuid)
							BEGIN
								--Generate XML for the pricebook data availavle in staging table
								EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

								--Once XML is generated delete the data from pricebook staging table.
								DELETE 
								FROM tblSTstgPassportPricebookComboCBT33
								WHERE strUniqueGuid = @strUniqueGuid
							END
						ELSE 
							BEGIN
								SET @ysnSuccessResult = CAST(0 AS BIT)
								SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
							END
					
					END
			END
		-- RADIANT
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO tblSTstgComboSalesFile
				SELECT DISTINCT
				  ST.intStoreNo [StoreLocationID]
					, 'iRely' [VendorName]  	
					, 'Rel. 13.2.0' [VendorModelVersion]
					, 'update' [TableActionType]
					, 'addchange' [RecordActionType] 
					, CASE PSL.ysnDeleteFromRegister 
						WHEN 0 
							THEN 'addchange' 
						WHEN 1 
							THEN 'delete' 
						ELSE 'addchange' 
					END [CBTDetailRecordActionType] 
					, PSL.intPromoSalesId [PromotionID]
					, PSL.strPromoReason [PromotionReason]
					, NULL [SalesRestrictCode]
					, 2 [LinkCodeType]
					, NULL [LinkCodeValue]
					, PSL.strPromoSalesDescription [ComboDescription]
					, PSL.dblPromoPrice [ComboPrice]
					, PIL.intPromoItemListNo [ItemListID]
					, PSLD.intQuantity [ComboItemQuantity]
					, IUM.strUnitMeasure [ComboItemQuantityUOM]
					, PSLD.dblPrice [ComboItemUnitPrice]
					, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) [StartDate]
					, '0:00:01' [StartTime]
					, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) [StopDate]
					, '23:59:59' [StopTime]
					, PSL.intPurchaseLimit [TransactionLimit]
					, CASE 
						WHEN R.strRegisterClass = 'RADIANT' 
							THEN 0 
						ELSE NULL 
					END [Priority]
					, 'yes' [WeekdayAvailabilitySunday]
					, 'Sunday' [WeekdaySunday]
					, 'yes' [WeekdayAvailabilityMonday]
					, 'Monday' [WeekdayMonday]
					, 'yes' [WeekdayAvailabilityTuesday]
					, 'Tuesday' [WeekdayTuesday]
					, 'yes' [WeekdayAvailabilityWednesday]
					, 'Wednesday' [WeekdayWednesday]
					, 'yes' [WeekdayAvailabilityThursday]
					, 'Thursday' [WeekdayThursday]
					, 'yes' [WeekdayAvailabilityFriday]
					, 'Friday' [WeekdayFriday]
					, 'yes' [WeekdayAvailabilitySaturday]
					, 'Saturday' [WeekdaySaturday]
				FROM tblICItem I
				JOIN tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN tblSMCompanyLocation L 
					ON L.intCompanyLocationId = IL.intLocationId 
				JOIN tblSTStore ST 
					ON ST.intCompanyLocationId = L.intCompanyLocationId 
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionSalesList PSL 
					ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
				JOIN tblSTPromotionSalesListDetail PSLD 
					ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intPromoItemListId = PSLD.intPromoItemListId
				JOIN tblSTPromotionItemListDetail PILD 
					ON PILD.intPromoItemListId = PIL.intPromoItemListId
				JOIN tblICItemUOM IUOM 
					ON IUOM.intItemUOMId = PILD.intItemUOMId 
				JOIN tblICUnitMeasure IUM 
					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
				WHERE R.intRegisterId = @intRegisterId 
				AND ST.intStoreId = @intStoreId
				AND PSL.strPromoType = 'C' -- <--- 'C' = Combo
				-- AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId
	
				

				IF EXISTS(SELECT StoreLocationID FROM tblSTstgComboSalesFile)
					BEGIN
							--Generate XML for the pricebook data availavle in staging table
							Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgComboSalesFile~intComboSalesFile > 0', 0, @strGeneratedXML OUTPUT

							--Once XML is generated delete the data from pricebook  staging table.
							DELETE FROM tblSTstgComboSalesFile	
					END
				ELSE 
					BEGIN
							SET @ysnSuccessResult = CAST(0 AS BIT)
							SET @strMessageResult = 'No result found to generate Combo - ' + @strFilePrefix + ' Outbound file'
					END
				
			END

	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
END