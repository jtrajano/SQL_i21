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
										CASE	WHEN Lot.intItemUOMId = ItemTransactions.intItemUOMId AND ISNULL(Lot.dblWeightPerQty, 0) <> 0 THEN 
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
	SET		dblUnitOnHand = ISNULL(ItemStock.dblUnitOnHand, 0) + ROUND(StockToUpdate.Qty, 6)

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
		,ROUND(StockToUpdate.Qty, 6) -- dblUnitOnHand
		,0
		,0
		,0
		,NULL 
		,1	
	)
;

----------------------------------------------------------
-- Update the Item Stock UOM table for non lot items
-- and non-stock unit UOMs. 
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
		FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemTransactions.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND ISNULL(ItemUOM.ysnStockUnit, 0) = 0 
				AND ItemTransactions.intLotId IS NULL 
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
	SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6)

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
		,ROUND(RawStockData.Qty, 6) 
		,0
		,1	
	)
;

--------------------------------------------------------------------------------------------------------------------
-- Update the Item Stock UOM table for non lot items but convert it to the stock unit. 
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
		FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemTransactions.intItemUOMId = ItemUOM.intItemUOMId
		WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
				AND ISNULL(ItemUOM.ysnStockUnit, 0) = 1
				AND ItemTransactions.intLotId IS NULL 
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
	SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6)

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
		,ROUND(RawStockData.Qty, 6) 
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
							AND Lot.intItemUOMId = ItemTransactions.intItemUOMId
						LEFT JOIN tblICItemUOM LotItemUOM
							ON LotItemUOM.intItemUOMId = Lot.intItemUOMId					
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
						AND Lot.intLotId IS NOT NULL 				
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
			SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6)

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
				,ROUND(RawStockData.Qty, 6) 
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
						,intItemUOMId = Lot.intWeightUOMId
						,ItemTransactions.intItemLocationId
						,ItemTransactions.intSubLocationId
						,ItemTransactions.intStorageLocationId
						,Qty = SUM(
							ItemTransactions.dblQty 
						)
				FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
							ON ItemTransactions.intLotId = Lot.intLotId
							AND ItemTransactions.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId					
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
						AND Lot.intLotId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId
				GROUP BY ItemTransactions.intItemId, Lot.intWeightUOMId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
		) AS RawStockData
			ON ItemStockUOM.intItemId = RawStockData.intItemId
			AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
			AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
			AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
			AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)

		-- If matched, update the unit on hand qty. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6) 

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
				,ROUND(RawStockData.Qty, 6)  
				,0
				,1	
			)
		;

		------------------------------------------------------------------------------
		-- Update the Item Stock UOM table. Convert the Pack UOM into Weight UOM
		------------------------------------------------------------------------------
		MERGE	
		INTO	dbo.tblICItemStockUOM 
		WITH	(HOLDLOCK) 
		AS		ItemStockUOM	
		USING (
				SELECT	ItemTransactions.intItemId
						,intItemUOMId = Lot.intWeightUOMId
						,ItemTransactions.intItemLocationId
						,ItemTransactions.intSubLocationId
						,ItemTransactions.intStorageLocationId
						,Qty = SUM(
							dbo.fnMultiply(ItemTransactions.dblQty, Lot.dblWeightPerQty)  
						)
				FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
							ON ItemTransactions.intLotId = Lot.intLotId
							AND ItemTransactions.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId					
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
						AND Lot.intLotId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId
				GROUP BY ItemTransactions.intItemId, Lot.intWeightUOMId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
		) AS RawStockData
			ON ItemStockUOM.intItemId = RawStockData.intItemId
			AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
			AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
			AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
			AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)

		-- If matched, update the unit on hand qty. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6) 

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
				,ROUND(RawStockData.Qty, 6)  
				,0
				,1	
			)
		;

		------------------------------------------------------------------------------
		-- Update the Item Stock UOM table. Convert the weight UOM into Pack UOM
		------------------------------------------------------------------------------
		MERGE	
		INTO	dbo.tblICItemStockUOM 
		WITH	(HOLDLOCK) 
		AS		ItemStockUOM	
		USING (
				SELECT	ItemTransactions.intItemId
						,intItemUOMId = Lot.intItemUOMId
						,ItemTransactions.intItemLocationId
						,ItemTransactions.intSubLocationId
						,ItemTransactions.intStorageLocationId
						,Qty = SUM(
							dbo.fnDivide(ItemTransactions.dblQty, Lot.dblWeightPerQty)  
						)
				FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
							ON ItemTransactions.intLotId = Lot.intLotId
							AND ItemTransactions.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId					
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
						AND Lot.intLotId IS NOT NULL 
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
			SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6) 

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
				,ROUND(RawStockData.Qty, 6)  
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
							dbo.fnMultiply(dbo.fnMultiply(ItemTransactions.dblQty, Lot.dblWeightPerQty), WeightUOM.dblUnitQty) 
						)
				FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
							ON ItemTransactions.intLotId = Lot.intLotId
							AND ItemTransactions.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN tblICItemUOM LotItemUOM
							ON LotItemUOM.intItemUOMId = Lot.intItemUOMId					
						LEFT JOIN tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
						AND Lot.intLotId IS NOT NULL 
						AND Lot.intWeightUOMId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId 
						AND dbo.fnGetItemStockUOM(ItemTransactions.intItemId) <> Lot.intItemUOMId 
						AND dbo.fnGetItemStockUOM(ItemTransactions.intItemId) <> Lot.intWeightUOMId 

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
			SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6)

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
				,ROUND(RawStockData.Qty, 6) 
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
							dbo.fnMultiply(ItemTransactions.dblQty, ItemTransactions.dblUOMQty) 
						)
				FROM	dbo.tblICInventoryTransaction ItemTransactions LEFT JOIN tblICLot Lot
							ON ItemTransactions.intLotId = Lot.intLotId
							AND ItemTransactions.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN tblICItemUOM LotItemUOM
							ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
						AND Lot.intLotId IS NOT NULL 						
						AND Lot.intItemUOMId <> Lot.intWeightUOMId
						AND dbo.fnGetItemStockUOM(ItemTransactions.intItemId) <> Lot.intWeightUOMId 
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
			SET		dblOnHand = ISNULL(ItemStockUOM.dblOnHand, 0) + ROUND(RawStockData.Qty, 6) 

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
				,ROUND(RawStockData.Qty, 6) 
				,0
				,1	
			);

