CREATE PROCEDURE [dbo].[uspSTstgInsertComboSalesFile]
	@StoreLocation int
	, @Register int
	, @BeginningComboId int
	, @EndingComboId int
AS
BEGIN

	Insert Into tblSTstgComboSalesFile
	SELECT 
	  ST.intStoreNo [StoreLocationID]
	, 'iRely' [VendorName]  	
	, 'Rel. 13.2.0' [VendorModelVersion]
	, 'update' [TableActionType]
	, 'addchange' [ComboMaintenanceRecordActionType]
	, CASE SaleList.ysnDeleteFromRegister WHEN 0 THEN 'addchange' WHEN 1 THEN 'delete' ELSE 'addchange' END as [CBTDetailRecordActionType] 
	, SaleList.intPromoSalesId [PromotionID]
	, '' [SalesRestrictCode]
	, '2' [LinkCodeType]
	, SaleList.strPromoSalesDescription [ComboDescription]
	, PromoItem.intPromoItemListNo [ItemListID]
	, SaleListDet.intQuantity [ComboItemQuantity]
	, SaleListDet.dblPrice [ComboItemUnitPrice]
	, SaleList.dtmPromoBegPeriod [StartDate]
	, SaleList.dtmPromoEndPeriod [StopDate]
	from 
	tblSTStore ST
	LEFT JOIN tblSTPromotionSalesList SaleList ON SaleList.intStoreId = ST.intStoreId 
	LEFT JOIN tblSTPromotionSalesListDetail SaleListDet ON SaleListDet.intPromoSalesListId = SaleList.intPromoSalesListId
	LEFT JOIN tblSTPromotionItemList PromoItem ON PromoItem.intPromoItemListId = SaleListDet.intPromoItemListId
	JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
	WHERE R.intRegisterId = @Register  AND ST.intStoreId = @StoreLocation AND SaleList.strPromoType = 'C'
	AND SaleList.intPromoSalesId BETWEEN @BeginningComboId AND @EndingComboId

END