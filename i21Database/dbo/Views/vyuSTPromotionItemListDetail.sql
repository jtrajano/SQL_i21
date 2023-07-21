
CREATE VIEW [dbo].[vyuSTPromotionItemListDetail]
AS

SELECT intPromoItemListDetailId,
	tblSTPromotionItemListDetail.intPromoItemListId,
	tblSTPromotionItemListDetail.intItemUOMId,
	strUpcDescription,
	intUpcModifier,
	strUpcCode,
    strLongUPCCode,
    strUnitMeasure,
	dblSalePrice AS dblRetailPrice
	
	FROM tblSTPromotionItemListDetail
		
	JOIN tblSTPromotionItemList ON 
	tblSTPromotionItemListDetail.intPromoItemListId = tblSTPromotionItemList.intPromoItemListId
		
	LEFT JOIN tblSTStore ON tblSTPromotionItemList.intStoreId = tblSTStore.intStoreId
		
	LEFT JOIN tblICItemUOM ON tblSTPromotionItemListDetail.intItemUOMId = tblICItemUOM.intItemUOMId
		
	LEFT JOIN tblICItemLocation ON tblSTStore.intCompanyLocationId = tblICItemLocation.intLocationId 
	AND tblICItemLocation.intItemId = tblICItemUOM.intItemId
		
	LEFT JOIN vyuSTItemHierarchyPricing ON tblSTPromotionItemListDetail.intItemUOMId = vyuSTItemHierarchyPricing.intItemUOMId
	AND vyuSTItemHierarchyPricing.intItemLocationId = tblICItemLocation.intItemLocationId

	LEFT JOIN tblICUnitMeasure ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId;

GO


