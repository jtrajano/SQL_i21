CREATE PROCEDURE [dbo].[uspICIncreaseConsignedPurchaseQty]
	@ItemsToIncreaseConsignedPurchase AS ItemCostingTableType READONLY
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
	FROM	@ItemsToIncreaseConsignedPurchase ItemsToValidate LEFT JOIN dbo.tblICItem Item
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

-- Do an upsert for the Item Stock table when updating the Consigned Purchase Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	cp.intItemId
				,cp.intItemLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(cp.intItemUOMId, StockUOM.intItemUOMId, cp.dblQty))  
		FROM	@ItemsToIncreaseConsignedPurchase cp 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = cp.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
		GROUP BY cp.intItemId
				, cp.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the Consigned Purchase qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblConsignedPurchase = CASE WHEN ISNULL(ItemStock.dblConsignedPurchase, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblConsignedPurchase, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblConsignedPurchase
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.Aggregrate_Qty 
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the Consigned Purchase Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		
		SELECT	ItemsToIncreaseConsignedPurchase.intItemId
				,ItemsToIncreaseConsignedPurchase.intItemLocationId
				,ItemsToIncreaseConsignedPurchase.intItemUOMId
				,ItemsToIncreaseConsignedPurchase.intSubLocationId
				,ItemsToIncreaseConsignedPurchase.intStorageLocationId
				,Aggregrate_Qty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseConsignedPurchase ItemsToIncreaseConsignedPurchase 
		GROUP BY ItemsToIncreaseConsignedPurchase.intItemId
				, ItemsToIncreaseConsignedPurchase.intItemLocationId
				, ItemsToIncreaseConsignedPurchase.intItemUOMId
				, ItemsToIncreaseConsignedPurchase.intSubLocationId
				, ItemsToIncreaseConsignedPurchase.intStorageLocationId
		-- Convert the Consigned Purchase Qty to the Stock UOM before adding it into tblICItemStockUOM
		UNION ALL 
		SELECT	cp.intItemId
				,cp.intItemLocationId
				,StockUOM.intItemUOMId
				,cp.intSubLocationId
				,cp.intStorageLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(cp.intItemUOMId, StockUOM.intItemUOMId, cp.dblQty))  
		FROM	@ItemsToIncreaseConsignedPurchase cp 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = cp.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
		WHERE	cp.intItemUOMId <> StockUOM.intItemUOMId
		GROUP BY cp.intItemId
				, cp.intItemLocationId
				, StockUOM.intItemUOMId
				, cp.intSubLocationId
				, cp.intStorageLocationId

) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the Consigned Purchase qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblConsignedPurchase = CASE WHEN ISNULL(ItemStockUOM.dblConsignedPurchase, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblConsignedPurchase, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblConsignedPurchase
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId
		,Source_Query.Aggregrate_Qty 
		,1	
	)
;

_Exit: