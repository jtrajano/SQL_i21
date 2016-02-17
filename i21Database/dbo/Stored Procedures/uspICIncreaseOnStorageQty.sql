﻿CREATE PROCEDURE [dbo].[uspICIncreaseOnStorageQty]
	@ItemsToIncreaseOnStorage AS ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Do an upsert for the Item Stock table when updating the Reserved Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,Aggregrate_StorageQty = SUM(ISNULL(dblQty, 0) * ISNULL(tblICItemUOM.dblUnitQty, 0))					
		FROM	@ItemsToIncreaseOnStorage ItemsToIncreaseInTransitOutBound LEFT JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitStorage = ISNULL(ItemStock.dblUnitStorage, 0) + Source_Query.Aggregrate_StorageQty 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblUnitStorage
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.Aggregrate_StorageQty
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the Reserved Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,ItemsToIncreaseInTransitOutBound.intItemUOMId
				,ItemsToIncreaseInTransitOutBound.intSubLocationId
				,ItemsToIncreaseInTransitOutBound.intStorageLocationId
				,Aggregrate_StorageQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseOnStorage ItemsToIncreaseInTransitOutBound LEFT JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
				, ItemsToIncreaseInTransitOutBound.intItemUOMId
				, ItemsToIncreaseInTransitOutBound.intSubLocationId
				, ItemsToIncreaseInTransitOutBound.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitStorage = ISNULL(ItemStockUOM.dblUnitStorage, 0) + Source_Query.Aggregrate_StorageQty 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblUnitStorage
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId
		,Source_Query.Aggregrate_StorageQty --CASE WHEN Source_Query.Aggregrate_StorageQty < 0 THEN 0 ELSE Source_Query.Aggregrate_StorageQty END
		,1	
	)
;
