CREATE PROCEDURE [dbo].[uspICIncreaseOnStorageQty]
	@ItemsToIncreaseOnStorage AS ItemCostingTableType READONLY
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
	FROM	@ItemsToIncreaseOnStorage ItemsToValidate LEFT JOIN dbo.tblICItem Item
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

-- Do an upsert for the Item Stock table when updating the Reserved Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	s.intItemId
				,s.intItemLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(s.intItemUOMId, StockUOM.intItemUOMId, s.dblQty)) 
		FROM	@ItemsToIncreaseOnStorage s 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = s.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		GROUP BY s.intItemId
				, s.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitStorage = ISNULL(ItemStock.dblUnitStorage, 0) + Source_Query.Aggregrate_Qty 

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
		,Source_Query.Aggregrate_Qty
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
		SELECT	s.intItemId
				,s.intItemLocationId
				,s.intItemUOMId
				,s.intSubLocationId
				,s.intStorageLocationId
				,Aggregrate_Qty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseOnStorage s LEFT JOIN dbo.tblICItemUOM 
					ON s.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY s.intItemId
				, s.intItemLocationId
				, s.intItemUOMId
				, s.intSubLocationId
				, s.intStorageLocationId
		-- Convert the On Order Qty to the Stock UOM before adding it into tblICItemStockUOM
		UNION ALL 
		SELECT	s.intItemId
				,s.intItemLocationId
				,StockUOM.intItemUOMId 
				,s.intSubLocationId
				,s.intStorageLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(s.intItemUOMId, StockUOM.intItemUOMId, s.dblQty))  
		FROM	@ItemsToIncreaseOnStorage s
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = s.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	s.intItemUOMId <> StockUOM.intItemUOMId 
		GROUP BY 
			s.intItemId
			, s.intItemLocationId
			, StockUOM.intItemUOMId 
			, s.intSubLocationId
			, s.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitStorage = ISNULL(ItemStockUOM.dblUnitStorage, 0) + Source_Query.Aggregrate_Qty 

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
		,Source_Query.Aggregrate_Qty 
		,1	
	)
;

_Exit: 