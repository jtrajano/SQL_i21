CREATE PROCEDURE [dbo].[uspSTstgInsertMixMatchFile]
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

		-- DECLARE @strFilePrefix AS NVARCHAR(10) = 'MMT'

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
					SET @strMessageResult = 'Register ' + @strRegister + ' has no Outbound setup for Promotion Sales List - Mix and Match (' + @strFilePrefix + ')'

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
				DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookMixMatchMMT33~strUniqueGuid=''' + @strUniqueGuid + ''''

				IF(@strXmlVersion = '3.4')
					BEGIN
							INSERT INTO tblSTstgPassportPricebookMixMatchMMT33
							(
								[StoreLocationID], 
								[VendorName], 
								[VendorModelVersion], 
								[TableActionType], 
								[RecordActionType], 
								[MMTDetailRecordActionType], 
								[PromotionID], 
								[PromotionReason], 
								[MixMatchDescription],
								[TransactionLimit],
								[ItemListID],
								[StartDate],
								[StartTime],
								[StopDate],
								[StopTime],
								[MixMatchUnits],
								[MixMatchPrice],
								[strUniqueGuid]
							)
							SELECT DISTINCT
								ST.intStoreNo AS [StoreLocationID]
								, 'iRely' AS [VendorName]  	
								, (SELECT TOP (1) strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC) AS [VendorModelVersion]
								, CASE
									WHEN @ysnClearRegisterPromotion = CAST(1 AS BIT) THEN 'initialize'
									WHEN @ysnClearRegisterPromotion = CAST(0 AS BIT) THEN 'update'
								END AS [TableActionType]
								, 'addchange' AS [RecordActionType] 
								, CASE PSL.ysnDeleteFromRegister 
									WHEN 0 
										THEN 'addchange' 
									WHEN 1 
										THEN 'delete' 
									ELSE 'addchange' 
								END AS [MMTDetailRecordActionType] 
								, PSL.intPromoSalesId AS [PromotionID]
								, PSL.strPromoReason AS [PromotionReason]
								, PSL.strPromoSalesDescription AS [MixMatchDescription]
								, 9999 AS [TransactionLimit]
								, PIL.intPromoItemListNo AS [ItemListID]
								, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) AS [StartDate]
								, CONVERT(varchar, CAST('0:00:00' AS TIME), 108) AS [StartTime]
								, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) AS [StopDate]
								, CONVERT(varchar, CAST('23:59:59' AS TIME), 108) AS [StopTime] 
								, PSL.intPromoUnits [MixMatchUnits]
								, PSL.dblPromoPrice [MixMatchPrice]
								--, PSLD.intQuantity [MixMatchUnits]
								--, PSLD.dblPrice [MixMatchPrice]
								, @strUniqueGuid AS [strUniqueGuid]
							FROM tblSTPromotionSalesListDetail PSLD
							INNER JOIN tblSTPromotionSalesList PSL
								ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
							INNER JOIN tblSTPromotionItemList PIL 
								ON PSLD.intPromoItemListId = PIL.intPromoItemListId
							INNER JOIN tblSTStore ST 
								ON PSL.intStoreId = ST.intStoreId
							INNER JOIN tblSTRegister R 
								ON R.intRegisterId = ST.intRegisterId
							INNER JOIN tblSMCompanyLocation CL 
								ON ST.intCompanyLocationId = CL.intCompanyLocationId
							INNER JOIN tblICItemLocation IL
								ON CL.intCompanyLocationId = IL.intLocationId
							--FROM tblICItem I
							--JOIN tblICItemLocation IL 
							--	ON IL.intItemId = I.intItemId
							--JOIN tblSMCompanyLocation L 
							--	ON L.intCompanyLocationId = IL.intLocationId
							--JOIN tblICItemUOM IUOM 
							--	ON IUOM.intItemId = I.intItemId 
							--JOIN tblICUnitMeasure IUM 
							--	ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
							--JOIN tblSTStore ST 
							--	ON ST.intCompanyLocationId = L.intCompanyLocationId 
							--JOIN tblSTRegister R 
							--	ON R.intStoreId = ST.intStoreId
							--JOIN tblSTPromotionItemList PIL 
							--	ON PIL.intStoreId = ST.intStoreId
							--JOIN tblSTPromotionSalesList PSL 
							--	ON PSL.intStoreId = ST.intStoreId
							--JOIN tblSTPromotionSalesListDetail PSLD 
							--	ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
							--WHERE R.intRegisterId = @intRegisterId 
							AND ST.intStoreId = @intStoreId
							AND PSL.strPromoType = 'M' -- <--- 'M' = Mix and Match
							-- AND PSL.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId	

							IF EXISTS(SELECT TOP 1 1 FROM tblSTstgPassportPricebookMixMatchMMT33 WHERE strUniqueGuid = @strUniqueGuid)
								BEGIN
									--Generate XML for the pricebook data availavle in staging table
									EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGeneratedXML OUTPUT

									--Once XML is generated delete the data from pricebook staging table.
									DELETE 
									FROM tblSTstgPassportPricebookMixMatchMMT33
									WHERE strUniqueGuid = @strUniqueGuid
								END
							ELSE 
								BEGIN
									SET @ysnSuccessResult = CAST(0 AS BIT)
									SET @strMessageResult = 'No result found to generate Mix/Match - ' + @strFilePrefix + ' Outbound file'
								END
					END
			END
		-- RADIANT
		ELSE IF(@strRegisterClass = 'RADIANT')
			BEGIN
				INSERT INTO tblSTstgMixMatchFile
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
					END AS [MMTDetailRecordActionType] 
					, 'no' [MMTDetailRecordActionConfirm]
					, PSL.intPromoSalesId [PromotionID]
					, PSL.strPromoReason [PromotionReason]
					, PSL.strPromoSalesDescription [MixMatchDescription]
					, 1 [SalesRestrictCode]
					, CASE 
						WHEN PSL.ysnPurchaseAtleastMin = 1 
							THEN 'yes' 
						ELSE 'no' 
					END [MixMatchStrictHighFlagValue]
					, CASE 
						WHEN PSL.ysnPurchaseExactMultiples = 1 
							THEN 'yes' 
						ELSE 'no' 
					END [MixMatchStrictLowFlagValue]
					, PIL.intPromoItemListNo [ItemListID]
					, PSLD.intQuantity [MixMatchUnits]
					, PSLD.dblPrice [MixMatchPrice]
					, 'USD' [MixMatchPriceCurrency]	
					, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) [StartDate]
					, '0:00:01' [StartTime]
					, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) [StopDate]
					, '23:59:59' [StopTime]
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
					, NULL [MixMatchPromotions]
					, R.strRegisterStoreId [DiscountExternalID]
				FROM tblICItem I
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
				JOIN tblSTRegister R 
					ON R.intStoreId = ST.intStoreId
				JOIN tblSTPromotionItemList PIL 
					ON PIL.intStoreId = ST.intStoreId
				JOIN tblSTPromotionSalesList PSL 
					ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
				JOIN tblSTPromotionSalesListDetail PSLD 
					ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
				WHERE R.intRegisterId = @intRegisterId 
				AND ST.intStoreId = @intStoreId 
				AND PSL.strPromoType = 'M' -- <--- 'M' = Mix and Match
				-- AND PSL.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId
				


				IF EXISTS(SELECT StoreLocationID FROM tblSTstgMixMatchFile)
					BEGIN
							-- Generate XML for the pricebook data availavle in staging table
							EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgMixMatchFile~intMixMatchFile > 0', 0, @strGeneratedXML OUTPUT

							-- Once XML is generated delete the data from pricebook  staging table.
							DELETE FROM tblSTstgMixMatchFile
					END
				ELSE 
					BEGIN
							SET @ysnSuccessResult = CAST(0 AS BIT)
							SET @strMessageResult = 'No result found to generate Mix/Match - ' + @strFilePrefix + ' Outbound file'
					END
			END

	END TRY

	BEGIN CATCH
		SET @ysnSuccessResult = CAST(0 AS BIT)
		SET @strMessageResult = ERROR_MESSAGE()
	END CATCH
END