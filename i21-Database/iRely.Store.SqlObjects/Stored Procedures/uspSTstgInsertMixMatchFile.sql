CREATE PROCEDURE [dbo].[uspSTstgInsertMixMatchFile]
	@StoreLocation int
	, @Register int
	, @BeginningMixMatchId int
	, @EndingMixMatchId int
	, @BuildFileThruEndingDate Datetime
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
AS
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
	WHERE R.intRegisterId = @Register AND ST.intStoreId = @StoreLocation AND PSL.strPromoType = 'M'
	AND PSL.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId

	SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader 
	Where strLayoutTitle = 'Pricebook Mix Match' AND strFileType = 'XML'
	
--Generate XML for the pricebook data availavle in staging table
	Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgMixMatchFile~intMixMatchFile > 0', 0, @strGenerateXML OUTPUT

--Once XML is generated delete the data from pricebook  staging table.
	DELETE FROM tblSTstgMixMatchFile	

END