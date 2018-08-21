CREATE PROCEDURE [dbo].[uspSTstgInsertPromotionItemListSend]
	@StoreLocation int
	, @Register int
	, @BeginningItemListId int
	, @EndingItemListId int
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
	, @strResult NVARCHAR(1000) OUTPUT
AS
BEGIN

	-- =========================================================================================================
	-- Check if register has intImportFileHeaderId
	DECLARE @strRegisterName nvarchar(200)
	        , @strRegisterClass NVARCHAR(200)
			, @dblXmlVersion NUMERIC(4, 2)
	SELECT @strRegisterName = strRegisterName 
		   , @strRegisterClass = strRegisterClass
		   , @dblXmlVersion = dblXmlVersion
	FROM dbo.tblSTRegister 
	Where intRegisterId = @Register

	IF EXISTS(SELECT intImportFileHeaderId FROM tblSTRegisterFileConfiguration WHERE intRegisterId = @Register AND strFilePrefix = 'ILT')
		BEGIN
			SELECT @intImportFileHeaderId = intImportFileHeaderId 
			FROM tblSTRegisterFileConfiguration 
			WHERE intRegisterId = @Register AND strFilePrefix = 'ILT'
		END
	ELSE
		BEGIN
			SET @intImportFileHeaderId = 0
		END	
	-- =========================================================================================================


	IF(@intImportFileHeaderId = 0)
	BEGIN
		SET @strGenerateXML = ''
		SET @intImportFileHeaderId = 0
		SET @strResult = 'Register ' + @strRegisterClass + ' has no Outbound setup for Send Promotion Item List File (ILT)'

		RETURN
	END


	DECLARE @XMLGatewayVersion nvarchar(100)
	SELECT @XMLGatewayVersion = dblXmlVersion FROM dbo.tblSTRegister WHERE intRegisterId = @Register

	IF(@strRegisterClass = 'PASSPORT')
		BEGIN
			IF(@dblXmlVersion = 3.40)
				BEGIN
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
						[POSCode]
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
						END [POSCode]
					FROM tblICItem I
					JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
					JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
					JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
					JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
					JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
					LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId
					JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
					JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId 
					WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @Register AND ST.intStoreId = @StoreLocation
					AND PIL.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId

					--Generate XML for the pricebook data availavle in staging table
					Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPassportPricebookItemListILT33~intPromotionItemListSend > 0', 0, @strGenerateXML OUTPUT

					--Once XML is generated delete the data from pricebook  staging table.
					DELETE FROM [tblSTstgPassportPricebookItemListILT33]	
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
				, CASE PIL.ysnDeleteFromRegister WHEN 0 THEN 'addchange' WHEN 1 THEN 'delete' ELSE 'addchange' END as [ILTDetailRecordActionType] 
				, PIL.intPromoItemListNo [ItemListID]
				, PIL.strPromoItemListDescription [ItemListDescription]
				, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) THEN 'PLU' ELSE 'upcA' END [POSCodeFormat]
				, CASE	WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as bigint),0) THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
						ELSE RIGHT('00000000000'+ISNULL(IUOM.strLongUPCCode,''),11) 
					END [POSCode]
				, IUM.strUnitMeasure [PosCodeModifierName] 
				, '0' [PosCodeModifierValue] 
				, Cat.strCategoryCode [MerchandiseCode]	
			from tblICItem I
			JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
			JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
			JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
			JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
			JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
			JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
			LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId
			JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
			JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId 
			WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @Register AND ST.intStoreId = @StoreLocation --AND SaleList.strPromoType = 'M'
			AND PIL.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId
	
	
			--Generate XML for the pricebook data availavle in staging table
			Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPromotionItemListSend~intPromotionItemListSend > 0', 0, @strGenerateXML OUTPUT

			--Once XML is generated delete the data from pricebook  staging table.
			DELETE FROM [tblSTstgPromotionItemListSend]	
		END

	
	
	SET @strResult = 'Success'
END