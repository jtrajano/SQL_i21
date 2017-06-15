CREATE PROCEDURE [dbo].[uspSTstgInsertPromotionItemListSend]
	@StoreLocation int
	, @Register int
	, @BeginningItemListId int
	, @EndingItemListId int
	, @strGenerateXML nvarchar(max) OUTPUT
	, @intImportFileHeaderId INT OUTPUT
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
	

	SELECT @intImportFileHeaderId = intImportFileHeaderId FROM dbo.tblSMImportFileHeader 
	Where strLayoutTitle = 'Promotion Item List' AND strFileType = 'XML'
	
--Generate XML for the pricebook data availavle in staging table
	Exec dbo.uspSMGenerateDynamicXML @intImportFileHeaderId, 'tblSTstgPromotionItemListSend~intPromotionItemListSend > 0', 0, @strGenerateXML OUTPUT

--Once XML is generated delete the data from pricebook  staging table.
	DELETE FROM [tblSTstgPromotionItemListSend]	
	
END