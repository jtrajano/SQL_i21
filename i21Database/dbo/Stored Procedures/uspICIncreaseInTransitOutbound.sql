CREATE PROCEDURE [dbo].[uspICIncreaseInTransitOutbound]
	@ItemsToIncreaseInTransitOutbound AS ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Do an upsert for the Item Stock table when updating the Order Committed
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	intItemId
				,intItemLocationId
				,Aggregrate_InTransitOutbound = SUM(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0))					
		FROM	@ItemsToIncreaseInTransitOutbound
		GROUP BY intItemId, intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = CASE WHEN ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutbound < 0 THEN 0 ELSE ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutbound END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblUnitOnHand
		,dblInTransitOutbound
		,dblOnOrder
		,dblLastCountRetail
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,0
		,CASE WHEN Source_Query.Aggregrate_InTransitOutbound < 0 THEN 0 ELSE Source_Query.Aggregrate_InTransitOutbound END -- dblInTransitOutbound
		,0
		,0
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the Order Committed
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		SELECT	intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,Aggregrate_InTransitOutbound = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseInTransitOutbound
		GROUP BY intItemId, intItemLocationId, intItemUOMId, intSubLocationId, intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = CASE WHEN ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutbound < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutbound END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblOnHand
		,dblOnOrder
		,dblInTransitOutbound
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId
		,0
		,0
		,CASE WHEN Source_Query.Aggregrate_InTransitOutbound < 0 THEN 0 ELSE Source_Query.Aggregrate_InTransitOutbound END
		,1	
	)
;
