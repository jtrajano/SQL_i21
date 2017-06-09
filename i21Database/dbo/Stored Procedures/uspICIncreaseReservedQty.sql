CREATE PROCEDURE [dbo].[uspICIncreaseReservedQty]
	@ItemsToIncreaseReserve AS ItemReservationTableType READONLY
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
	FROM	@ItemsToIncreaseReserve ItemsToValidate LEFT JOIN dbo.tblICItem Item
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
		SELECT	r.intItemId
				,r.intItemLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(r.intItemUOMId, StockUOM.intItemUOMId, r.dblQty)) 
		FROM	@ItemsToIncreaseReserve r INNER JOIN dbo.tblICItemUOM i
					ON r.intItemUOMId = i.intItemUOMId
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		GROUP BY r.intItemId
				, r.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitReserved = CASE WHEN ISNULL(ItemStock.dblUnitReserved, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblUnitReserved, 0) + Source_Query.Aggregrate_Qty END 

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
		,Source_Query.Aggregrate_Qty 
		,NULL 
		,1	
	)		
;

DECLARE @ItemsToIncreaseReserveUsingStockUOM AS ItemReservationTableType 
INSERT INTO @ItemsToIncreaseReserveUsingStockUOM (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId	
		,dblQty
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
)

SELECT 
		r.intItemId
		,r.intItemLocationId
		,StockUOM.intItemUOMId 
		,r.intSubLocationId
		,r.intStorageLocationId
		,dblQty = SUM(dbo.fnCalculateQtyBetweenUOM(r.intItemUOMId, StockUOM.intItemUOMId, r.dblQty)) 
		,intTransactionId = 1
		,strTransactionId = ''
		,intTransactionTypeId = 1
FROM	@ItemsToIncreaseReserve r
		CROSS APPLY (
			SELECT	TOP 1 
					intItemUOMId
					,dblUnitQty 
			FROM	tblICItemUOM iUOM
			WHERE	iUOM.intItemId = r.intItemId
					AND iUOM.ysnStockUnit = 1 
		) StockUOM
GROUP BY r.intItemId
		, r.intItemLocationId
		, StockUOM.intItemUOMId 
		, r.intSubLocationId
		, r.intStorageLocationId

-- Do an upsert for the Item Stock UOM table when updating the Reserved Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		-- Update reserves with respect to Stock UOM. 
		SELECT	r.intItemId
				,r.intItemLocationId
				,r.intItemUOMId
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseReserveUsingStockUOM r 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, r.intItemUOMId
				, r.intSubLocationId
				, r.intStorageLocationId
		-- Update reserves for non Stock UOM. 
		UNION ALL 
		SELECT	toReserve.intItemId
				,toReserve.intItemLocationId
				,toReserve.intItemUOMId 
				,toReserve.intSubLocationId
				,toReserve.intStorageLocationId
				,Aggregrate_Qty = SUM(ISNULL(toReserve.dblQty, 0))
		FROM	@ItemsToIncreaseReserve toReserve
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = toReserve.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	toReserve.intItemUOMId <> StockUOM.intItemUOMId 
		GROUP BY toReserve.intItemId
				, toReserve.intItemLocationId
				, toReserve.intItemUOMId 
				, toReserve.intSubLocationId
				, toReserve.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitReserved = CASE WHEN ISNULL(ItemStockUOM.dblUnitReserved, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblUnitReserved, 0) + Source_Query.Aggregrate_Qty END 

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
		,Source_Query.Aggregrate_Qty 
		,1	
	)
;

_Exit: