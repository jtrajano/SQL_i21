﻿CREATE PROCEDURE [dbo].[uspICIncreaseReservedQty]
	@ItemsToIncreaseReserve AS ItemReservationTableType READONLY
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
		SELECT	ItemsToIncreaseReserve.intItemId
				,ItemsToIncreaseReserve.intItemLocationId
				,Aggregrate_ReserveQty = SUM(ISNULL(dblQty, 0) * ISNULL(tblICItemUOM.dblUnitQty, 0))					
		FROM	@ItemsToIncreaseReserve ItemsToIncreaseReserve LEFT JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseReserve.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY ItemsToIncreaseReserve.intItemId
				, ItemsToIncreaseReserve.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitReserved = CASE WHEN ISNULL(ItemStock.dblUnitReserved, 0) + Source_Query.Aggregrate_ReserveQty < 0 THEN 0 ELSE ISNULL(ItemStock.dblUnitReserved, 0) + Source_Query.Aggregrate_ReserveQty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblUnitReserved
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,CASE WHEN Source_Query.Aggregrate_ReserveQty < 0 THEN 0 ELSE Source_Query.Aggregrate_ReserveQty END -- dblUnitReserved
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
		SELECT	ItemsToIncreaseReserve.intItemId
				,ItemsToIncreaseReserve.intItemLocationId
				,ItemsToIncreaseReserve.intItemUOMId
				,ItemsToIncreaseReserve.intSubLocationId
				,ItemsToIncreaseReserve.intStorageLocationId
				,Aggregrate_ReserveQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseReserve ItemsToIncreaseReserve LEFT JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseReserve.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY ItemsToIncreaseReserve.intItemId
				, ItemsToIncreaseReserve.intItemLocationId
				, ItemsToIncreaseReserve.intItemUOMId
				, ItemsToIncreaseReserve.intSubLocationId
				, ItemsToIncreaseReserve.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitReserved = CASE WHEN ISNULL(ItemStockUOM.dblUnitReserved, 0) + Source_Query.Aggregrate_ReserveQty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblUnitReserved, 0) + Source_Query.Aggregrate_ReserveQty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblUnitReserved
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId
		,Source_Query.Aggregrate_ReserveQty --CASE WHEN Source_Query.Aggregrate_ReserveQty < 0 THEN 0 ELSE Source_Query.Aggregrate_ReserveQty END
		,1	
	)
;