-------------------
--UPDATE ON ORDER
-------------------
BEGIN 
	UPDATE tblICItemStock
	SET dblOnOrder = 0

	UPDATE tblICItemStockUOM
	SET dblOnOrder = 0 

	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
					SELECT
			 intItemId
			 ,intItemLocationId
			 ,SUM(dblOnOrder) dblOnOrder
			 FROM (
				SELECT	
					B.intItemId
					,C.intItemLocationId
					,dblOnOrder =  (CASE WHEN dblQtyReceived > dblQtyOrdered THEN 0 ELSE dblQtyOrdered - dblQtyReceived END) * D.dblUnitQty --ItemStock should be the base qty
				FROM tblPOPurchase A
				INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
				INNER JOIN tblICItemLocation C
					ON A.intShipToId = C.intLocationId AND B.intItemId = C.intItemId
				INNER JOIN tblICItemUOM D ON B.intUnitOfMeasureId = D.intItemUOMId AND B.intItemId = D.intItemId
				WHERE 
				intOrderStatusId NOT IN (4, 3, 6)
				OR (dblQtyOrdered > dblQtyReceived AND intOrderStatusId NOT IN (4, 3, 6))--Handle wrong status of PO, greater qty received should be closed status
			) ItemTransactions
			GROUP BY intItemLocationId, intItemId
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on order qty. 
	WHEN MATCHED THEN 
		UPDATE 
		--SET		dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0) + StockToUpdate.dblOnOrder
		SET		dblOnOrder = StockToUpdate.dblOnOrder

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
			,0
			,StockToUpdate.dblOnOrder
			,0
			,0
			,NULL 
			,1	
		);
	--UPDATE tblICItemStockUOM
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
			SELECT	
				B.intItemId
				,B.intUnitOfMeasureId AS intItemUOMId
				,C.intItemLocationId
				,B.intSubLocationId
				,B.intStorageLocationId
				,dblOnOrder =  (CASE WHEN SUM(dblQtyReceived) > SUM(dblQtyOrdered) THEN 0 ELSE SUM(dblQtyOrdered) - SUM(dblQtyReceived) END)
			FROM tblPOPurchase A
			INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
			INNER JOIN tblICItemLocation C
				ON A.intShipToId = C.intLocationId AND B.intItemId = C.intItemId
			WHERE 
			intOrderStatusId NOT IN (4, 3, 6)
			OR (dblQtyOrdered > dblQtyReceived AND intOrderStatusId NOT IN (4, 3, 6))--Handle wrong status of PO, greater qty received should be closed status
			GROUP BY B.intItemId,
			 B.intUnitOfMeasureId,
			 C.intItemLocationId,
			 B.intSubLocationId,
			 B.intStorageLocationId


			--SELECT	ItemTransactions.intItemId
			--		,ItemTransactions.intUnitOfMeasureId AS intItemUOMId
			--		,ItemTransactions.intItemLocationId
			--		,ItemTransactions.intSubLocationId
			--		,ItemTransactions.intStorageLocationId
			--		,dblOnOrder = (CASE WHEN SUM(dblQtyReceived) > SUM(dblQtyOrdered) THEN 0 ELSE SUM(dblQtyOrdered) - SUM(dblQtyReceived) END)
			--FROM	vyuPOStatus ItemTransactions
			--WHERE 
			--intOrderStatusId NOT IN (4, 3, 6)
			--OR (dblQtyOrdered < dblQtyReceived)--Handle wrong status of PO, greater qty received should be closed status
			--GROUP BY ItemTransactions.intItemId, ItemTransactions.intUnitOfMeasureId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

	WHEN MATCHED THEN 
		UPDATE 
		--SET		dblOnOrder = ISNULL(ItemStockUOM.dblOnOrder, 0) + RawStockData.dblOnOrder
		SET		dblOnOrder = RawStockData.dblOnOrder

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
			,0
			,RawStockData.dblOnOrder
			,1	
		);
