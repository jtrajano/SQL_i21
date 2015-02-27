CREATE PROCEDURE [dbo].[uspICIncreaseOnOrderQty]
	@ItemsToIncreaseOnOrder AS ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Do an upsert for the Item Stock table when updating the On Order Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	intItemId
				,intItemLocationId
				,Aggregrate_OnOrderQty = SUM(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0))					
		FROM	@ItemsToIncreaseOnOrder
		GROUP BY intItemId, intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblUnitOnHand
		,dblOrderCommitted
		,dblOnOrder
		,dblLastCountRetail
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,0
		,0
		,Source_Query.Aggregrate_OnOrderQty -- dblOnOrder
		,0
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the On Order Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,Aggregrate_OnOrderQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseOnOrder
		GROUP BY intItemId, intItemLocationId, intItemUOMId, intSubLocationId, intStorageLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStock.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStock.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStock.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty

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
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId
		,0
		,Source_Query.Aggregrate_OnOrderQty 
		,1	
	)
;
