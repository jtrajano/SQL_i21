CREATE PROCEDURE [dbo].[uspICIncreaseInTransitInBoundQty]
	@ItemsToIncreaseInTransitInBound AS InTransitTableType READONLY
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
	FROM	@ItemsToIncreaseInTransitInBound ItemsToValidate LEFT JOIN dbo.tblICItem Item
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

-- Do an upsert for the Item Stock table when updating the In-Transit Inbound Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ib.intItemId
				,ib.intItemLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(ib.intItemUOMId, StockUOM.intItemUOMId, ib.dblQty))  
		FROM	@ItemsToIncreaseInTransitInBound ib 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = ib.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
		GROUP BY ib.intItemId
				, ib.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the In-Transit Inbound qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitInbound = CASE WHEN ISNULL(ItemStock.dblInTransitInbound, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblInTransitInbound, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblInTransitInbound
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

-- Do an upsert for the Item Stock UOM table when updating the InTransit-Inbound Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		SELECT	ib.intItemId
				,ib.intItemLocationId
				,ib.intItemUOMId
				,ib.intSubLocationId
				,ib.intStorageLocationId
				,Aggregrate_Qty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseInTransitInBound ib 
		GROUP BY ib.intItemId
				, ib.intItemLocationId
				, ib.intItemUOMId
				, ib.intSubLocationId
				, ib.intStorageLocationId
		-- Convert the InTransit-Inbound Qty to the Stock UOM before adding it into tblICItemStockUOM
		UNION ALL 
		SELECT	ib.intItemId
				,ib.intItemLocationId
				,StockUOM.intItemUOMId
				,ib.intSubLocationId
				,ib.intStorageLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(ib.intItemUOMId, StockUOM.intItemUOMId, ib.dblQty))  
		FROM	@ItemsToIncreaseInTransitInBound ib 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = ib.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
		WHERE	ib.intItemUOMId <> StockUOM.intItemUOMId
		GROUP BY ib.intItemId
				, ib.intItemLocationId
				, StockUOM.intItemUOMId
				, ib.intSubLocationId
				, ib.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitInbound = CASE WHEN ISNULL(ItemStockUOM.dblInTransitInbound, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblInTransitInbound, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblInTransitInbound
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