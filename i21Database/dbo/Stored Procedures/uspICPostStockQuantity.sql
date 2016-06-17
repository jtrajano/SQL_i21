/*
	This stored procedure handles the updating of the Stock Quantity in tblICItemStock and tblICItemStockUOM. 
*/
CREATE PROCEDURE [dbo].[uspICPostStockQuantity]
	@intItemId AS INT,
	@intItemLocationId AS INT,
	@intSubLocationId AS INT,
	@intStorageLocationId AS INT,
	@intItemUOMId AS INT,
	@dblQty AS NUMERIC(38,20),
	@dblUOMQty AS NUMERIC(38,20),
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
	DECLARE @dblWeightPerQty AS NUMERIC(38,20)
			,@intLotWeightUOMId AS INT
			,@intLotItemUOMId AS INT 
			,@dblWeightUnitQty AS NUMERIC(38,20) 

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
										dbo.fnCalculateStockUnitQty(dbo.fnMultiply(@dblQty, @dblWeightPerQty), @dblWeightUnitQty) 
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

BEGIN 
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
				SELECT	intItemId 
						,intItemUOMId 
						,intItemLocationId 
						,intSubLocationId 
						,intStorageLocationId 
						,Qty = SUM(Qty) 
				FROM (
					-------------------------------------------
					-- Item is NOT a Lot. 
					-------------------------------------------
					-- Get the Qty as it is. 
					SELECT	intItemId = @intItemId
							,intItemUOMId = @intItemUOMId
							,intItemLocationId = @intItemLocationId					
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty = ISNULL(@dblQty, 0) 
					WHERE	@intLotId IS NULL 

					-- Convert the Qty to stock Unit. 
					UNION ALL 
					SELECT	intItemId = @intItemId
							,intItemUOMId = StockUOM.intItemUOMId
							,intItemLocationId = @intItemLocationId					
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty = dbo.fnCalculateStockUnitQty(@dblQty, ItemUOM.dblUnitQty) -- Convert the qty to stock unit. 
					FROM	(
								SELECT	intItemId
										,intItemUOMId 
										,dblUnitQty									
								FROM	dbo.tblICItemUOM 
								WHERE	intItemId = @intItemId
										AND intItemUOMId = @intItemUOMId
							) ItemUOM 
							,(
								SELECT	intItemId
										,intItemUOMId 
										,dblUnitQty
								FROM	dbo.tblICItemUOM 
								WHERE	intItemId = @intItemId
										AND ysnStockUnit = 1
							) StockUOM 						
					WHERE	@intLotId IS NULL 
							AND @intItemUOMId <> StockUOM.intItemUOMId
				
					-------------------------------------------
					-- Item is a Lot and with Weight. 
					-------------------------------------------

					-- Get the Pack Qty (Lot.intItemUOMId) 
					UNION ALL 
					SELECT	intItemId = @intItemId					
							,intItemUOMId =	Lot.intItemUOMId 
							,intItemLocationId = @intItemLocationId
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	@dblQty
					FROM	dbo.tblICLot Lot 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemUOMId = @intItemUOMId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0			
					
					-- Get the Weight Qty (Lot.intWeightUOMId) 
					UNION ALL 
					SELECT	intItemId = @intItemId					
							,intItemUOMId =	Lot.intWeightUOMId
							,intItemLocationId = @intItemLocationId
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	@dblQty
					FROM	dbo.tblICLot Lot 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0		
							AND Lot.intItemUOMId <> Lot.intWeightUOMId 

					-- Convert the pack uom to weight uom 
					UNION ALL 
					SELECT	intItemId = @intItemId					
							,intItemUOMId =	Lot.intWeightUOMId 
							,intItemLocationId = @intItemLocationId
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	dbo.fnMultiply(@dblQty, Lot.dblWeightPerQty) 
					FROM	dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
								ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
							LEFT JOIN dbo.tblICItemUOM LotStockUOM 
								ON LotStockUOM.intItemId = Lot.intItemId
								AND LotStockUOM.ysnStockUnit = 1
								AND LotStockUOM.intItemUOMId <> Lot.intItemUOMId 
								AND LotStockUOM.intWeightUOMId <> Lot.intWeightUOMId 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemUOMId = @intItemUOMId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0	
							AND Lot.intItemUOMId <> Lot.intWeightUOMId 

					-- Convert the weight uom to pack uom 
					UNION ALL 
					SELECT	intItemId = @intItemId					
							,intItemUOMId =	Lot.intItemUOMId 
							,intItemLocationId = @intItemLocationId
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	dbo.fnDivide(@dblQty, Lot.dblWeightPerQty) 
					FROM	dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
								ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
							LEFT JOIN dbo.tblICItemUOM LotStockUOM 
								ON LotStockUOM.intItemId = Lot.intItemId
								AND LotStockUOM.ysnStockUnit = 1
								AND LotStockUOM.intItemUOMId <> Lot.intItemUOMId 
								AND LotStockUOM.intWeightUOMId <> Lot.intWeightUOMId 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intWeightUOMId = @intItemUOMId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0	
							AND Lot.intItemUOMId <> Lot.intWeightUOMId 

					-- Convert weight to stock unit. 
					UNION ALL 
					SELECT	intItemId = @intItemId					
							,intItemUOMId =	LotStockUOM.intItemUOMId -- Stock UOM Id
							,intItemLocationId = @intItemLocationId
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	dbo.fnCalculateStockUnitQty(
										CASE	WHEN (@intItemUOMId = Lot.intItemUOMId) THEN dbo.fnMultiply(@dblQty, Lot.dblWeightPerQty) -- Stock is in packs, then convert the qty to weight. 
												ELSE @dblQty -- else it is in weights. Keep using the weight qty. 
										END 
										,LotWeightUOM.dblUnitQty								
									) 

					FROM	dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
								ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
							LEFT JOIN dbo.tblICItemUOM LotStockUOM 
								ON LotStockUOM.intItemId = Lot.intItemId
								AND LotStockUOM.ysnStockUnit = 1
								AND LotStockUOM.intItemUOMId <> Lot.intItemUOMId 
								AND LotStockUOM.intWeightUOMId <> Lot.intWeightUOMId 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0						

					---------------------------------------------
					-- Item is a Lot and does NOT have a Weight. 
					---------------------------------------------
					-- Get the Pack Qty (intItemUOMId) 
					UNION ALL 
					SELECT	intItemId = @intItemId
							,intItemUOMId = @intItemUOMId
							,intItemLocationId = @intItemLocationId					
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty = ISNULL(@dblQty, 0) 
					FROM	dbo.tblICLot Lot 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemLocationId = @intItemLocationId
							AND Lot.intWeightUOMId IS NULL 
					
					--------------------------------------------------------------------------------------
					-- If incoming Lot has a no weight, then convert the lot item UOM to stock unit Qty
					--------------------------------------------------------------------------------------
					UNION ALL 
					SELECT	intItemId = @intItemId
							,intItemUOMId =	LotStockUOM.intItemUOMId
							,intItemLocationId = @intItemLocationId					
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	dbo.fnCalculateStockUnitQty(@dblQty, LotItemUOM.dblUnitQty) 
					FROM	dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotItemUOM
								ON Lot.intItemUOMId = LotItemUOM.intItemUOMId
							LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
								ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
							LEFT JOIN dbo.tblICItemUOM LotStockUOM 
								ON LotStockUOM.intItemId = Lot.intItemId
								AND LotStockUOM.ysnStockUnit = 1
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemLocationId = @intItemLocationId
							AND Lot.intWeightUOMId IS NULL 
							AND Lot.intItemUOMId <> LotStockUOM.intItemUOMId				
				) Query
				GROUP BY intItemId 
						,intItemUOMId 
						,intItemLocationId 
						,intSubLocationId 
						,intStorageLocationId 

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
