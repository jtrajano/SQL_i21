CREATE PROCEDURE [dbo].[uspSTstgInsertComboSalesFile]
	@StoreLocation int
	, @Register int
	, @BeginningComboId int
	, @EndingComboId int
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @strResult NVARCHAR(1000) OUTPUT
AS
BEGIN
	
	DECLARE @strFilePrefix AS NVARCHAR(10) = 'CBT'

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
	IF EXISTS(SELECT * FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @Register AND strFilePrefix = 'CBT')
		BEGIN
				SELECT TOP 1 @intImportFileHeaderId = intImportFileHeaderId 
				FROM tblSTRegisterFileConfiguration 
				WHERE intRegisterId = @Register 
				AND strFilePrefix = 'CBT'
		END
	ELSE
		BEGIN
				SET @strGenerateXML = ''
				SET @intImportFileHeaderId = 0
				SET @strResult = 'Register ' + @strRegister + ' has no Outbound setup for Send Promotion Sales List File (CBT)'

				RETURN
		END

	--IF EXISTS(SELECT IFH.intImportFileHeaderId 
	--				  FROM dbo.tblSMImportFileHeader IFH
	--				  JOIN dbo.tblSTRegisterFileConfiguration FC ON FC.intImportFileHeaderId = IFH.intImportFileHeaderId
	--				  Where IFH.strLayoutTitle = 'Pricebook Combo' AND IFH.strFileType = 'XML' AND FC.intRegisterId = @Register)
	--	BEGIN
	--		--SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader 
	--		--Where strLayoutTitle = 'Pricebook Combo' AND strFileType = 'XML'

	--		SELECT @intImportFileHeaderId = IFH.intImportFileHeaderId 
	--		FROM dbo.tblSMImportFileHeader IFH
	--		JOIN dbo.tblSTRegisterFileConfiguration FC ON FC.intImportFileHeaderId = IFH.intImportFileHeaderId
	--		Where IFH.strLayoutTitle = 'Pricebook Combo' AND IFH.strFileType = 'XML' AND FC.intRegisterId = @Register
	--	END
	--ELSE
	--	BEGIN
	--		SET @intImportFileHeaderId = 0
	--	END	
	-- =========================================================================================================



	--IF(@intImportFileHeaderId = 0)
	--BEGIN
	--	SET @strGenerateXML = ''
	--	SET @intImportFileHeaderId = 0
	--	SET @strResult = 'Register ' + @strRegister + ' has no Outbound setup for Send Promotion Sales List File'

	--	RETURN
	--END


	-- PASSPORT
	IF(@strRegisterClass = 'PASSPORT')
		BEGIN
			IF(@dblXmlVersion = 3.40)
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
						[StopTime] 
					)
					SELECT DISTINCT
						ST.intStoreNo AS [StoreLocationID]
						, 'iRely' AS [VendorName] 
						, 'Rel. 10.2.0' AS [VendorModelVersion] 
						, 'update' AS [TableActionType]
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
					from tblICItem I
					JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId 
					JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
					JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
					JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
					JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
					JOIN tblSTPromotionItemList PIL ON PIL.intPromoItemListId = PSLD.intPromoItemListId
					JOIN tblSTPromotionItemListDetail PILD ON PILD.intPromoItemListId = PIL.intPromoItemListId
					JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = PILD.intItemUOMId 
					JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
					WHERE R.intRegisterId = @Register  AND ST.intStoreId = @StoreLocation AND PSL.strPromoType = 'C'
					AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId

					--Generate XML for the pricebook data availavle in staging table
					EXEC dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPassportPricebookComboCBT33~intComboSalesFile > 0', 0, @strGenerateXML OUTPUT

					--Once XML is generated delete the data from pricebook staging table.
					DELETE FROM tblSTstgPassportPricebookComboCBT33
				END
		END
	-- RADIANT
	ELSE IF(@strRegisterClass = 'RADIANT')
		BEGIN
			Insert Into tblSTstgComboSalesFile
			SELECT DISTINCT
			  ST.intStoreNo [StoreLocationID]
				, 'iRely' [VendorName]  	
				, 'Rel. 13.2.0' [VendorModelVersion]
				, 'update' [TableActionType]
				, 'addchange' [RecordActionType] 
				, CASE PSL.ysnDeleteFromRegister WHEN 0 THEN 'addchange' WHEN 1 THEN 'delete' ELSE 'addchange' END [CBTDetailRecordActionType] 
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
			from tblICItem I
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
			JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId 
			JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
			JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
			JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
			JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
			JOIN tblSTPromotionItemList PIL ON PIL.intPromoItemListId = PSLD.intPromoItemListId
			JOIN tblSTPromotionItemListDetail PILD ON PILD.intPromoItemListId = PIL.intPromoItemListId
			JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = PILD.intItemUOMId 
			JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 

			--JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
			--JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
			--JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
			--JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
			--JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
			--JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
			--JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId
			--JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
			--JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId

			WHERE R.intRegisterId = @Register  AND ST.intStoreId = @StoreLocation AND PSL.strPromoType = 'C'
			AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId
	
	
			--Generate XML for the pricebook data availavle in staging table
			Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgComboSalesFile~intComboSalesFile > 0', 0, @strGenerateXML OUTPUT

			--Once XML is generated delete the data from pricebook  staging table.
			DELETE FROM tblSTstgComboSalesFile	
		END

	

	SET @strResult = 'Success'
END