CREATE VIEW [dbo].[vyuICGetItemStockSummary]
	AS 

SELECT
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY ItemStock.intItemId
			, ItemStock.intItemLocationId
			, ItemStock.intSubLocationId
			, ItemStock.intStorageLocationId
			, ItemStock.intItemUOMId) AS INT)
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
	, ItemStock.dblStockIn
	, ItemStock.dblStockOut
	, ItemStock.dblOnHand
	, dblConversionFactor = ItemUOM.dblUnitQty
	, ItemPricing.dblLastCost
	, dblTotalCost = ItemStock.dblOnHand * ItemUOM.dblUnitQty * ItemPricing.dblLastCost
FROM (
	SELECT intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
			, dblStockIn = SUM(dblStockIn)
			, dblStockOut = SUM(dblStockOut)
			, dblOnHand = SUM(dblStockIn) - SUM(dblStockOut)
	FROM (
		SELECT f.intItemId
			, f.intItemLocationId
			, intSubLocationId = r.intSubLocationId
			, intStorageLocationId = r.intStorageLocationId
			, f.intItemUOMId
			, dblStockIn = SUM(f.dblStockIn)
			, dblStockOut = SUM(f.dblStockOut)
			, dblOnHand = SUM(f.dblStockIn) - SUM(f.dblStockOut)
		FROM tblICInventoryFIFO f
			LEFT JOIN tblICInventoryReceiptItem r ON r.intInventoryReceiptItemId = f.intTransactionDetailId
				AND r.intInventoryReceiptId = f.intTransactionId
		GROUP BY f.intItemId, f.intItemLocationId, f.intItemUOMId, r.intSubLocationId, r.intStorageLocationId

		UNION ALL

		SELECT f.intItemId
			, f.intItemLocationId
			, intSubLocationId = r.intSubLocationId
			, intStorageLocationId = r.intStorageLocationId
			, f.intItemUOMId
			, dblStockIn = SUM(f.dblStockIn)
			, dblStockOut = SUM(f.dblStockOut)
			, dblOnHand = SUM(f.dblStockIn) - SUM(f.dblStockOut)
		FROM tblICInventoryLIFO f
			LEFT JOIN tblICInventoryReceiptItem r ON r.intInventoryReceiptItemId = f.intTransactionDetailId
				AND r.intInventoryReceiptId = f.intTransactionId
		GROUP BY f.intItemId, f.intItemLocationId, f.intItemUOMId, r.intSubLocationId, r.intStorageLocationId

		UNION ALL

		SELECT f.intItemId
			, f.intItemLocationId
			, intSubLocationId = r.intSubLocationId
			, intStorageLocationId = r.intStorageLocationId
			, f.intItemUOMId
			, dblStockIn = SUM(f.dblStockIn)
			, dblStockOut = SUM(f.dblStockOut)
			, dblOnHand = SUM(f.dblStockIn) - SUM(f.dblStockOut)
		FROM tblICInventoryLot f
			LEFT JOIN tblICInventoryReceiptItem r ON r.intInventoryReceiptItemId = f.intTransactionDetailId
				AND r.intInventoryReceiptId = f.intTransactionId
		GROUP BY f.intItemId, f.intItemLocationId, f.intItemUOMId, r.intSubLocationId, r.intStorageLocationId

		UNION ALL

		SELECT f.intItemId
			, f.intItemLocationId
			, intSubLocationId = r.intSubLocationId
			, intStorageLocationId = r.intStorageLocationId
			, f.intItemUOMId
			, dblStockIn = SUM(f.dblStockIn)
			, dblStockOut = SUM(f.dblStockOut)
			, dblOnHand = SUM(f.dblStockIn) - SUM(f.dblStockOut)
		FROM tblICInventoryActualCost f
			LEFT JOIN tblICInventoryReceiptItem r ON r.intInventoryReceiptItemId = f.intTransactionDetailId
				AND r.intInventoryReceiptId = f.intTransactionId
		GROUP BY f.intItemId, f.intItemLocationId, f.intItemUOMId, r.intSubLocationId, r.intStorageLocationId

		UNION ALL

		SELECT f.intItemId
			, f.intItemLocationId
			, intSubLocationId = r.intSubLocationId
			, intStorageLocationId = r.intStorageLocationId
			, f.intItemUOMId
			, dblStockIn = SUM(f.dblStockIn)
			, dblStockOut = SUM(f.dblStockOut)
			, dblOnHand = SUM(f.dblStockIn) - SUM(f.dblStockOut)
		FROM tblICInventoryFIFOStorage f
			LEFT JOIN tblICInventoryReceiptItem r ON r.intInventoryReceiptItemId = f.intTransactionDetailId
				AND r.intInventoryReceiptId = f.intTransactionId
		GROUP BY f.intItemId, f.intItemLocationId, f.intItemUOMId, r.intSubLocationId, r.intStorageLocationId

		UNION ALL

		SELECT f.intItemId
			, f.intItemLocationId
			, intSubLocationId = r.intSubLocationId
			, intStorageLocationId = r.intStorageLocationId
			, f.intItemUOMId
			, dblStockIn = SUM(f.dblStockIn)
			, dblStockOut = SUM(f.dblStockOut)
			, dblOnHand = SUM(f.dblStockIn) - SUM(f.dblStockOut)
		FROM tblICInventoryLIFOStorage f
			LEFT JOIN tblICInventoryReceiptItem r ON r.intInventoryReceiptItemId = f.intTransactionDetailId
				AND r.intInventoryReceiptId = f.intTransactionId
		GROUP BY f.intItemId, f.intItemLocationId, f.intItemUOMId, r.intSubLocationId, r.intStorageLocationId

		UNION ALL
		SELECT intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
			, dblStockIn = SUM(dblStockIn)
			, dblStockOut = SUM(dblStockOut)
			, dblOnHand = SUM(dblStockIn) - SUM(dblStockOut)
		FROM tblICInventoryLotStorage
		GROUP BY intItemId, intItemLocationId, intSubLocationId, intStorageLocationId, intItemUOMId
		) tblCostingBuckets
	GROUP BY intItemId
			, intItemLocationId
			, intSubLocationId
			, intStorageLocationId
			, intItemUOMId
	) ItemStock
	LEFT JOIN tblICItem Item 
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