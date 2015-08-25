CREATE PROCEDURE [dbo].[uspSTstgInsertMixMatchFile]
	@StoreLocation int
	, @Register int
	, @BeginningMixMatchId int
	, @EndingMixMatchId int
	, @BuildFileThruEndingDate Datetime
AS
BEGIN

	INSERT INTO tblSTstgMixMatchFile
	SELECT 
	  ST.intStoreNo [StoreLocationID]
	, 'iRely' [VendorName]  	
	, 'Rel. 13.2.0' [VendorModelVersion]
	, 'update' [TableActionType]
	, 'addchange' [MixMatchMaintenanceRecordActionType]
	, CASE SaleList.ysnDeleteFromRegister WHEN 0 THEN 'addchange' WHEN 1 THEN 'delete' ELSE 'addchange' END as [CBTDetailRecordActionType] 
	, SaleList.intPromoSalesId [PromotionID]
	, SaleList.strPromoReason [PromotionReason]
	, SaleList.strPromoSalesDescription [MixMatchDescription]
	, '' [SalesRestrictCode]
	, PromoItem.intPromoItemListNo [ItemListID]
	, SaleListDet.intQuantity [MixMatchUnits]
	, SaleListDet.dblPrice [MixMatchPrice]
	, 'USD' [MixMatchPriceCurrency]
	from 
	tblSTStore ST
	JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
	LEFT JOIN tblSTPromotionSalesList SaleList ON SaleList.intStoreId = ST.intStoreId --AND SaleList.intRegProdId = SubCat.intRegProdId
	LEFT JOIN tblSTPromotionSalesListDetail SaleListDet ON SaleListDet.intPromoSalesListId = SaleList.intPromoSalesListId
	LEFT JOIN tblSTPromotionItemList PromoItem ON PromoItem.intPromoItemListId = SaleListDet.intPromoItemListId
	WHERE R.intRegisterId = @Register AND ST.intStoreId = @StoreLocation AND SaleList.strPromoType = 'M'
	AND SaleList.intPromoSalesId BETWEEN @BeginningMixMatchId AND @EndingMixMatchId

END