CREATE PROCEDURE [dbo].[uspICFixStorageQty]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE tblICItemStock
SET dblUnitStorage = 0

UPDATE tblICItemStockUOM
SET dblUnitStorage = 0 

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
						,Qty = SUM(ItemTransactionStorage.dblQty)
				FROM dbo.tblICInventoryTransactionStorage ItemTransactionStorage 
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemTransactionStorage.intItemUOMId = ItemUOM.intItemUOMId
				WHERE ItemTransactionStorage.intLotId IS NULL 
				GROUP BY ItemTransactionStorage.intItemId
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