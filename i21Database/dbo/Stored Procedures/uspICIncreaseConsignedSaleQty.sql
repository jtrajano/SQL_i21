CREATE PROCEDURE [dbo].[uspICIncreaseConsignedSaleQty]
	@ItemsToIncreaseConsignedSale AS ItemCostingTableType READONLY
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
	FROM	@ItemsToIncreaseConsignedSale ItemsToValidate LEFT JOIN dbo.tblICItem Item
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

-- Do an upsert for the Item Stock table when updating the Consigned Sale Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	cs.intItemId
				,cs.intItemLocationId
				,Aggregrate_Qty = SUM(ISNULL(dblQty, 0) * ISNULL(tblICItemUOM.dblUnitQty, 0))					
		FROM	@ItemsToIncreaseConsignedSale cs LEFT JOIN dbo.tblICItemUOM 
					ON cs.intItemUOMId = tblICItemUOM.intItemUOMId
		GROUP BY cs.intItemId
				, cs.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblConsignedSale = CASE WHEN ISNULL(ItemStock.dblConsignedSale, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblConsignedSale, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblConsignedSale
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

-- Do an upsert for the Item Stock UOM table when updating the Consigned Sale Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		-- If separate UOMs is not enabled, convert the qty to stock unit. 
		SELECT	cs.intItemId
				,cs.intItemLocationId
				,StockUOM.intItemUOMId
				,cs.intSubLocationId
				,cs.intStorageLocationId
				,Aggregrate_Qty = SUM(
						dbo.fnCalculateQtyBetweenUOM(
							cs.intItemUOMId
							,StockUOM.intItemUOMId
							,ISNULL(dblQty, 0)
						)						
					)
		FROM	@ItemsToIncreaseConsignedSale cs 
				INNER JOIN tblICItem i
					ON cs.intItemId = i.intItemId 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = cs.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
		WHERE	
			ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 
			AND i.strLotTracking NOT LIKE 'Yes%'
		GROUP BY cs.intItemId
				, cs.intItemLocationId
				, StockUOM.intItemUOMId
				, cs.intSubLocationId
				, cs.intStorageLocationId
		-- If separate UOMs is enabled, don't convert the qty. Track it using the same uom. 
		UNION ALL 
		SELECT	cs.intItemId
				,cs.intItemLocationId
				,cs.intItemUOMId
				,cs.intSubLocationId
				,cs.intStorageLocationId
				,Aggregrate_Qty = SUM(cs.dblQty)  
		FROM	@ItemsToIncreaseConsignedSale cs 
				INNER JOIN tblICItem i
					ON cs.intItemId = i.intItemId 
		WHERE 
			ISNULL(i.ysnSeparateStockForUOMs, 0) = 1
			OR i.strLotTracking LIKE 'Yes%'
		GROUP BY cs.intItemId
				, cs.intItemLocationId
				, cs.intItemUOMId
				, cs.intSubLocationId
				, cs.intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the Consigned Sale qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblConsignedSale = CASE WHEN ISNULL(ItemStockUOM.dblConsignedSale, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblConsignedSale, 0) + Source_Query.Aggregrate_Qty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,dblConsignedSale
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
			intItemStockTypeId	= @stockType_ConsignedSale
			,intItemId			= intItemId
			,intItemLocationId  = intItemLocationId
			,intItemUOMId		= intItemUOMId
			,intSubLocationId	= intSubLocationId
			,intStorageLocationId = intStorageLocationId 
			,strTransactionId	= strTransactionId
			,dblQty				= dblQty
			,intConcurrencyId	= 1
	FROM	@ItemsToIncreaseConsignedSale cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

_Exit: