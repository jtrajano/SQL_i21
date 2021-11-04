CREATE PROCEDURE [dbo].[uspICFixStorageQty]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

UPDATE tblICItemStock
SET dblUnitStorage = 0

UPDATE tblICItemStockUOM
SET dblUnitStorage = 0 

-----------------------------------
-- Update the Item Stock table
-----------------------------------
BEGIN 
	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
		SELECT	
			ItemTransactionStorage.intItemId
			,stockUOM.intItemUOMId
			,ItemTransactionStorage.intItemLocationId
			,Qty = SUM(
					dbo.fnCalculateQtyBetweenUOM(
						ItemTransactionStorage.intItemUOMId
						,stockUOM.intItemUOMId 
						,ItemTransactionStorage.dblQty	
					)				
				)
		FROM 
			tblICInventoryTransactionStorage ItemTransactionStorage 
			INNER JOIN tblICItemUOM ItemUOM
				ON ItemTransactionStorage.intItemUOMId = ItemUOM.intItemUOMId
			CROSS APPLY (
				SELECT TOP 1 
					stockUOM.intItemUOMId
				FROM 
					tblICItemUOM stockUOM
				WHERE
					stockUOM.intItemId = ItemTransactionStorage.intItemId
					AND stockUOM.ysnStockUnit = 1
			) stockUOM
				
		GROUP BY 
			ItemTransactionStorage.intItemId
			,stockUOM.intItemUOMId
			,ItemTransactionStorage.intItemLocationId
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblUnitStorage = ISNULL(ItemStock.dblUnitStorage, 0) + StockToUpdate.Qty

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblUnitStorage
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
			,StockToUpdate.Qty -- dblUnitStorage
			,0 
			,0
			,0
			,0
			,NULL 
			,1	
		)
	;
END	

BEGIN 
	BEGIN 
		MERGE INTO dbo.tblICItemStockUOM 
		WITH (HOLDLOCK) 
		AS ItemStockUOM	
		USING (
				SELECT	ItemTransactionStorage.intItemId
						,ItemTransactionStorage.intItemUOMId
						,ItemTransactionStorage.intItemLocationId
						,ItemTransactionStorage.intSubLocationId
						,ItemTransactionStorage.intStorageLocationId
						,Qty = SUM(
								dbo.fnCalculateQtyBetweenUOM(
									ItemTransactionStorage.intItemUOMId
									,stockUOM.intItemUOMId 
									,ItemTransactionStorage.dblQty	
								)				
							)
				FROM 
					tblICInventoryTransactionStorage ItemTransactionStorage 
					INNER JOIN tblICItemUOM ItemUOM
						ON ItemTransactionStorage.intItemUOMId = ItemUOM.intItemUOMId
					OUTER APPLY (
						SELECT TOP 1 
							stockUOM.intItemUOMId
						FROM 
							tblICItemUOM stockUOM
						WHERE
							stockUOM.intItemId = ItemTransactionStorage.intItemId
							AND stockUOM.ysnStockUnit = 1
					) stockUOM
				WHERE 
					ItemTransactionStorage.intLotId IS NULL 
				GROUP BY 
					ItemTransactionStorage.intItemId
					,ItemTransactionStorage.intItemUOMId
					,ItemTransactionStorage.intItemLocationId
					,ItemTransactionStorage.intSubLocationId
					,ItemTransactionStorage.intStorageLocationId
		) AS RawStockData
			ON ItemStockUOM.intItemId = RawStockData.intItemId
				AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
				AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
				AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
				AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

		WHEN MATCHED THEN 
		UPDATE 
		SET	dblUnitStorage = ISNULL(ItemStockUOM.dblUnitStorage, 0) + ROUND(RawStockData.Qty, 6)

		WHEN NOT MATCHED 
			AND RawStockData.intItemUOMId IS NOT NULL 
		THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dblUnitStorage
				,intConcurrencyId
			)
			VALUES (
				RawStockData.intItemId
				,RawStockData.intItemLocationId
				,RawStockData.intItemUOMId
				,RawStockData.intSubLocationId
				,RawStockData.intStorageLocationId
				,ROUND(RawStockData.Qty, 6) 
				,1	
			);
	END 

	BEGIN 
		MERGE INTO dbo.tblICItemStockUOM
		WITH (HOLDLOCK) 
		AS ItemStockUOM	
		USING (
				SELECT	ItemTransactionStorage.intItemId
						,intItemUOMId = dbo.fnGetItemStockUOM(ItemTransactionStorage.intItemId) 
						,ItemTransactionStorage.intItemLocationId
						,ItemTransactionStorage.intSubLocationId
						,ItemTransactionStorage.intStorageLocationId
						,Qty = SUM(dbo.fnCalculateStockUnitQty(ItemTransactionStorage.dblQty, ItemTransactionStorage.dblUOMQty))
				FROM	dbo.tblICInventoryTransactionStorage ItemTransactionStorage 
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemTransactionStorage.intItemUOMId = ItemUOM.intItemUOMId
						AND ISNULL(ItemUOM.ysnStockUnit, 0) = 0 
				WHERE ItemTransactionStorage.intLotId IS NULL 
				GROUP BY ItemTransactionStorage.intItemId
					,dbo.fnGetItemStockUOM(ItemTransactionStorage.intItemId)
					,ItemTransactionStorage.intItemLocationId
					,ItemTransactionStorage.intSubLocationId
					,ItemTransactionStorage.intStorageLocationId
		) AS RawStockData
			ON ItemStockUOM.intItemId = RawStockData.intItemId
				AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
				AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
				AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
				AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

		WHEN MATCHED THEN 
		UPDATE 
		SET	dblUnitStorage = ISNULL(ItemStockUOM.dblUnitStorage, 0) + ROUND(RawStockData.Qty, 6)

		WHEN NOT MATCHED 
			AND RawStockData.intItemUOMId IS NOT NULL 
		THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dblUnitStorage
				,intConcurrencyId
			)
			VALUES (
				RawStockData.intItemId
				,RawStockData.intItemLocationId
				,RawStockData.intItemUOMId
				,RawStockData.intSubLocationId
				,RawStockData.intStorageLocationId
				,ROUND(RawStockData.Qty, 6)
				,1	
			);
	END 
END 