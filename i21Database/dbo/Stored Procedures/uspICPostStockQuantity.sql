﻿/*
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
	@intLotId AS INT,
	@intTransactionTypeId AS INT = NULL,
	@dtmTransactionDate AS DATETIME = NULL,
	@ysnPost AS BIT = 1
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
-- Get Variable Defaults
------------------------------------------------------------
BEGIN
	
	DECLARE @TransactionType_InventoryReceipt AS INT,
			@TransactionType_Invoice AS INT;
	
	SELECT	TOP 1 @TransactionType_InventoryReceipt = intTransactionTypeId
	FROM	tblICInventoryTransactionType 
	WHERE	strName = 'Inventory Receipt';

	SELECT	TOP 1 @TransactionType_Invoice = intTransactionTypeId
	FROM	tblICInventoryTransactionType 
	WHERE	strName = 'Invoice';

END
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

-----------------------------------------
-- Do not update an In-Transit Location 
-----------------------------------------
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	tblICItemLocation il
	WHERE	il.intItemLocationId = @intItemLocationId
			AND il.intLocationId IS NULL 
)
BEGIN 
	RETURN; 
END 

IF EXISTS (SELECT 1 FROM tblICItem i WHERE i.intItemId = @intItemId AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 0) 
BEGIN 	
	-- Replace the UOM to 'Stock Unit'. 
	-- Convert the Qty, Cost, and Sales Price to stock UOM. 
	SELECT 
		@dblQty = dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblQty)
		,@intItemUOMId = iu.intItemUOMId
		,@dblUOMQty = iu.dblUnitQty
	FROM 
		tblICItemUOM iu 
	WHERE 
		iu.intItemId = @intItemId 		
		AND iu.ysnStockUnit = 1
		AND iu.intItemUOMId <> @intItemUOMId -- Do not do the conversion if @intItemUOMId is already the stock uom. 
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
										ROUND(dbo.fnCalculateStockUnitQty(dbo.fnMultiply(@dblQty, @dblWeightPerQty), @dblWeightUnitQty) , 6)
									ELSE 
										ROUND(dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) , 6)
										
							END
					,dtmTransactionDate = CASE 
											WHEN @ysnPost = 1 
											THEN @dtmTransactionDate 
											ELSE [dbo].[fnICGetPreviousTransactionDate](@intItemId, @intItemLocationId, @intSubLocationId, @intStorageLocationId, @intTransactionTypeId) 
										END
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0) + StockToUpdate.Qty
				,dtmLastPurchaseDate = CASE 
											WHEN @intTransactionTypeId = @TransactionType_InventoryReceipt
												AND ((@ysnPost = 1 AND StockToUpdate.dtmTransactionDate IS NOT NULL 
													AND StockToUpdate.dtmTransactionDate > ISNULL(ItemStock.dtmLastPurchaseDate, '2000-01-01')) 
												OR @ysnPost = 0)
												THEN StockToUpdate.dtmTransactionDate
											ELSE ItemStock.dtmLastPurchaseDate
										END
				,dtmLastSaleDate = CASE 
										WHEN @intTransactionTypeId = @TransactionType_Invoice
											AND ((@ysnPost = 1 AND StockToUpdate.dtmTransactionDate IS NOT NULL 
												AND StockToUpdate.dtmTransactionDate > ISNULL(ItemStock.dtmLastSaleDate, '2000-01-01'))
											OR @ysnPost = 0)
											THEN StockToUpdate.dtmTransactionDate
										ELSE ItemStock.dtmLastSaleDate
									END
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
			,dtmLastPurchaseDate
			,dtmLastSaleDate
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
			,CASE WHEN @intTransactionTypeId = @TransactionType_InventoryReceipt THEN StockToUpdate.dtmTransactionDate ELSE NULL END
			,CASE WHEN @intTransactionTypeId = @TransactionType_Invoice THEN StockToUpdate.dtmTransactionDate ELSE NULL END
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
						,Qty = ROUND(SUM(Qty), 6)
						,dtmTransactionDate = CASE 
											WHEN @ysnPost = 1 
											THEN @dtmTransactionDate 
											ELSE [dbo].[fnICGetPreviousTransactionDate](@intItemId, @intItemLocationId, @intSubLocationId, @intStorageLocationId, @intTransactionTypeId) 
										END
				FROM (

					-------------------------------------------
					-- Item is NOT a Lot. 
					-------------------------------------------
					-- Get the Qty as it is. 
					SELECT	[subQueryId] = 1
							,intItemId = @intItemId
							,intItemUOMId = @intItemUOMId
							,intItemLocationId = @intItemLocationId					
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty = ISNULL(@dblQty, 0) 
					WHERE	@intLotId IS NULL 

					---- Convert the Qty to stock Unit. 
					--UNION ALL 
					--SELECT	[subQueryId] = 2
					--		,intItemId = @intItemId
					--		,intItemUOMId = StockUOM.intItemUOMId
					--		,intItemLocationId = @intItemLocationId					
					--		,intSubLocationId = @intSubLocationId 
					--		,intStorageLocationId = @intStorageLocationId
					--		,Qty = --dbo.fnCalculateStockUnitQty(@dblQty, ItemUOM.dblUnitQty) -- Convert the qty to stock unit. 
					--				dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, StockUOM.intItemUOMId, @dblQty)
					--FROM	(
					--			SELECT	intItemId
					--					,intItemUOMId 
					--					,dblUnitQty									
					--			FROM	dbo.tblICItemUOM 
					--			WHERE	intItemId = @intItemId
					--					AND intItemUOMId = @intItemUOMId
					--		) ItemUOM 
					--		,(
					--			SELECT	intItemId
					--					,intItemUOMId 
					--					,dblUnitQty
					--			FROM	dbo.tblICItemUOM 
					--			WHERE	intItemId = @intItemId
					--					AND ysnStockUnit = 1
					--		) StockUOM 						
					--WHERE	@intLotId IS NULL 
					--		AND @intItemUOMId <> StockUOM.intItemUOMId
				
					-------------------------------------------
					-- Item is a Lot and with Weight. 
					-------------------------------------------

					-- Get the Pack Qty (Lot.intItemUOMId) 
					UNION ALL 
					SELECT	[subQueryId] = 3
							,intItemId = @intItemId					
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
					SELECT	[subQueryId] = 4
							,intItemId = @intItemId					
							,intItemUOMId =	Lot.intWeightUOMId
							,intItemLocationId = @intItemLocationId
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty =	@dblQty
					FROM	dbo.tblICLot Lot 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intWeightUOMId = @intItemUOMId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0					
							AND Lot.intItemUOMId <> Lot.intWeightUOMId 

					-- Convert the pack uom to weight uom 
					UNION ALL 
					SELECT	[subQueryId] = 5
							,intItemId = @intItemId					
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
								AND LotStockUOM.intItemUOMId NOT IN (Lot.intItemUOMId, Lot.intWeightUOMId)
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
					SELECT	[subQueryId] = 6
							,intItemId = @intItemId					
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
								AND LotStockUOM.intItemUOMId NOT IN (Lot.intItemUOMId, Lot.intWeightUOMId)
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intWeightUOMId = @intItemUOMId
							AND Lot.intItemLocationId = @intItemLocationId
							AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
							AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
							AND Lot.intWeightUOMId IS NOT NULL 
							AND ISNULL(Lot.dblWeightPerQty, 0) <> 0	
							AND Lot.intItemUOMId <> Lot.intWeightUOMId 

					---- Convert weight to stock unit. 
					--UNION ALL 
					--SELECT	[subQueryId] = 7
					--		,intItemId = @intItemId					
					--		,intItemUOMId =	LotStockUOM.intItemUOMId -- Stock UOM Id
					--		,intItemLocationId = @intItemLocationId
					--		,intSubLocationId = @intSubLocationId 
					--		,intStorageLocationId = @intStorageLocationId
					--		,Qty =	dbo.fnCalculateStockUnitQty(
					--					CASE	WHEN (@intItemUOMId = Lot.intItemUOMId) THEN dbo.fnMultiply(@dblQty, Lot.dblWeightPerQty) -- Stock is in packs, then convert the qty to weight. 
					--							ELSE @dblQty -- else it is in weights. Keep using the weight qty. 
					--					END 
					--					,LotWeightUOM.dblUnitQty								
					--				) 

					--FROM	dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
					--			ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
					--		INNER JOIN dbo.tblICItemUOM LotStockUOM 
					--			ON LotStockUOM.intItemId = Lot.intItemId
					--			AND LotStockUOM.ysnStockUnit = 1
					--			AND LotStockUOM.intItemUOMId NOT IN (Lot.intItemUOMId, Lot.intWeightUOMId)
					--WHERE	Lot.intLotId = @intLotId
					--		AND Lot.intItemLocationId = @intItemLocationId
					--		AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
					--		AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
					--		AND Lot.intWeightUOMId IS NOT NULL 
					--		AND ISNULL(Lot.dblWeightPerQty, 0) <> 0						

					---------------------------------------------
					-- Item is a Lot and does NOT have a Weight. 
					---------------------------------------------
					-- Get the Pack Qty (intItemUOMId) 
					UNION ALL 
					SELECT	[subQueryId] = 8
							,intItemId = @intItemId
							,intItemUOMId = @intItemUOMId
							,intItemLocationId = @intItemLocationId					
							,intSubLocationId = @intSubLocationId 
							,intStorageLocationId = @intStorageLocationId
							,Qty = ISNULL(@dblQty, 0) 
					FROM	dbo.tblICLot Lot 
					WHERE	Lot.intLotId = @intLotId
							AND Lot.intItemLocationId = @intItemLocationId
							AND Lot.intWeightUOMId IS NULL 
					
					----------------------------------------------------------------------------------------
					---- If incoming Lot has a no weight, then convert the lot item UOM to stock unit Qty
					----------------------------------------------------------------------------------------
					--UNION ALL 
					--SELECT	[subQueryId] = 9
					--		,intItemId = @intItemId
					--		,intItemUOMId =	LotStockUOM.intItemUOMId
					--		,intItemLocationId = @intItemLocationId					
					--		,intSubLocationId = @intSubLocationId 
					--		,intStorageLocationId = @intStorageLocationId
					--		,Qty =	dbo.fnCalculateStockUnitQty(@dblQty, LotItemUOM.dblUnitQty) 
					--FROM	dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotItemUOM
					--			ON Lot.intItemUOMId = LotItemUOM.intItemUOMId
					--		LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
					--			ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
					--		LEFT JOIN dbo.tblICItemUOM LotStockUOM 
					--			ON LotStockUOM.intItemId = Lot.intItemId
					--			AND LotStockUOM.ysnStockUnit = 1
					--WHERE	Lot.intLotId = @intLotId
					--		AND Lot.intItemLocationId = @intItemLocationId
					--		AND Lot.intWeightUOMId IS NULL 
					--		AND Lot.intItemUOMId <> LotStockUOM.intItemUOMId			
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
				,dtmLastPurchaseDate = CASE WHEN @intTransactionTypeId = @TransactionType_InventoryReceipt
												AND ((@ysnPost = 1 AND RawStockData.dtmTransactionDate IS NOT NULL 
													AND RawStockData.dtmTransactionDate > ISNULL(ItemStockUOM.dtmLastPurchaseDate, '2000-01-01'))
												OR @ysnPost = 0)
												THEN RawStockData.dtmTransactionDate
											ELSE ItemStockUOM.dtmLastPurchaseDate
										END
				,dtmLastSaleDate = CASE 
										WHEN @intTransactionTypeId = @TransactionType_Invoice
											AND ((@ysnPost = 1 AND RawStockData.dtmTransactionDate IS NOT NULL 
												AND RawStockData.dtmTransactionDate > ISNULL(ItemStockUOM.dtmLastSaleDate, '2000-01-01'))
											OR @ysnPost = 0)
										THEN RawStockData.dtmTransactionDate
										ELSE ItemStockUOM.dtmLastSaleDate
									END

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
			,dtmLastPurchaseDate
			,dtmLastSaleDate
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
			,CASE WHEN @intTransactionTypeId = @TransactionType_InventoryReceipt THEN RawStockData.dtmTransactionDate ELSE NULL END
			,CASE WHEN @intTransactionTypeId = @TransactionType_Invoice THEN RawStockData.dtmTransactionDate ELSE NULL END
			,1	
		)
	;
END 
