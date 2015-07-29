/*
	CAUTION: Execute this stored procedure with extreme care.

	This is a utility stored procedure used to fix the stock quantities. 
	
	Features
	----------------------------------------------------------------
	07/08/2015:		Re-calculate the On-Hand Qty. 

*/
CREATE PROCEDURE [dbo].[uspICFixStockQuantities]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE tblICItemStock
SET dblUnitOnHand = 0

UPDATE tblICItemStockUOM
SET dblOnHand = 0 

-----------------------------------
-- Update the Item Stock table
-----------------------------------
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ItemTransactions.intItemId
				,ItemTransactions.intItemLocationId
				,Qty =	SUM (
							CASE	WHEN Lot.intLotId IS NOT NULL AND Lot.intItemUOMId <> Lot.intWeightUOMId THEN 
										CASE	WHEN Lot.intItemUOMId = ItemTransactions.intItemUOMId THEN 
													-- Get the actual weight and convert it to stock unit  
													dbo.fnCalculateStockUnitQty(ItemTransactions.dblQty * Lot.dblWeightPerQty, WeightUOM.dblUnitQty) 
												ELSE
													-- the qty is already in weight, then convert the weight to stock unit. 
													dbo.fnCalculateStockUnitQty(ItemTransactions.dblQty, WeightUOM.dblUnitQty) 
										END 
									ELSE
										dbo.fnCalculateStockUnitQty(ItemTransactions.dblQty, ItemTransactions.dblUOMQty) 
							END				
						)
						
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
		GROUP BY ItemTransactions.intItemId, ItemTransactions.intItemLocationId
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

----------------------------------------------------------
-- Update the Item Stock UOM table for non lot items
----------------------------------------------------------
MERGE	
INTO	dbo.tblICItemStockUOM 
WITH	(HOLDLOCK) 
AS		ItemStockUOM	
USING (
		SELECT	ItemTransactions.intItemId
				,ItemTransactions.intItemUOMId
				,ItemTransactions.intItemLocationId
				,ItemTransactions.intSubLocationId
				,ItemTransactions.intStorageLocationId
				,Qty = SUM(ItemTransactions.dblQty)
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND Lot.intLotId IS NULL 
		GROUP BY ItemTransactions.intItemId, ItemTransactions.intItemUOMId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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

--------------------------------------------------------------------------------------------------------------------
-- Update the Item Stock UOM table for non lot items but converts it into the stock unit
--------------------------------------------------------------------------------------------------------------------
MERGE	
INTO	dbo.tblICItemStockUOM 
WITH	(HOLDLOCK) 
AS		ItemStockUOM	
USING (
		SELECT	ItemTransactions.intItemId
				,intItemUOMId = dbo.fnGetItemStockUOM(ItemTransactions.intItemId) 
				,ItemTransactions.intItemLocationId
				,ItemTransactions.intSubLocationId
				,ItemTransactions.intStorageLocationId
				,Qty = SUM(ItemTransactions.dblQty * ItemTransactions.dblUOMQty)
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND Lot.intLotId IS NULL 
				AND dbo.fnGetItemStockUOM(ItemTransactions.intItemId) IS NOT NULL 
				AND dbo.fnGetItemStockUOM(ItemTransactions.intItemId) <> ItemTransactions.intItemUOMId
		GROUP BY ItemTransactions.intItemId, dbo.fnGetItemStockUOM(ItemTransactions.intItemId), ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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
---------------------------------------------------------------------------
-- Update the Item Stock UOM table for lot items in favor of item UOM id
---------------------------------------------------------------------------
MERGE	
INTO	dbo.tblICItemStockUOM 
WITH	(HOLDLOCK) 
AS		ItemStockUOM	
USING (
		SELECT	ItemTransactions.intItemId
				,Lot.intItemUOMId
				,ItemTransactions.intItemLocationId
				,ItemTransactions.intSubLocationId
				,ItemTransactions.intStorageLocationId
				,Qty = SUM(
					ItemTransactions.dblQty
				)
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND Lot.intLotId IS NOT NULL 
				AND Lot.intItemUOMId = ItemTransactions.intItemUOMId
		GROUP BY ItemTransactions.intItemId, Lot.intItemUOMId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update the Item Stock UOM table for lot items in favor the item UOM. But this one converts it to weight and then to stock unit
------------------------------------------------------------------------------------------------------------------------------------------------------
MERGE	
INTO	dbo.tblICItemStockUOM 
WITH	(HOLDLOCK) 
AS		ItemStockUOM	
USING (
		SELECT	ItemTransactions.intItemId
				,intItemUOMId = dbo.fnGetItemStockUOM(ItemTransactions.intItemId) 
				,ItemTransactions.intItemLocationId
				,ItemTransactions.intSubLocationId
				,ItemTransactions.intStorageLocationId
				,Qty = SUM(
					ItemTransactions.dblQty * Lot.dblWeightPerQty * WeightUOM.dblUnitQty 
				)
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND Lot.intLotId IS NOT NULL 
				AND Lot.intItemUOMId = ItemTransactions.intItemUOMId
				AND Lot.intItemUOMId <> Lot.intWeightUOMId
		GROUP BY ItemTransactions.intItemId, dbo.fnGetItemStockUOM(ItemTransactions.intItemId), ItemTransactions.intItemLocationId ,ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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

------------------------------------------------------------------------------
-- Update the Item Stock UOM table for lot items in favor of the weight UOM
------------------------------------------------------------------------------
MERGE	
INTO	dbo.tblICItemStockUOM 
WITH	(HOLDLOCK) 
AS		ItemStockUOM	
USING (
		SELECT	ItemTransactions.intItemId
				,Lot.intItemUOMId
				,ItemTransactions.intItemLocationId
				,ItemTransactions.intSubLocationId
				,ItemTransactions.intStorageLocationId
				,Qty = SUM(
					ItemTransactions.dblQty / Lot.dblWeightPerQty
				)
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND Lot.intLotId IS NOT NULL 
				AND Lot.intWeightUOMId = ItemTransactions.intItemUOMId
				AND ISNULL(Lot.dblWeightPerQty, 0) <> 0
				AND Lot.intItemUOMId <> Lot.intWeightUOMId
		GROUP BY ItemTransactions.intItemId, Lot.intItemUOMId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update the Item Stock UOM table for lot items in favor of the weight UOM. But this one converts the weight into the stock unit. 
------------------------------------------------------------------------------------------------------------------------------------------------------------
MERGE	
INTO	dbo.tblICItemStockUOM 
WITH	(HOLDLOCK) 
AS		ItemStockUOM	
USING (
		SELECT	ItemTransactions.intItemId
				,intItemUOMId = dbo.fnGetItemStockUOM(ItemTransactions.intItemId) 
				,ItemTransactions.intItemLocationId
				,ItemTransactions.intSubLocationId
				,ItemTransactions.intStorageLocationId
				,Qty = SUM(
					ItemTransactions.dblQty * ItemTransactions.dblUOMQty
				)
		FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
					ON ItemTransactions.intLotId = Lot.intLotId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND Lot.intLotId IS NOT NULL 
				AND Lot.intWeightUOMId = ItemTransactions.intItemUOMId
				AND dbo.fnGetItemStockUOM(ItemTransactions.intItemId) IS NOT NULL 
				AND Lot.intItemUOMId <> Lot.intWeightUOMId
		GROUP BY ItemTransactions.intItemId, dbo.fnGetItemStockUOM(ItemTransactions.intItemId), ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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