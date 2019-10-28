CREATE VIEW [dbo].[vyuICGetRunningStockQtyByStockUOM]
AS 

SELECT
	intKey = 
		CAST(ROW_NUMBER() OVER(ORDER BY 
			ItemStock.intItemId
			, ItemStock.intItemLocationId
			, ItemStock.intSubLocationId
			, ItemStock.intStorageLocationId
			, ItemUOM.intItemUOMId) AS INT
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
	, ItemUOM.intItemUOMId
	, UOM.strUnitMeasure
	, ItemStock.dtmDate
	, dblOnHand = dbo.fnCalculateQtyBetweenUOM(stockUOM.intItemUOMId, ItemUOM.intItemUOMId, ItemStock.dblOnHand) 
	, dblConversionFactor = ItemUOM.dblUnitQty
	, ItemPricing.dblLastCost
	, dblTotalCost = ItemStock.dblOnHand * ItemUOM.dblUnitQty * ItemPricing.dblLastCost
FROM		
	(
		SELECT	t.intItemId
				,t.intItemLocationId
				,t.intSubLocationId
				,t.intStorageLocationId
				,dtmDate = CAST(CONVERT(VARCHAR(10),t.dtmDate,112) AS datetime)
				,dblOnHand = SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, stockUOM.intItemUOMId, t.dblQty)) 
		FROM 
			tblICInventoryTransaction t INNER JOIN tblICItemUOM stockUOM 
				ON t.intItemId = stockUOM.intItemId
				AND stockUOM.ysnStockUnit = 1
		WHERE
			dblQty <> 0 			
		GROUP BY 
			t.intItemId
			, t.intItemLocationId
			, t.intSubLocationId
			, t.intStorageLocationId
			, CONVERT(VARCHAR(10),t.dtmDate,112)
	) ItemStock	
	INNER JOIN tblICItem Item 	
		ON Item.intItemId = ItemStock.intItemId
	INNER JOIN tblICItemUOM ItemUOM 
		ON ItemUOM.intItemId = Item.intItemId
	INNER JOIN tblICItemUOM stockUOM 
		ON Item.intItemId = stockUOM.intItemId
		AND stockUOM.ysnStockUnit = 1
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
	LEFT JOIN tblICUnitMeasure UOM 
		ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = ItemStock.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation 
		ON StorageLocation.intStorageLocationId = ItemStock.intStorageLocationId