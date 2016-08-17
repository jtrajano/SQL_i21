CREATE PROCEDURE [dbo].[uspICIncreaseInTransitOutBoundQty]
	@ItemsToIncreaseInTransitOutBound AS InTransitTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Do an upsert for the Item Stock table when updating the In-Transit Outbound Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,Aggregrate_InTransitOutboundQty = SUM(ISNULL(dblQty, 0) * ISNULL(tblICItemUOM.dblUnitQty, 0))					
		FROM	@ItemsToIncreaseInTransitOutBound ItemsToIncreaseInTransitOutBound LEFT JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty --CASE WHEN ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty < 0 THEN 0 ELSE ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblInTransitOutbound
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,CASE WHEN Source_Query.Aggregrate_InTransitOutboundQty < 0 THEN 0 ELSE Source_Query.Aggregrate_InTransitOutboundQty END -- dblInTransitOutbound
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the In-Transit Outbound Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,ItemsToIncreaseInTransitOutBound.intItemUOMId
				-- Remove the sub and storage locations. These are irrelevant for In-Transit Qty. 
				,Aggregrate_InTransitOutboundQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseInTransitOutBound ItemsToIncreaseInTransitOutBound INNER JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId				
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
				, ItemsToIncreaseInTransitOutBound.intItemUOMId

		UNION ALL 
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,StockUOM.intItemUOMId
				-- Remove the sub and storage locations. These are irrelevant for In-Transit Qty. 
				,Aggregrate_InTransitOutboundQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseInTransitOutBound ItemsToIncreaseInTransitOutBound INNER JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
				INNER JOIN dbo.tblICItemUOM StockUOM
					ON StockUOM.intItemId = ItemsToIncreaseInTransitOutBound.intItemId 
					AND StockUOM.ysnStockUnit = 1
					AND StockUOM.intItemUOMId <> tblICItemUOM.intItemUOMId

		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
				, StockUOM.intItemUOMId


) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty -- CASE WHEN ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dblInTransitOutbound
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.Aggregrate_InTransitOutboundQty --CASE WHEN Source_Query.Aggregrate_InTransitOutboundQty < 0 THEN 0 ELSE Source_Query.Aggregrate_InTransitOutboundQty END
		,1	
	)
;
