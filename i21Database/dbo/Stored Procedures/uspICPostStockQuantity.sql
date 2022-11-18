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
	@intLotId AS INT,
	@intTransactionTypeId AS INT = NULL,
	@dtmTransactionDate AS DATETIME = NULL,
	@ysnPost AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Initialize the parameters
SET @dblQty = ISNULL(@dblQty, 0)
SET @dblUOMQty = ISNULL(@dblUOMQty, 0)

DECLARE @dtmLastPurchaseDate AS DATETIME
		,@dtmLastSaleDate AS DATETIME 

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

IF EXISTS (
	SELECT TOP 1 1 
	FROM tblICItem i 
	WHERE 
		i.intItemId = @intItemId 
		AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 
		AND ISNULL(i.strLotTracking, 'No') = 'No'
) 
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

-----------------------------------------------------------
-- If unposting, get the last posted purchase or sale date 
-----------------------------------------------------------
IF @ysnPost = 0 
BEGIN 
	SELECT TOP 1 
		@dtmLastPurchaseDate = dtmDate
	FROM 
		tblICInventoryTransaction
	WHERE 
		@intTransactionTypeId = @TransactionType_InventoryReceipt
		AND intItemId = @intItemId
		AND (intSubLocationId = @intSubLocationId OR (intSubLocationId IS NULL AND @intSubLocationId IS NULL))
		AND (intStorageLocationId = @intStorageLocationId OR (intStorageLocationId IS NULL AND @intStorageLocationId IS NULL))			
		AND intTransactionTypeId = @TransactionType_InventoryReceipt 
		AND ysnIsUnposted <> 1
	ORDER BY 
		intInventoryTransactionId DESC

	SELECT TOP 1 
		@dtmLastSaleDate = dtmDate
	FROM 
		tblICInventoryTransaction
	WHERE 
		@intTransactionTypeId = @TransactionType_Invoice
		AND intItemId = @intItemId
		AND (intSubLocationId = @intSubLocationId OR (intSubLocationId IS NULL AND @intSubLocationId IS NULL))
		AND (intStorageLocationId = @intStorageLocationId OR (intStorageLocationId IS NULL AND @intStorageLocationId IS NULL))
		AND intTransactionTypeId = @TransactionType_Invoice 
		AND ysnIsUnposted <> 1
	ORDER BY 
		intInventoryTransactionId DESC
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
			WHERE
				@intItemId IS NOT NULL 
				AND @intItemLocationId IS NOT NULL 
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0) + StockToUpdate.Qty
				,dtmLastPurchaseDate = 
						CASE 
							WHEN 
								@intTransactionTypeId = @TransactionType_InventoryReceipt
								AND @ysnPost = 1
								AND @dtmTransactionDate IS NOT NULL
								AND @dtmTransactionDate > ISNULL(ItemStock.dtmLastPurchaseDate, '2000-01-01')
							THEN
								@dtmTransactionDate

							WHEN 
								@intTransactionTypeId = @TransactionType_InventoryReceipt
								AND @ysnPost = 0 
								AND @dtmLastPurchaseDate IS NOT NULL 
							THEN 
								@dtmLastPurchaseDate

							ELSE 
								ItemStock.dtmLastPurchaseDate
						END 

				,dtmLastSaleDate = 
						CASE 
							WHEN @intTransactionTypeId = @TransactionType_Invoice
							AND @ysnPost = 1
							AND @dtmTransactionDate IS NOT NULL 
							AND @dtmTransactionDate > ISNULL(ItemStock.dtmLastSaleDate, '2000-01-01')
							THEN 
								@dtmTransactionDate

							WHEN @intTransactionTypeId = @TransactionType_Invoice
							AND @ysnPost = 0 
							AND @dtmLastSaleDate IS NOT NULL
							THEN
								@dtmLastSaleDate

							ELSE 
								ItemStock.dtmLastSaleDate
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
			,CASE WHEN @intTransactionTypeId = @TransactionType_InventoryReceipt THEN @dtmTransactionDate ELSE NULL END
			,CASE WHEN @intTransactionTypeId = @TransactionType_Invoice THEN @dtmTransactionDate ELSE NULL END
			,1	
		)
	;
END		

