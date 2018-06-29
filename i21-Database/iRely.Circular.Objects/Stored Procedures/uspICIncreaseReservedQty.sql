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
		RETURN 80002
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
		-- Aggregrate the non-stock-unit UOMs. 
		SELECT	r.intItemId
				,r.intItemLocationId
				,r.intItemUOMId
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseReserveUsingStockUOM r 
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	r.intItemUOMId <> StockUOM.intItemUOMId 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, r.intItemUOMId
				, r.intSubLocationId
				, r.intStorageLocationId
		-- Convert the Reserved Qty to 'Stock UOM' before adding it into tblICItemStockUOM
		UNION ALL 
		SELECT	r.intItemId
				,r.intItemLocationId
				,StockUOM.intItemUOMId 
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(r.intItemUOMId, StockUOM.intItemUOMId, r.dblQty)) 
		FROM	@ItemsToIncreaseReserve r
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		GROUP BY r.intItemId
				, r.intItemLocationId
				, StockUOM.intItemUOMId 
				, r.intSubLocationId
				, r.intStorageLocationId
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

-- Create the Item Stock Detail 
BEGIN 
	DECLARE		
		@stockType_OnOrder AS INT = 1
		,@stockType_OnStorage AS INT = 2
		,@stockType_OrderCommitted AS INT = 3
		,@stockType_InTransitInbound AS INT = 4
		,@stockType_InTransitOutbound AS INT = 5
		,@stockType_InTransitDirect AS INT = 6
		,@stockType_ConsignedPurchase AS INT = 7
		,@stockType_ConsignedSale AS INT = 8
		,@stockType_Reserved AS INT = 9

	INSERT INTO tblICItemStockDetail (
			intItemStockTypeId 
			,intItemId   
			,intItemLocationId 
			,intItemUOMId 
			,intSubLocationId 
			,intStorageLocationId 
			,strTransactionId
			,dblQty
			,intConcurrencyId
	)
	SELECT 
			intItemStockTypeId	= @stockType_Reserved
			,intItemId			= intItemId
			,intItemLocationId  = intItemLocationId
			,intItemUOMId		= intItemUOMId
			,intSubLocationId	= intSubLocationId
			,intStorageLocationId = intStorageLocationId 
			,strTransactionId	= strTransactionId
			,dblQty				= dblQty
			,intConcurrencyId	= 1
	FROM	@ItemsToIncreaseReserve cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

_Exit: