/*
	This stored procedure handles the updating of the Stock Quantity in tblICItemStock and tblICItemStockUOM. 
*/
CREATE PROCEDURE [dbo].[uspICPostStockQuantity]
	@intItemId AS INT,
	@intItemLocationId AS INT,
	@intSubLocationId AS INT,
	@intStorageLocationId AS INT,
	@intItemUOMId AS INT,
	@dblQty AS NUMERIC(18, 6),
	@dblUOMQty AS NUMERIC(18, 6),
	@intLotId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Initialize the parameters
SET @dblQty = ISNULL(@dblQty, 0)
SET @dblUOMQty = ISNULL(@dblUOMQty, 0)

------------------------------------------------------------
-- If item is a Lot, retrieve Weight UOM and Weight Per Qty
------------------------------------------------------------
BEGIN 
	DECLARE @dblWeightPerQty AS NUMERIC(38, 20)
			,@intLotWeightUOMId AS INT
			,@intLotItemUOMId AS INT 
			,@dblWeightUnitQty AS NUMERIC(18, 6) 

	SELECT	@intLotItemUOMId = intItemUOMId
			,@intLotWeightUOMId = intWeightUOMId
			,@dblWeightPerQty = dblWeightPerQty
	FROM	dbo.tblICLot 
	WHERE	intLotId = @intLotId

	SELECT  @dblWeightUnitQty = dblUnitQty
	FROM	dbo.tblICItemUOM 
	WHERE	intItemUOMId = @intLotWeightUOMId

	SET @dblWeightPerQty = ISNULL(@dblWeightPerQty, 0)
END 

-----------------------------------
-- Update the Item Stock table
-----------------------------------
BEGIN 
	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,Qty =	CASE	WHEN @intLotWeightUOMId IS NOT NULL AND @intItemUOMId <> @intLotWeightUOMId THEN 
										dbo.fnCalculateStockUnitQty(@dblQty * @dblWeightPerQty, @dblWeightUnitQty) 
									ELSE 
										dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
							END 
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0) + StockToUpdate.Qty

	-- If none found, insert a new item stock record
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
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,StockToUpdate.Qty -- dblUnitOnHand
			,0
			,0
			,0
			,NULL 
			,1	
		)
	;
END

----------------------------------------------------------------------------------
-- 1. Update tblICItemStockUOM for non-lot items
----------------------------------------------------------------------------------
BEGIN 
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = @intItemUOMId
					,intSubLocationId = @intSubLocationId 
					,intStorageLocationId = @intStorageLocationId
					,Qty = @dblQty
			WHERE @intLotId IS NULL 

			UNION ALL 
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 
					,intSubLocationId = @intSubLocationId 
					,intStorageLocationId = @intStorageLocationId				
					,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty)
			WHERE	@intLotId IS NULL 
					AND dbo.fnGetItemStockUOM(@intItemId) IS NOT NULL 
					AND dbo.fnGetItemStockUOM(@intItemId) <> @intItemUOMId 
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + RawStockData.Qty

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND RawStockData.intItemUOMId IS NOT NULL THEN 
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
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.Qty 
			,0
			,1	
		)
	;
END 

---------------------------------------------------------------------------------------
-- 2. Update tblICItemStockUOM. Item is a Lot and @intItemUOMId is not a weight UOM
---------------------------------------------------------------------------------------
BEGIN 
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
			-- Record the Stock Qty in terms of Item UOM
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = @intItemUOMId
					,intSubLocationId = @intSubLocationId 
					,intStorageLocationId = @intStorageLocationId
					,Qty = @dblQty
			WHERE	@intLotId IS NOT NULL 
					AND @intLotItemUOMId = @intItemUOMId 

			-- and if it has weight, convert the qty to weight and then to stock unit. This records the converted qty to the stock unit level. 
			UNION ALL 
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 
					,intSubLocationId = @intSubLocationId 
					,intStorageLocationId = @intStorageLocationId
					,Qty = dbo.fnCalculateStockUnitQty(@dblQty * @dblWeightPerQty, @dblWeightUnitQty) 
			WHERE	@intLotId IS NOT NULL 
					AND @intLotWeightUOMId IS NOT NULL 
					AND @intLotItemUOMId = @intItemUOMId
					AND dbo.fnGetItemStockUOM(@intItemId) IS NOT NULL 

	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + RawStockData.Qty

	-- If none found, insert a new item stock record
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
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.Qty 
			,0
			,1	
		)
	;
END 

---------------------------------------------------------------------------------------
-- 3. Update tblICItemStockUOM. Item is a lot and @intItemUOMId is a weight UOM
---------------------------------------------------------------------------------------
BEGIN 
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
			-- If @intItemUOMId is already the weight UOM, convert it to stock unit level. 
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 
					,intSubLocationId = @intSubLocationId 
					,intStorageLocationId = @intStorageLocationId
					,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty)
			WHERE	@intLotId IS NOT NULL 
					AND @intLotWeightUOMId = @intItemUOMId 			
					AND dbo.fnGetItemStockUOM(@intItemId)  IS NOT NULL 
		
			-- and then, convert the weight back to Lot Item UOM Id and Qty. So if weight is in bags, it will reduce the on-hand qty of the bags. 
			UNION ALL 
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,intItemUOMId = @intLotItemUOMId
					,intSubLocationId = @intSubLocationId 
					,intStorageLocationId = @intStorageLocationId
					,Qty = @dblQty / @dblWeightPerQty 
			WHERE	@intLotId IS NOT NULL 
					AND @intLotWeightUOMId = @intItemUOMId
					AND @intLotItemUOMId IS NOT NULL 
					AND @dblWeightPerQty <> 0 

	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + RawStockData.Qty

	-- If none found, insert a new item stock record
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
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.Qty 
			,0
			,1	
		)
	;
END