BEGIN 
	DECLARE @tblItemStockUOM AS TABLE (
		intItemId INT 
		,intItemUOMId INT 
		,intItemLocationId INT  
		,intSubLocationId INT NULL
		,intStorageLocationId INT NULL
		,dblQty NUMERIC(30, 20) NULL 
		,dtmPurchaseDate DATETIME 
		,dtmSaleDate DATETIME 
	)

	-------------------------------------------
	-- Item is NOT a Lot. 
	-------------------------------------------
	INSERT INTO @tblItemStockUOM (
		intItemId 
		,intItemUOMId 
		,intItemLocationId 
		,intSubLocationId 
		,intStorageLocationId 
		,dblQty 
	)
	-- Get the Qty as it is. 
	SELECT	
			intItemId = @intItemId
			,intItemUOMId = @intItemUOMId
			,intItemLocationId = @intItemLocationId					
			,intSubLocationId = @intSubLocationId 
			,intStorageLocationId = @intStorageLocationId
			,dblQty = ISNULL(@dblQty, 0) 
	WHERE	@intLotId IS NULL 	 

	-------------------------------------------
	-- Item is a Lotted. 
	-------------------------------------------
	-- Get the Pack Qty (Lot.intItemUOMId) 
	INSERT INTO @tblItemStockUOM (
		intItemId 
		,intItemUOMId 
		,intItemLocationId 
		,intSubLocationId 
		,intStorageLocationId 
		,dblQty 
	)
	SELECT	
		intItemId = @intItemId					
		,intItemUOMId =	Lot.intItemUOMId 
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId 
		,intStorageLocationId = @intStorageLocationId
		,dblQty = @dblQty
	FROM	
		dbo.tblICLot Lot 
	WHERE	
		Lot.intLotId = @intLotId
		AND Lot.intItemUOMId = @intItemUOMId
		AND Lot.intItemLocationId = @intItemLocationId
		AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND Lot.intWeightUOMId IS NOT NULL 
		AND ISNULL(Lot.dblWeightPerQty, 0) <> 0			
					
	-- Get the Weight Qty (Lot.intWeightUOMId) 
	INSERT INTO @tblItemStockUOM (
		intItemId 
		,intItemUOMId 
		,intItemLocationId 
		,intSubLocationId 
		,intStorageLocationId 
		,dblQty 
	)
	SELECT	
		intItemId = @intItemId					
		,intItemUOMId =	Lot.intWeightUOMId
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId 
		,intStorageLocationId = @intStorageLocationId
		,dblQty = @dblQty
	FROM	
		dbo.tblICLot Lot 
	WHERE	
		Lot.intLotId = @intLotId
		AND Lot.intWeightUOMId = @intItemUOMId
		AND Lot.intItemLocationId = @intItemLocationId
		AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND Lot.intWeightUOMId IS NOT NULL 
		AND ISNULL(Lot.dblWeightPerQty, 0) <> 0					
		AND Lot.intItemUOMId <> Lot.intWeightUOMId 

	-- Convert the pack uom to weight uom 
	INSERT INTO @tblItemStockUOM (
		intItemId 
		,intItemUOMId 
		,intItemLocationId 
		,intSubLocationId 
		,intStorageLocationId 
		,dblQty 
	)
	SELECT	
		intItemId = @intItemId					
		,intItemUOMId =	Lot.intWeightUOMId 
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId 
		,intStorageLocationId = @intStorageLocationId
		,dblQty = dbo.fnMultiply(@dblQty, Lot.dblWeightPerQty) 
	FROM	
		dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
			ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
		LEFT JOIN dbo.tblICItemUOM LotStockUOM 
			ON LotStockUOM.intItemId = Lot.intItemId
			AND LotStockUOM.ysnStockUnit = 1
			AND LotStockUOM.intItemUOMId NOT IN (Lot.intItemUOMId, Lot.intWeightUOMId)
	WHERE	
		Lot.intLotId = @intLotId
		AND Lot.intItemUOMId = @intItemUOMId
		AND Lot.intItemLocationId = @intItemLocationId
		AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND Lot.intWeightUOMId IS NOT NULL 
		AND ISNULL(Lot.dblWeightPerQty, 0) <> 0	
		AND Lot.intItemUOMId <> Lot.intWeightUOMId 

	-- Convert the weight uom to pack uom 
	INSERT INTO @tblItemStockUOM (
		intItemId 
		,intItemUOMId 
		,intItemLocationId 
		,intSubLocationId 
		,intStorageLocationId 
		,dblQty 
	)					
	SELECT	
		intItemId = @intItemId					
		,intItemUOMId =	Lot.intItemUOMId 
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId 
		,intStorageLocationId = @intStorageLocationId
		,dblQty = dbo.fnDivide(@dblQty, Lot.dblWeightPerQty) 
	FROM	
		dbo.tblICLot Lot LEFT JOIN dbo.tblICItemUOM LotWeightUOM 
			ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
		LEFT JOIN dbo.tblICItemUOM LotStockUOM 
			ON LotStockUOM.intItemId = Lot.intItemId
			AND LotStockUOM.ysnStockUnit = 1
			AND LotStockUOM.intItemUOMId NOT IN (Lot.intItemUOMId, Lot.intWeightUOMId)
	WHERE	
		Lot.intLotId = @intLotId
		AND Lot.intWeightUOMId = @intItemUOMId
		AND Lot.intItemLocationId = @intItemLocationId
		AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND Lot.intWeightUOMId IS NOT NULL 
		AND ISNULL(Lot.dblWeightPerQty, 0) <> 0	
		AND Lot.intItemUOMId <> Lot.intWeightUOMId 		

	---------------------------------------------
	-- Item is a Lot and does NOT have a Weight. 
	---------------------------------------------
	-- Get the Pack Qty (intItemUOMId) 
	INSERT INTO @tblItemStockUOM (
		intItemId 
		,intItemUOMId 
		,intItemLocationId 
		,intSubLocationId 
		,intStorageLocationId 
		,dblQty 
	)
	SELECT	
		intItemId = @intItemId
		,intItemUOMId = @intItemUOMId
		,intItemLocationId = @intItemLocationId					
		,intSubLocationId = @intSubLocationId 
		,intStorageLocationId = @intStorageLocationId
		,dblQty = ISNULL(@dblQty, 0) 
	FROM	
		dbo.tblICLot Lot 
	WHERE	
		Lot.intLotId = @intLotId
		AND Lot.intItemLocationId = @intItemLocationId
		AND Lot.intWeightUOMId IS NULL 

	---------------------------------------------------
	-- UPDATE THE STOCK UOM
	---------------------------------------------------
	;MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
				SELECT	
					intItemId 
					,intItemUOMId 
					,intItemLocationId 
					,intSubLocationId 
					,intStorageLocationId 
					,Qty = ROUND(SUM(dblQty), 6)
				FROM 
					@tblItemStockUOM
				GROUP BY 
					intItemId 
					,intItemUOMId 
					,intItemLocationId 
					,intSubLocationId 
					,intStorageLocationId 

	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND (
			ItemStockUOM.intSubLocationId = RawStockData.intSubLocationId
			OR (ItemStockUOM.intSubLocationId IS NULL AND RawStockData.intSubLocationId IS NULL) 
		)
		AND (
			ItemStockUOM.intStorageLocationId = RawStockData.intStorageLocationId
			OR (ItemStockUOM.intStorageLocationId IS NULL AND RawStockData.intStorageLocationId IS NULL)
		)

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + RawStockData.Qty
				,dtmLastPurchaseDate = 				
					CASE 
						-- When posting, use @dtmTransactionDate to update the last purchase date. 
						WHEN 
							@intTransactionTypeId = @TransactionType_InventoryReceipt
							AND @ysnPost = 1 
							AND @dtmTransactionDate IS NOT NULL 
							AND @dtmTransactionDate > ISNULL(ItemStockUOM.dtmLastPurchaseDate, '2000-01-01')
						THEN
							@dtmTransactionDate

						-- When unposting, use @dtmLastPurchaseDate to update the last purchase date. 
						WHEN 
							@intTransactionTypeId = @TransactionType_InventoryReceipt
							AND @ysnPost = 0
							AND @dtmLastPurchaseDate IS NOT NULL 
						THEN
							@dtmLastPurchaseDate

						-- Otherwise, keep it the same. 
						ELSE 
							ItemStockUOM.dtmLastPurchaseDate
					END

				,dtmLastSaleDate = 
					CASE
						WHEN 
							@intTransactionTypeId = @TransactionType_Invoice
							AND @ysnPost = 1
							AND @dtmTransactionDate IS NOT NULL 
							AND @dtmTransactionDate > ISNULL(ItemStockUOM.dtmLastSaleDate, '2000-01-01')
						THEN 
							@dtmTransactionDate

						WHEN 
							@intTransactionTypeId = @TransactionType_Invoice
							AND @ysnPost = 0
							AND @dtmLastSaleDate IS NOT NULL 
						THEN 
							@dtmLastSaleDate

						ELSE
							ItemStockUOM.dtmLastSaleDate
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
			,CASE WHEN @intTransactionTypeId = @TransactionType_InventoryReceipt THEN @dtmTransactionDate ELSE NULL END
			,CASE WHEN @intTransactionTypeId = @TransactionType_Invoice THEN @dtmTransactionDate ELSE NULL END
			,1	
		)
	;
END 

-- Cache Item
EXEC dbo.uspICCacheItem @intItemId