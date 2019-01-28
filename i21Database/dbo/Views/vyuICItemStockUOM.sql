CREATE VIEW [dbo].[vyuICItemStockUOM]
AS
SELECT 
	StockUOM.intSubLocationId,
	StockUOM.intStorageLocationId,
	ItemUOM.strUpcCode,
	ItemUOM.dblUnitQty,
	ItemUOM.strLongUPCCode,
	ItemUOM.ysnStockUnit,
	ItemUOM.intItemId,
	ItemUOM.intItemUOMId,
	ItemLocation.intItemLocationId,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblOnOrder, 0) - ISNULL(StockUnit.dblOnOrder, 0), 2)
		ELSE StockUOM.dblOnOrder
	END AS dblOnOrder, 
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblConsignedPurchase, 0) - ISNULL(StockUnit.dblConsignedPurchase, 0), 2)
		END AS dblConsignedPurchase,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblConsignedSale, 0) - ISNULL(StockUnit.dblConsignedSale, 0), 2)
		ELSE StockUOM.dblConsignedSale
	END AS dblConsignedSale,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblInTransitInbound, 0) - ISNULL(StockUnit.dblInTransitInbound, 0), 2)
		ELSE StockUOM.dblInTransitInbound
	END AS dblInTransitInbound,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblInTransitOutbound, 0) - ISNULL(StockUnit.dblInTransitOutbound, 0), 2)
		ELSE StockUOM.dblInTransitOutbound
	END AS dblInTransitOutbound,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblOrderCommitted, 0) - ISNULL(StockUnit.dblOrderCommitted, 0), 2)
		ELSE StockUOM.dblOrderCommitted
	END AS dblOrderCommitted,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblUnitReserved, 0) - ISNULL(StockUnit.dblUnitReserved, 0), 2)
		ELSE StockUOM.dblUnitReserved
	END AS dblUnitReserved,
	CASE WHEN ItemUOM.ysnStockUnit = 1 
		THEN ROUND(ISNULL(StockUOM.dblUnitStorage, 0) - ISNULL(StockUnit.dblUnitStorage, 0), 2)
		ELSE StockUOM.dblUnitStorage
	END AS dblUnitStorage,
	CASE WHEN ItemUOM.ysnStockUnit = 1
		THEN ROUND(ISNULL(StockUOM.dblOnHand, 0) - ISNULL(StockUnit.dblOnHand, 0), 2)
		ELSE StockUOM.dblOnHand
	END AS dblOnHand
FROM tblICItemStockUOM StockUOM
INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = StockUOM.intItemId
	AND ItemLocation.intItemLocationId = StockUOM.intItemLocationId
INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = StockUOM.intItemUOMId
OUTER APPLY (
	SELECT
		ItemUOM_StockUnit.intItemId,
		ItemLocation_StockUnit.intItemLocationId,
		StockUOM_StockUnit.intStorageLocationId,
		StockUOM_StockUnit.intSubLocationId,
		dblOnHand = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblOnHand)),
		dblInTransitInbound = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblInTransitInbound)),
		dblInTransitOutbound = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblInTransitOutbound)),
		dblConsignedPurchase = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblConsignedPurchase)),
		dblConsignedSale = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblConsignedSale)),
		dblOrderCommitted = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblOrderCommitted)),
		dblUnitReserved = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblUnitReserved)),
		dblOnOrder = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblOnOrder)),
		dblUnitStorage = SUM([dbo].[fnICConvertUOMtoStockUnit](ItemUOM_StockUnit.intItemId, ItemUOM_StockUnit.intItemUOMId, StockUOM_StockUnit.dblUnitStorage))
	FROM tblICItemUOM ItemUOM_StockUnit
		INNER JOIN tblICItemLocation ItemLocation_StockUnit ON ItemLocation_StockUnit.intItemId = ItemUOM_StockUnit.intItemId
		INNER JOIN tblICItemStockUOM StockUOM_StockUnit ON StockUOM_StockUnit.intItemUOMId = ItemUOM_StockUnit.intItemUOMId
			AND StockUOM_StockUnit.intItemId = ItemUOM_StockUnit.intItemId
			AND StockUOM_StockUnit.intItemLocationId = ItemLocation_StockUnit.intItemLocationId
	WHERE ItemUOM_StockUnit.ysnStockUnit <> 1
		AND ItemUOM_StockUnit.intItemId = ItemUOM.intItemId
		AND StockUOM_StockUnit.intItemLocationId = StockUOM.intItemLocationId
		AND (ISNULL(StockUOM_StockUnit.intSubLocationId, '') = ISNULL(StockUOM.intSubLocationId, '')  OR StockUOM_StockUnit.intSubLocationId = StockUOM.intSubLocationId)
		AND (ISNULL(StockUOM_StockUnit.intStorageLocationId, '') = ISNULL(StockUOM.intStorageLocationId,'') OR StockUOM_StockUnit.intStorageLocationId = StockUOM.intStorageLocationId)
	GROUP BY ItemUOM_StockUnit.intItemId, ItemLocation_StockUnit.intItemLocationId, StockUOM_StockUnit.intStorageLocationId, StockUOM_StockUnit.intSubLocationId
) StockUnit