END;

--------------------------------------
--Update the In-Transit Outbound 
--------------------------------------
BEGIN 
	UPDATE tblICItemStock
	SET dblInTransitOutbound = 0

	UPDATE tblICItemStockUOM
	SET dblInTransitOutbound = 0 

	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,dblInTransitOutbound = SUM(ISNULL(Shipment.dblQuantity, 0) - ISNULL(SalesInvoice.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQuantity, u.dblUnitQty))
					FROM	tblICInventoryShipment h INNER JOIN tblICInventoryShipmentItem d
								ON h.intInventoryShipmentId = d.intInventoryShipmentId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId						
					WHERE	h.ysnPosted = 1
							AND h.intShipFromLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							
				) Shipment 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQtyShipped, u.dblUnitQty)) 
					FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
								on h.intInvoiceId = d.intInvoiceId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId
							INNER JOIN tblICInventoryShipmentItem shipmentItem
								ON shipmentItem.intInventoryShipmentId = d.intInventoryShipmentItemId 
					WHERE	h.ysnPosted = 1
							AND h.intCompanyLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
				) SalesInvoice 
		GROUP BY il.intItemLocationId, i.intItemId
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on order qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblInTransitOutbound = StockToUpdate.dblInTransitOutbound

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND ISNULL(StockToUpdate.dblInTransitOutbound, 0) <> 0 THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblInTransitOutbound
			,intSort
			,intConcurrencyId
		)
		VALUES (
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,StockToUpdate.dblInTransitOutbound
			,NULL 
			,1	
		);

	-- Update the Stock UOM
	-- (1) Convert all qty to stock unit
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,StockUOM.intItemUOMId
				,SubLocation.intSubLocationId
				,StorageLocation.intStorageLocationId
				,dblInTransitOutbound = SUM(ISNULL(Shipment.dblQuantity, 0) - ISNULL(SalesInvoice.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				CROSS APPLY (
					SELECT	intItemUOMId
					FROM	tblICItemUOM stockUOM
					WHERE	stockUOM.intItemId = i.intItemId
							AND stockUOM.ysnStockUnit = 1
				) StockUOM
				OUTER APPLY (
					SELECT	intSubLocationId = intCompanyLocationSubLocationId
					FROM	tblSMCompanyLocationSubLocation sub
					WHERE	sub.intCompanyLocationId = il.intLocationId 
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) SubLocation 
				OUTER APPLY (
					SELECT	intStorageLocationId 
					FROM	tblICStorageLocation storage 
					WHERE	storage.intLocationId = il.intLocationId
							AND storage.intSubLocationId = SubLocation.intSubLocationId  
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) StorageLocation
 				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQuantity, u.dblUnitQty))
					FROM	tblICInventoryShipment h INNER JOIN tblICInventoryShipmentItem d
								ON h.intInventoryShipmentId = d.intInventoryShipmentId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId						
					WHERE	h.ysnPosted = 1
							AND h.intShipFromLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 							
				) Shipment 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQtyShipped, u.dblUnitQty))
					FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
								on h.intInvoiceId = d.intInvoiceId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId
							INNER JOIN tblICInventoryShipmentItem shipmentItem
								ON shipmentItem.intInventoryShipmentId = d.intInventoryShipmentItemId 
					WHERE	h.ysnPosted = 1
							AND h.intCompanyLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 
				) SalesInvoice 
			GROUP BY i.intItemId, il.intItemLocationId, StockUOM.intItemUOMId, SubLocation.intSubLocationId, StorageLocation.intStorageLocationId
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

	WHEN MATCHED THEN 
		UPDATE 
		SET		dblInTransitOutbound = RawStockData.dblInTransitOutbound

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND ISNULL(RawStockData.dblInTransitOutbound, 0) <> 0 THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblInTransitOutbound
			,intConcurrencyId
		)
		VALUES (
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.dblInTransitOutbound
			,1	
		)
	;

	-- Update the Stock UOM
	-- (2) ysnStockUnit = 0 
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,uom.intItemUOMId 
				,SubLocation.intSubLocationId
				,StorageLocation.intStorageLocationId
				,dblInTransitOutbound = SUM(ISNULL(Shipment.dblQuantity, 0) - ISNULL(SalesInvoice.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				INNER JOIN tblICItemUOM uom
					ON uom.intItemId = i.intItemId
					AND ISNULL(uom.ysnStockUnit, 0) = 0
				OUTER APPLY (
					SELECT	intSubLocationId = intCompanyLocationSubLocationId
					FROM	tblSMCompanyLocationSubLocation sub
					WHERE	sub.intCompanyLocationId = il.intLocationId 
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) SubLocation 
				OUTER APPLY (
					SELECT	intStorageLocationId 
					FROM	tblICStorageLocation storage 
					WHERE	storage.intLocationId = il.intLocationId
							AND storage.intSubLocationId = SubLocation.intSubLocationId  
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) StorageLocation
 				OUTER APPLY (
					SELECT  dblQuantity = SUM(d.dblQuantity)
					FROM	tblICInventoryShipment h INNER JOIN tblICInventoryShipmentItem d
								ON h.intInventoryShipmentId = d.intInventoryShipmentId
					WHERE	h.ysnPosted = 1
							AND h.intShipFromLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND d.intItemUOMId = uom.intItemUOMId
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 							
				) Shipment 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(d.dblQtyShipped)
					FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
								on h.intInvoiceId = d.intInvoiceId
							INNER JOIN tblICInventoryShipmentItem shipmentItem
								ON shipmentItem.intInventoryShipmentId = d.intInventoryShipmentItemId 
					WHERE	h.ysnPosted = 1
							AND h.intCompanyLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND d.intItemUOMId = uom.intItemUOMId
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 
				) SalesInvoice 
			GROUP BY i.intItemId, il.intItemLocationId, uom.intItemUOMId, SubLocation.intSubLocationId, StorageLocation.intStorageLocationId
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

	WHEN MATCHED THEN 
		UPDATE 
		SET		dblInTransitOutbound = RawStockData.dblInTransitOutbound

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND ISNULL(RawStockData.dblInTransitOutbound, 0) <> 0 THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblInTransitOutbound
			,intConcurrencyId
		)
		VALUES (
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.dblInTransitOutbound
			,1	
		)
	;
END 

--------------------------------------
--Update the Reservation
--------------------------------------
BEGIN 
	DECLARE @FixStockReservation AS ItemReservationTableType

	UPDATE	s
	SET		dblUnitReserved = 0 
	FROM	tblICItemStock s 

	UPDATE	s
	SET		dblUnitReserved = 0 
	FROM	tblICItemStockUOM 
			
	INSERT INTO @FixStockReservation (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intSubLocationId
			,intStorageLocationId	
	)
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,SUM(dblQty)
			,intTransactionId
			,strTransactionId
			,intInventoryTransactionType
			,intSubLocationId
			,intStorageLocationId	 
	FROM	tblICStockReservation r 
	WHERE	r.ysnPosted = 0 
	GROUP BY intItemId
			, intItemLocationId
			, intItemUOMId
			, intLotId
			, intTransactionId
			, strTransactionId
			, intInventoryTransactionType
			, intSubLocationId
			, intStorageLocationId

	-- Call this SP to increase the reserved qty. 
	EXEC dbo.uspICIncreaseReservedQty
		@FixStockReservation
END 