CREATE PROCEDURE [dbo].[uspSTstgInsertComboSalesFile]
	@StoreLocation int
	, @Register int
	, @BeginningComboId int
	, @EndingComboId int
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
AS
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
	JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
	JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
	JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
	JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId
	JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
	JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
	WHERE R.intRegisterId = @Register  AND ST.intStoreId = @StoreLocation AND PSL.strPromoType = 'C'
	AND PSL.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId
	

	SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader 
	Where strLayoutTitle = 'Pricebook Combo' AND strFileType = 'XML'
	
--Generate XML for the pricebook data availavle in staging table
	Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgComboSalesFile~intComboSalesFile > 0', 0, @strGenerateXML OUTPUT

--Once XML is generated delete the data from pricebook  staging table.
	DELETE FROM tblSTstgComboSalesFile	

END