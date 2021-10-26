CREATE PROCEDURE [dbo].[uspICPostStockDailyQuantity]
	@intInventoryTransactionId AS INT = NULL 
	,@strBatchId AS NVARCHAR(50) = NULL 
	,@strTransactionId AS NVARCHAR(50) = NULL 
	,@ysnRebuild AS BIT = 0 
AS

-----------------------------------
-- Rebuild the Daily Quantity
-----------------------------------
IF @ysnRebuild = 1 
BEGIN 
	TRUNCATE TABLE tblICInventoryDailyTransaction;

	MERGE	
	INTO	dbo.tblICInventoryDailyTransaction 
	WITH	(HOLDLOCK) 
	AS		DailyTransaction	
	USING (
			SELECT	
				[intItemId] 
				,[intItemLocationId] 
				,[intInTransitSourceLocationId] 
				,[intCompanyLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intCompanyId] 
				,[dtmDate] 
				,[dblQty] = SUM(dblQty) 
				,[dblValue] = SUM(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0))
				,[dblValueRounded] = SUM(ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2))
			FROM 
				tblICInventoryTransaction t 				
			GROUP BY
				[intItemId] 
				,[intItemLocationId] 
				,[intInTransitSourceLocationId] 
				,[intCompanyLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intCompanyId] 
				,[dtmDate] 
	) AS StockToUpdate
		ON 
			DailyTransaction.[intItemId] = StockToUpdate.intItemId 
			AND DailyTransaction.[intItemLocationId] = StockToUpdate.intItemLocationId 
			AND DailyTransaction.[intInTransitSourceLocationId] = StockToUpdate.intInTransitSourceLocationId 
			AND DailyTransaction.[intCompanyLocationId] = StockToUpdate.intCompanyLocationId
			AND DailyTransaction.[intSubLocationId] = StockToUpdate.intSubLocationId 
			AND DailyTransaction.[intStorageLocationId] = StockToUpdate.intStorageLocationId 
			AND DailyTransaction.[intItemUOMId] = StockToUpdate.intItemUOMId 
			AND DailyTransaction.[intCompanyId] = StockToUpdate.intCompanyId 
			AND DailyTransaction.[dtmDate] = StockToUpdate.dtmDate 

	-- If matched, update daily qty and value
	WHEN MATCHED THEN 
		UPDATE 
		SET		
			DailyTransaction.dblQty = ISNULL(DailyTransaction.dblQty, 0) + ISNULL(StockToUpdate.dblQty, 0)
			,DailyTransaction.dblValue = ISNULL(DailyTransaction.dblValue, 0) + ISNULL(StockToUpdate.dblValue, 0)
			,DailyTransaction.dblValueRounded = ISNULL(DailyTransaction.dblValueRounded, 0) + ISNULL(StockToUpdate.dblValueRounded, 0)

	-- If none found, insert a new record
	WHEN NOT MATCHED THEN 
		INSERT (
			[intItemId]
			,[intItemLocationId] 
			,[intInTransitSourceLocationId] 
			,[intCompanyLocationId]
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intCompanyId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblValue] 
			,[dblValueRounded]
		)
		VALUES (
			StockToUpdate.[intItemId]
			,StockToUpdate.[intItemLocationId] 
			,StockToUpdate.[intInTransitSourceLocationId] 
			,StockToUpdate.[intCompanyLocationId]
			,StockToUpdate.[intSubLocationId] 
			,StockToUpdate.[intStorageLocationId] 
			,StockToUpdate.[intItemUOMId] 
			,StockToUpdate.[intCompanyId] 
			,StockToUpdate.[dtmDate] 
			,StockToUpdate.[dblQty] 
			,StockToUpdate.[dblValue] 
			,StockToUpdate.[dblValueRounded] 
		)
	;
END
ELSE 
BEGIN 
	MERGE	
	INTO	dbo.tblICInventoryDailyTransaction 
	WITH	(HOLDLOCK) 
	AS		DailyTransaction	
	USING (
			SELECT	
				[intItemId] 
				,[intItemLocationId] 
				,[intInTransitSourceLocationId] 
				,[intCompanyLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intCompanyId] 
				,[dtmDate] 
				,[dblQty] = SUM(dblQty) 
				,[dblValue] = SUM(ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2))
				,[dblValueRounded] = SUM(ROUND(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0), 2))
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.intInventoryTransactionId = @intInventoryTransactionId			
				OR (
					t.strBatchId = @strBatchId
					AND t.strTransactionId = @strTransactionId 
				)
			GROUP BY
				[intItemId] 
				,[intItemLocationId] 
				,[intInTransitSourceLocationId] 
				,[intCompanyLocationId]
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[intItemUOMId] 
				,[intCompanyId] 
				,[dtmDate] 
	) AS StockToUpdate
		ON 
			DailyTransaction.[intItemId] = StockToUpdate.intItemId 
			AND DailyTransaction.[intItemLocationId] = StockToUpdate.intItemLocationId 
			AND DailyTransaction.[intInTransitSourceLocationId] = StockToUpdate.intInTransitSourceLocationId 
			AND DailyTransaction.[intCompanyLocationId] = StockToUpdate.intCompanyLocationId 
			AND DailyTransaction.[intSubLocationId] = StockToUpdate.intSubLocationId 
			AND DailyTransaction.[intStorageLocationId] = StockToUpdate.intStorageLocationId 
			AND DailyTransaction.[intItemUOMId] = StockToUpdate.intItemUOMId 
			AND DailyTransaction.[intCompanyId] = StockToUpdate.intCompanyId 
			AND DailyTransaction.[dtmDate] = StockToUpdate.dtmDate 

	-- If matched, update daily qty and value
	WHEN MATCHED THEN 
		UPDATE 
		SET		
			DailyTransaction.dblQty = ISNULL(DailyTransaction.dblQty, 0) + ISNULL(StockToUpdate.dblQty, 0)
			,DailyTransaction.dblValue = ISNULL(DailyTransaction.dblValue, 0) + ISNULL(StockToUpdate.dblValue, 0)
			,DailyTransaction.dblValueRounded = ISNULL(DailyTransaction.dblValueRounded, 0) + ISNULL(StockToUpdate.dblValueRounded, 0)

	-- If none found, insert a new record
	WHEN NOT MATCHED THEN 
		INSERT (
			[intItemId]
			,[intItemLocationId] 
			,[intInTransitSourceLocationId] 
			,[intCompanyLocationId]
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[intItemUOMId] 
			,[intCompanyId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblValue] 
			,[dblValueRounded]
		)
		VALUES (
			StockToUpdate.[intItemId]
			,StockToUpdate.[intItemLocationId] 
			,StockToUpdate.[intInTransitSourceLocationId] 
			,StockToUpdate.[intCompanyLocationId]
			,StockToUpdate.[intSubLocationId] 
			,StockToUpdate.[intStorageLocationId] 
			,StockToUpdate.[intItemUOMId] 
			,StockToUpdate.[intCompanyId] 
			,StockToUpdate.[dtmDate] 
			,StockToUpdate.[dblQty] 
			,StockToUpdate.[dblValue] 
			,StockToUpdate.[dblValueRounded] 
		)
	;
END 

RETURN 0
