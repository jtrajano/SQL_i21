/*
	CAUTION: Execute this stored procedure with extreme care.

	This is a utility stored procedure used to fix on-hand stocks. 
*/
CREATE PROCEDURE [dbo].[uspICFixStockOnHand]
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
BEGIN 
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
END 

----------------------------------------------------------
-- Fix Stock UOM for non-lotted items. 
----------------------------------------------------------
BEGIN 
	/*------------------------------------------------------------------------------------------------------------
      Update On-Hand for the uom, regardless of stock-unit setup. 
      
	  Ex. 
	  If LB is the stock-unit and Bushel (BU) is the other uom:

      (1) If transaction is in BU, on-hand for BU is updated. The on-hand for LB is not updated. 
	  (2) If transaction is in LB, on-hand for LB is updated. The on-hand for BU is not updated. 
	------------------------------------------------------------------------------------------------------------*/
	BEGIN 
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
	END 

	/*------------------------------------------------------------------------------------------------------------
      Update On-Hand the stock-unit UOM. 
      
	  Ex. 
	  If LB is the stock-unit and Bushel (BU) is the other uom:

      (1) If transaction is in BU, BU is converted first to LB and it is used to update the on-hand for LB. 	  
	  The on-hand for BU is not updated. 

	  (2) If transaction is in LB, do not update the on-hand for LB.
	  It is already updated in the script above, "Update On-Hand for the uom, regardless if stock-unit setup."
	------------------------------------------------------------------------------------------------------------*/
	BEGIN 
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
						,Qty = SUM(dbo.fnCalculateStockUnitQty(ItemTransactions.dblQty, ItemTransactions.dblUOMQty))
				FROM	dbo.tblICInventoryTransaction ItemTransactions INNER JOIN dbo.tblICItemUOM ItemUOM
							ON ItemTransactions.intItemUOMId = ItemUOM.intItemUOMId
							AND ISNULL(ItemUOM.ysnStockUnit, 0) = 0 
				WHERE	ISNULL(ItemTransactions.ysnIsUnposted, 0) = 0
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
	END 
END 

---------------------------------------------------------------------------
-- LOT ITEMS 
---------------------------------------------------------------------------
BEGIN 
	---------------------------------------------------------------------------
	-- Update the Item Stock UOM table for lot items in favor of item UOM id
	---------------------------------------------------------------------------
	BEGIN 
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
	END 

	------------------------------------------------------------------------------
	-- Update the Item Stock UOM table for lot items in favor of the weight UOM
	------------------------------------------------------------------------------
	BEGIN 
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
	END 

	------------------------------------------------------------------------------
	-- Update the Item Stock UOM table. Convert the Pack UOM into Weight UOM
	------------------------------------------------------------------------------
	BEGIN 
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
	END

	------------------------------------------------------------------------------
	-- Update the Item Stock UOM table. Convert the weight UOM into Pack UOM
	------------------------------------------------------------------------------
	BEGIN 
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
	END 

	------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Update the Item Stock UOM table for lot items in favor the item UOM. But this one converts it to weight and then to stock unit
	------------------------------------------------------------------------------------------------------------------------------------------------------
	BEGIN 
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
	END 

	------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Update the Item Stock UOM table for lot items in favor of the weight UOM. But this one converts the weight into the stock unit. 
	------------------------------------------------------------------------------------------------------------------------------------------------------------
	BEGIN 
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
	END 
END 