﻿CREATE PROCEDURE [dbo].[uspICIncreaseOnOrderQty]
	@ItemsToIncreaseOnOrder AS ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Validate the item-location. 
BEGIN 
	DECLARE @intItemId AS INT 
			,@strItemNo AS NVARCHAR(50)

	SELECT	@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToIncreaseOnOrder ItemsToValidate LEFT JOIN dbo.tblICItem Item
				ON ItemsToValidate.intItemId = Item.intItemId
	WHERE	NOT EXISTS (
				SELECT TOP 1 1 
				FROM	dbo.tblICItemLocation
				WHERE	tblICItemLocation.intItemLocationId = ItemsToValidate.intItemLocationId
						AND tblICItemLocation.intItemId = ItemsToValidate.intItemId
			)
			AND ItemsToValidate.intItemId IS NOT NULL 	
			
	-- 'Item-Location is invalid or missing for {Item}.'
	IF @intItemId IS NOT NULL 
	BEGIN 
		EXEC uspICRaiseError 80002, @strItemNo;
		GOTO _Exit
	END 
END 

-- Do an upsert for the Item Stock table when updating the On Order Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	o.intItemId
				,o.intItemLocationId
				,Aggregrate_OnOrderQty = SUM(dbo.fnCalculateQtyBetweenUOM(o.intItemUOMId, StockUOM.intItemUOMId, o.dblQty)) 
		FROM	@ItemsToIncreaseOnOrder o  
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = o.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		GROUP BY 
			o.intItemId
			, o.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOnOrder = CASE WHEN ISNULL(ItemStock.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty < 0 THEN 0 ELSE ISNULL(ItemStock.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty END 

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
		,CASE WHEN Source_Query.Aggregrate_OnOrderQty < 0 THEN 0 ELSE Source_Query.Aggregrate_OnOrderQty END -- dblOnOrder
		,0
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the On Order Qty
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
				,Aggregrate_OnOrderQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseOnOrder
		GROUP BY intItemId, intItemLocationId, intItemUOMId, intSubLocationId, intStorageLocationId
		-- Convert the On Order Qty to the Stock UOM before adding it into tblICItemStockUOM
		UNION ALL 
		SELECT	o.intItemId
				,o.intItemLocationId
				,StockUOM.intItemUOMId 
				,o.intSubLocationId
				,o.intStorageLocationId
				,Aggregrate_OnOrderQty = SUM(dbo.fnCalculateQtyBetweenUOM(o.intItemUOMId, StockUOM.intItemUOMId, o.dblQty))  
		FROM	@ItemsToIncreaseOnOrder o
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = o.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	o.intItemUOMId <> StockUOM.intItemUOMId 
		GROUP BY 
			o.intItemId
			, o.intItemLocationId
			, StockUOM.intItemUOMId 
			, o.intSubLocationId
			, o.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOnOrder = CASE WHEN ISNULL(ItemStockUOM.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty END 

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
		,CASE WHEN Source_Query.Aggregrate_OnOrderQty < 0 THEN 0 ELSE Source_Query.Aggregrate_OnOrderQty END
		,1	
	)
;

_Exit: