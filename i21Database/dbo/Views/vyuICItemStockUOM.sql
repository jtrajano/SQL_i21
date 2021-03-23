CREATE VIEW [dbo].[vyuICItemStockUOM]
AS
SELECT 
	intSubLocationId = ISNULL(StockUnit.intSubLocationId, StockUOM.intSubLocationId)
	,intStorageLocationId = ISNULL(StockUnit.intSubLocationId, StockUOM.intStorageLocationId)
	,iu.strUpcCode
	,iu.dblUnitQty
	,iu.strLongUPCCode
	,iu.ysnStockUnit
	,i.intItemId
	,iu.intItemUOMId
	,il.intItemLocationId
	,u.strUnitMeasure
	,dblOnOrder = 
		CASE WHEN iu.ysnStockUnit = 1 THEN 
			ISNULL(StockUnit.dblOnOrder, 0)
		ELSE 
			ISNULL(StockUOM.dblOnOrder, 0)
	END 
	,dblConsignedPurchase  = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblConsignedPurchase, 0)
			ELSE
				ISNULL(StockUOM.dblConsignedPurchase, 0)
		END
	,dblConsignedSale 
		= CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblConsignedSale, 0)
			ELSE 
				ISNULL(StockUOM.dblConsignedSale, 0)
	END
	,dblInTransitInbound = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblInTransitInbound, 0)
			ELSE 
				ISNULL(StockUOM.dblInTransitInbound, 0)
		END
	,dblInTransitOutbound = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblInTransitOutbound, 0)
			ELSE 
				ISNULL(StockUOM.dblInTransitOutbound, 0) 
		END
	,dblOrderCommitted = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblOrderCommitted, 0)
			ELSE 
				ISNULL(StockUOM.dblOrderCommitted, 0) 
		END 
	,dblUnitReserved = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblUnitReserved, 0)
			ELSE 
				ISNULL(StockUOM.dblUnitReserved, 0) 
		END 
	,dblUnitStorage = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 
				ISNULL(StockUnit.dblUnitStorage, 0)
			ELSE 
				ISNULL(StockUOM.dblUnitStorage, 0) 
		END 
	,dblOnHand = 
		CASE 
			WHEN iu.ysnStockUnit = 1 THEN 				
				ISNULL(StockUnit.dblOnHand, 0)
			ELSE 
				ISNULL(StockUOM.dblOnHand, 0) 
		END 
FROM 
	tblICItem i INNER JOIN tblICItemLocation il 
		ON i.intItemId = il.intItemId
	INNER JOIN tblICItemUOM iu 
		ON iu.intItemId = i.intItemId
	INNER JOIN tblICUnitMeasure u
		ON u.intUnitMeasureId = iu.intUnitMeasureId
 
	OUTER APPLY (
		SELECT 
			StockUnit.*
		FROM 
			tblICItemStockUOM StockUnit 
		WHERE
			StockUnit.intItemId = i.intItemId
			AND StockUnit.intItemLocationId = il.intItemLocationId
			AND StockUnit.intItemUOMId = iu.intItemUOMId
			AND iu.ysnStockUnit = 1 
	) StockUnit

	OUTER APPLY (
		SELECT 
			StockUOM.*
		FROM 
			tblICItemStockUOM StockUOM 
		WHERE
			StockUOM.intItemId = i.intItemId
			AND StockUOM.intItemLocationId = il.intItemLocationId
			AND StockUOM.intItemUOMId = iu.intItemUOMId
			AND iu.ysnStockUnit <> 1 
	) StockUOM

