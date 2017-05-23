CREATE PROCEDURE [dbo].[uspICIncreaseOrderCommitted]
	@ItemsToIncreaseOrderCommitted AS ItemCostingTableType READONLY
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
	FROM	@ItemsToIncreaseOrderCommitted ItemsToValidate LEFT JOIN dbo.tblICItem Item
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

-- Do an upsert for the Item Stock table when updating the Order Committed
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	c.intItemId
				,c.intItemLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(c.intItemUOMId, StockUOM.intItemUOMId, c.dblQty)) 
		FROM	@ItemsToIncreaseOrderCommitted c
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = c.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		GROUP BY 
			c.intItemId
			, c.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOrderCommitted = CASE WHEN ISNULL(ItemStock.dblOrderCommitted, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblOrderCommitted, 0) + Source_Query.Aggregrate_Qty END 

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
		,CASE WHEN Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE Source_Query.Aggregrate_Qty END -- dblOrderCommitted
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
		SELECT	c.intItemId
				,c.intItemLocationId
				,intItemUOMId
				,c.intSubLocationId
				,c.intStorageLocationId
				,Aggregrate_Qty = SUM(c.dblQty) 
		FROM	@ItemsToIncreaseOrderCommitted c
		GROUP BY 
			c.intItemId
			, c.intItemLocationId
			, c.intItemUOMId
			, c.intSubLocationId
			, c.intStorageLocationId
		-- Convert the Committed Qty to 'Stock UOM' before adding it into tblICItemStockUOM
		UNION ALL 
		SELECT	c.intItemId
				,c.intItemLocationId
				,StockUOM.intItemUOMId
				,c.intSubLocationId
				,c.intStorageLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(c.intItemUOMId, StockUOM.intItemUOMId, c.dblQty)) 
		FROM	@ItemsToIncreaseOrderCommitted c
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = c.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	c.intItemUOMId <> StockUOM.intItemUOMId 
		GROUP BY 
			c.intItemId
			, c.intItemLocationId
			, StockUOM.intItemUOMId
			, c.intSubLocationId
			, c.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOrderCommitted = CASE WHEN ISNULL(ItemStockUOM.dblOrderCommitted, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblOrderCommitted, 0) + Source_Query.Aggregrate_Qty END 

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
		,dblOrderCommitted
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
		,CASE WHEN Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE Source_Query.Aggregrate_Qty END
		,1	
	)
;

_Exit: