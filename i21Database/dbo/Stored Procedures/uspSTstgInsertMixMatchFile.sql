CREATE PROCEDURE [dbo].[uspSTstgInsertMixMatchFile]
	@StoreId int
	, @Register int
	, @BeginningMixMatchId int
	, @EndingMixMatchId int
	, @BuildFileThruEndingDate Datetime
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @strResult NVARCHAR(1000) OUTPUT
AS
BEGIN
	
	DECLARE @strFilePrefix AS NVARCHAR(10) = 'MMT'


	DECLARE @strRegister NVARCHAR(200)
			, @strRegisterClass NVARCHAR(200)
			, @dblXmlVersion NUMERIC(4, 2)
	SELECT @strRegister = strRegisterName 
			, @strRegisterClass = strRegisterClass
			, @dblXmlVersion = dblXmlVersion
	FROM dbo.tblSTRegister 
	Where intRegisterId = @Register


	-- =========================================================================================================
	-- Check if register has intImportFileHeaderId
	IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @Register AND strFilePrefix = @strFilePrefix)
		BEGIN
				SELECT TOP 1 @intImportFileHeaderId = intImportFileHeaderId 
				FROM tblSTRegisterFileConfiguration 
				WHERE intRegisterId = @Register 
				AND strFilePrefix = @strFilePrefix
		END
	ELSE
		BEGIN
				SET @strGenerateXML = ''
				SET @intImportFileHeaderId = 0
				SET @strResult = 'Register ' + @strRegister + ' has no Outbound setup for Send Promotion Sales List File (' + @strFilePrefix + ')'

				RETURN
		END


	-- PASSPORT
	IF(@strRegisterClass = 'PASSPORT')
		BEGIN
			-- Create Unique Identifier
			-- Handles multiple Update of registers by different Stores
			DECLARE @strUniqueGuid AS NVARCHAR(50) = NEWID()

			-- Table and Condition
			DECLARE @strTableAndCondition AS NVARCHAR(250) = 'tblSTstgPassportPricebookMixMatchMMT33~strUniqueGuid=''' + @strUniqueGuid + ''''

			IF(@dblXmlVersion = 3.40)
				BEGIN
						INSERT INTO tblSTstgPassportPricebookMixMatchMMT33
						(
							[StoreLocationID], 
							[VendorName], 
							[VendorModelVersion], 
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
							, 'Rel. 13.2.0' AS [VendorModelVersion]
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
							, CONVERT(varchar, CAST('0:00:01' AS TIME), 108) AS [StartTime]
							, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) AS [StopDate]
							, CONVERT(varchar, CAST('23:59:59' AS TIME), 108) AS [StopTime] 
							, PSLD.intQuantity [MixMatchUnits]
							, PSLD.dblPrice [MixMatchPrice]
							, @strUniqueGuid AS [strUniqueGuid]
						FROM tblICItem I
						JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
						JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
						JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
						JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
						JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
						JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId
						JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId
						JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
						WHERE R.intRegisterId = @Register 
						AND ST.intStoreId = @StoreLocation 
						AND PSL.strPromoType = 'M'
						AND PSL.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId	

						IF EXISTS(SELECT StoreLocationID FROM tblSTstgPassportPricebookMixMatchMMT33)
						BEGIN
							--Generate XML for the pricebook data availavle in staging table
							EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, @strTableAndCondition, 0, @strGenerateXML OUTPUT

							--Once XML is generated delete the data from pricebook staging table.
							DELETE FROM tblSTstgPassportPricebookMixMatchMMT33
							WHERE strUniqueGuid = @strUniqueGuid
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
				, CASE PSL.ysnDeleteFromRegister WHEN 0 THEN 'addchange' WHEN 1 THEN 'delete' ELSE 'addchange' END as [MMTDetailRecordActionType] 
				, 'no' [MMTDetailRecordActionConfirm]
				, PSL.intPromoSalesId [PromotionID]
				, PSL.strPromoReason [PromotionReason]
				, PSL.strPromoSalesDescription [MixMatchDescription]
				, 1 [SalesRestrictCode]
				, CASE WHEN PSL.ysnPurchaseAtleastMin = 1 THEN 'yes' Else 'no' END [MixMatchStrictHighFlagValue]
				, CASE WHEN PSL.ysnPurchaseExactMultiples = 1 THEN 'yes' ELSE 'no' END [MixMatchStrictLowFlagValue]
				, PIL.intPromoItemListNo [ItemListID]
				, PSLD.intQuantity [MixMatchUnits]
				, PSLD.dblPrice [MixMatchPrice]
				, 'USD' [MixMatchPriceCurrency]	
				, CONVERT(nvarchar(10), PSL.dtmPromoBegPeriod, 126) [StartDate]
				, '0:00:01' [StartTime]
				, CONVERT(nvarchar(10), PSL.dtmPromoEndPeriod, 126) [StopDate]
				, '23:59:59' [StopTime]
				, CASE WHEN R.strRegisterClass = 'RADIANT' THEN 0 ELSE NULL END [Priority]
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
			from tblICItem I
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
			JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
			JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
			JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
			JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
			JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
			JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId
			JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
			JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
			WHERE R.intRegisterId = @Register AND ST.intStoreId = @StoreId AND PSL.strPromoType = 'M'
			AND PSL.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId

			--SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader 
			--Where strLayoutTitle = 'Pricebook Mix Match' AND strFileType = 'XML'
	
			--Generate XML for the pricebook data availavle in staging table
			Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgMixMatchFile~intMixMatchFile > 0', 0, @strGenerateXML OUTPUT

			--Once XML is generated delete the data from pricebook  staging table.
			DELETE FROM tblSTstgMixMatchFile	
		END

	SET @strResult = 'Success'
END