CREATE PROCEDURE [dbo].[uspSTstgInsertPromotionItemListSend]
	@StoreLocation int
	, @Register int
	, @BeginningItemListId int
	, @EndingItemListId int
AS
BEGIN

	DECLARE @XMLGatewayVersion nvarchar(100)
	SELECT @XMLGatewayVersion = dblXmlVersion FROM dbo.tblSTRegister WHERE intRegisterId = @Register

	INSERT INTO [tblSTstgPromotionItemListSend]
	SELECT 
	  ST.intStoreNo [StoreLocationID]
	, 'iRely' [VendorName]  	
	, 'Rel. 13.2.0' [VendorModelVersion]
	, 'update' [TableActionType]
	, 'addchange' [ItemListMaintenanceRecordActionType]
	, CASE PromoItem.ysnDeleteFromRegister WHEN 0 THEN 'addchange' WHEN 1 THEN 'delete' ELSE 'addchange' END as [ILTDetailRecordActionType] 
	, PromoItem.intPromoItemListNo [ItemListID]
	, PromoItem.strPromoItemListDescription [ItemListDescription]
	, CASE WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN 'PLU' ELSE 'upcA' END [POSCodeFormat]
	, CASE	WHEN ISNULL(ST.intMaxPlu,0) > ISNULL(CAST(IUOM.strUpcCode as int),0) THEN RIGHT('0000'+ISNULL(IUOM.strUpcCode,''),4) 
			ELSE RIGHT('00000000000'+ISNULL(IUOM.strUpcCode,''),11) 
		END [POSCode]
	, IUM.strUnitMeasure [PosCodeModifierName] 
	from 
	tblSTStore ST
	JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
	LEFT JOIN tblSTPromotionItemList PromoItem ON PromoItem.intStoreId = ST.intStoreId
	JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = ST.intCompanyLocationId
	JOIN tblICItemLocation IL ON IL.intLocationId = L.intCompanyLocationId
	JOIN tblICItem I ON I.intItemId = IL.intItemId
	JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
	WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @Register AND ST.intStoreId = @StoreLocation --AND SaleList.strPromoType = 'M'
	AND PromoItem.intPromoItemListId BETWEEN @BeginningItemListId AND @EndingItemListId
	

END