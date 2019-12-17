CREATE PROCEDURE [dbo].[uspICIncreaseReservedQty]
	@ItemsToIncreaseReserve AS ItemReservationTableType READONLY
	,@intUserId AS INT = NULL
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

-- Do an upsert for the Item Stock UOM table when updating the Reserved Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		-- NON-LOTTED
		-- Convert the Reserved Qty to 'Stock UOM' before adding it into tblICItemStockUOM		 
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
		WHERE	r.intLotId IS NULL 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, StockUOM.intItemUOMId 
				, r.intSubLocationId
				, r.intStorageLocationId
		-- If the UOM is not a stock unit, reserve it as it is. 
		UNION ALL 
		SELECT	r.intItemId
				,r.intItemLocationId
				,r.intItemUOMId 
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = SUM(r.dblQty) 
		FROM	@ItemsToIncreaseReserve r
				INNER JOIN tblICItem i
					ON r.intItemId = i.intItemId 
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	r.intLotId IS NULL 
				AND r.intItemUOMId <> StockUOM.intItemUOMId 
				AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 -- If separate UOMs is not enabled, then don't track the non-stock unit UOM. 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, r.intItemUOMId 
				, r.intSubLocationId
				, r.intStorageLocationId
		-- LOTTED
		-- Convert the lot qty or weight to stock uom. 
		UNION ALL 
		SELECT	r.intItemId
				,r.intItemLocationId
				,StockUOM.intItemUOMId 
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = 
					SUM(
						dbo.fnCalculateQtyBetweenUOM (
							CASE 
								WHEN r.intItemUOMId = l.intItemUOMId AND l.intWeightUOMId = l.intItemUOMId THEN 
									l.intItemUOMId 
								WHEN r.intItemUOMId = l.intItemUOMId AND l.intWeightUOMId IS NOT NULL THEN 
									l.intWeightUOMId
								WHEN r.intItemUOMId = l.intItemUOMId AND l.intWeightUOMId IS NULL THEN 
									l.intItemUOMId 
								WHEN r.intItemUOMId = l.intWeightUOMId THEN 
									l.intWeightUOMId
							END
							,StockUOM.intItemUOMId
							,CASE 
								WHEN r.intItemUOMId = l.intItemUOMId AND l.intWeightUOMId = l.intItemUOMId THEN 
									r.dblQty
								WHEN r.intItemUOMId = l.intItemUOMId AND l.intWeightUOMId IS NOT NULL THEN 
									dbo.fnMultiply(r.dblQty,l.dblWeightPerQty) -- convert the pack to weight 
								WHEN r.intItemUOMId = l.intItemUOMId AND l.intWeightUOMId IS NULL THEN 
									r.dblQty 
								WHEN r.intItemUOMId = l.intWeightUOMId THEN 
									r.dblQty 
							END 						
						)
					) 
		FROM	@ItemsToIncreaseReserve r INNER JOIN tblICLot l
					ON r.intLotId = l.intLotId 
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	r.intLotId IS NOT NULL 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, StockUOM.intItemUOMId 
				, r.intSubLocationId
				, r.intStorageLocationId
		-- Reserve the Lot Qty 
		UNION ALL 
		SELECT	r.intItemId
				,r.intItemLocationId
				,l.intItemUOMId 
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = 
					SUM(
						CASE 
							WHEN r.intItemUOMId = l.intItemUOMId THEN 
								r.dblQty 
							WHEN r.intItemUOMId = l.intWeightUOMId AND l.intItemUOMId <> l.intWeightUOMId THEN 
								dbo.fnDivide(r.dblQty, l.dblWeightPerQty) -- Convert the wgt to pack qty. 
						END 						
					) 
		FROM	@ItemsToIncreaseReserve r INNER JOIN tblICLot l
					ON r.intLotId = l.intLotId 
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	r.intLotId IS NOT NULL 
				AND l.intItemUOMId <> StockUOM.intItemUOMId 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, l.intItemUOMId
				, r.intSubLocationId
				, r.intStorageLocationId
		-- Reserve the Wgt Qty 
		UNION ALL 
		SELECT	r.intItemId
				,r.intItemLocationId
				,l.intWeightUOMId 
				,r.intSubLocationId
				,r.intStorageLocationId
				,Aggregrate_Qty = 
					SUM(
						CASE 
							WHEN r.intItemUOMId = l.intItemUOMId THEN 
								dbo.fnMultiply(r.dblQty, l.dblWeightPerQty) -- Convert the pack to wgt qty. 
							WHEN r.intItemUOMId = l.intWeightUOMId THEN 
								r.dblQty 
						END 						
					) 
		FROM	@ItemsToIncreaseReserve r INNER JOIN tblICLot l
					ON r.intLotId = l.intLotId 
				CROSS APPLY (
					SELECT	TOP 1 
							iUOM.intItemUOMId
							,iUOM.dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = r.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM
		WHERE	r.intLotId IS NOT NULL 
				AND l.intWeightUOMId IS NOT NULL 
				AND l.intWeightUOMId <> StockUOM.intItemUOMId 
				AND l.intWeightUOMId <> l.intItemUOMId 
		GROUP BY r.intItemId
				, r.intItemLocationId
				, l.intWeightUOMId
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
			,dtmDate
			,dtmDateCreated
			,intCreatedByUserId
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
			,dtmDate
			,dtmDateCreated		= GETDATE()
			,intCreatedByUserId	= @intUserId
	FROM	@ItemsToIncreaseReserve cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

_Exit: