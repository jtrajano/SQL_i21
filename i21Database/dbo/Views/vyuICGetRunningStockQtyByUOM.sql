CREATE VIEW [dbo].[vyuICGetRunningStockQtyByUOM]
AS 

SELECT
	intKey = 
		CAST(ROW_NUMBER() OVER(ORDER BY 
			ItemStock.intItemId
			, ItemStock.intItemLocationId
			, ItemStock.intSubLocationId
			, ItemStock.intStorageLocationId
			, ItemStock.intItemUOMId) AS INT
		)
	, ItemStock.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, Item.intCategoryId
	, Category.strCategoryCode
	, Item.intCommodityId
	, Commodity.strCommodityCode
	, ItemStock.intItemLocationId
	, ItemLocation.intLocationId
	, ItemLocation.intCountGroupId
	, l.strLocationName
	, ItemStock.intSubLocationId
	, SubLocation.strSubLocationName
	, ItemStock.intStorageLocationId
	, strStorageLocationName = StorageLocation.strName
	, ItemStock.intItemUOMId
	, UOM.strUnitMeasure
	, ItemStock.dtmDate
	, ItemStock.dblOnHand
	, dblConversionFactor = ItemUOM.dblUnitQty
	, ItemPricing.dblLastCost
	, dblTotalCost = ItemStock.dblOnHand * ItemUOM.dblUnitQty * ItemPricing.dblLastCost
FROM		
	(
		SELECT	t.intItemId
				,t.intItemLocationId
				,t.intSubLocationId
				,t.intStorageLocationId
				,t.intItemUOMId
				,dtmDate --= CAST(CONVERT(VARCHAR(10),t.dtmDate,112) AS datetime)
				,dblOnHand = SUM(t.dblQty)				
		FROM 
			tblICInventoryTransaction t
		WHERE
			dblQty <> 0 			
		GROUP BY 
			t.intItemId
			, t.intItemLocationId
			, t.intSubLocationId
			, t.intStorageLocationId
			, t.intItemUOMId
			, t.dtmDate --CONVERT(VARCHAR(10),t.dtmDate,112)
	) ItemStock	
	INNER JOIN tblICItem Item 	
		ON Item.intItemId = ItemStock.intItemId
	LEFT JOIN tblICCategory Category 
		ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICCommodity Commodity 
		ON Commodity.intCommodityId = Item.intCommodityId
	LEFT JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemLocationId = ItemStock.intItemLocationId
	LEFT JOIN tblSMCompanyLocation l 
		ON l.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblICItemPricing ItemPricing 
		ON ItemPricing.intItemLocationId = ItemStock.intItemLocationId
	LEFT JOIN tblICItemUOM ItemUOM 
		ON ItemUOM.intItemUOMId = ItemStock.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM 
		ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = ItemStock.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation 
		ON StorageLocation.intStorageLocationId = ItemStock.intStorageLocationId