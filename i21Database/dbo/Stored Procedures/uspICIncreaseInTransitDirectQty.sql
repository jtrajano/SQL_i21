CREATE PROCEDURE [dbo].[uspICIncreaseInTransitDirectQty]
	@ItemsToIncreaseInTransitDirect AS InTransitTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Validate the item-location. 
BEGIN 
	DECLARE @intItemId AS INT 
			,@strItemNo AS NVARCHAR(50)

	SELECT	@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToIncreaseInTransitDirect ItemsToValidate LEFT JOIN dbo.tblICItem Item
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
		FROM	@ItemsToIncreaseInTransitDirect ib 
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
	SET		dblInTransitDirect = CASE WHEN ISNULL(ItemStock.dblInTransitDirect, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblInTransitDirect, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblInTransitDirect
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
		-- If separate UOMs is not enabled, convert the qty to stock unit. 
		SELECT	ib.intItemId
				,ib.intItemLocationId
				,StockUOM.intItemUOMId
				,ib.intSubLocationId
				,ib.intStorageLocationId
				,Aggregrate_Qty = SUM(
					dbo.fnCalculateQtyBetweenUOM(
						ib.intItemUOMId
						, StockUOM.intItemUOMId
						, ib.dblQty
					)
				)  
		FROM	@ItemsToIncreaseInTransitDirect ib 
				INNER JOIN tblICItem i
					ON ib.intItemId = i.intItemId 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = ib.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
		WHERE	
			ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 
			AND i.strLotTracking NOT LIKE 'Yes%'
		GROUP BY ib.intItemId
				, ib.intItemLocationId
				, StockUOM.intItemUOMId
				, ib.intSubLocationId
				, ib.intStorageLocationId
		-- If separate UOMs is enabled, don't convert the qty. Track it using the same uom. 
		UNION ALL 
		SELECT	ib.intItemId
				,ib.intItemLocationId
				,ib.intItemUOMId
				,ib.intSubLocationId
				,ib.intStorageLocationId
				,Aggregrate_Qty = SUM(ib.dblQty)  
		FROM	@ItemsToIncreaseInTransitDirect ib 
				INNER JOIN tblICItem i
					ON ib.intItemId = i.intItemId 
		WHERE	
			ISNULL(i.ysnSeparateStockForUOMs, 0) = 1 
			OR i.strLotTracking LIKE 'Yes%'
		GROUP BY ib.intItemId
				, ib.intItemLocationId
				, ib.intItemUOMId
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
	SET		dblInTransitDirect = CASE WHEN ISNULL(ItemStockUOM.dblInTransitDirect, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblInTransitDirect, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblInTransitDirect
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
			intItemStockTypeId	= @stockType_InTransitDirect
			,intItemId			= intItemId
			,intItemLocationId  = intItemLocationId
			,intItemUOMId		= intItemUOMId
			,intSubLocationId	= intSubLocationId
			,intStorageLocationId = intStorageLocationId 
			,strTransactionId	= strTransactionId
			,dblQty				= dblQty
			,intConcurrencyId	= 1
	FROM	@ItemsToIncreaseInTransitDirect cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

_Exit: