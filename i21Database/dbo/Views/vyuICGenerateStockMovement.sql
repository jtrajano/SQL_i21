CREATE VIEW [dbo].[vyuICGenerateStockMovement]
AS

SELECT *
	FROM (
		SELECT	
				i.intItemId
				,t.intItemLocationId
				,t.intItemUOMId
				,t.intSubLocationId
				,t.intStorageLocationId
				,t.intLotId
				,dtmDate = dbo.fnRemoveTimeOnDate(t.dtmDate)
				,groupedQty.dblQty
				,t.dblUOMQty
				,t.dblCost
				,t.dblValue
				,t.dblSalesPrice
				,t.intCurrencyId
				,t.dblExchangeRate
				,t.intTransactionId
				,t.intTransactionDetailId
				,t.strTransactionId
				,t.strBatchId
				,t.intTransactionTypeId
				,t.ysnIsUnposted
				,t.strTransactionForm
				,t.intRelatedInventoryTransactionId
				,t.intRelatedTransactionId
				,t.strRelatedTransactionId
				,t.intCostingMethod
				,t.dtmCreated
				,t.intCreatedUserId
				,t.intCreatedEntityId
				,t.intConcurrencyId
				,t.intForexRateTypeId
				,t.dblForexRate
				,t.intInventoryTransactionId
				,intInventoryTransactionStorageId = CAST(NULL AS INT)
				,intOwnershipType = 1 
				,t.intCommodityId
				,t.intCategoryId
				,t.intLocationId 
				,t.intSourceEntityId
		FROM	tblICItem i
				LEFT JOIN (
					SELECT	
						dblQty = SUM(t.dblQty)
						,t.strTransactionId
						,t.intTransactionId
						,t.intTransactionDetailId
						,t.strBatchId
						,t.intItemId
						,t.intItemLocationId
						,t.intItemUOMId
						,t.intLotId 
						,t.intSubLocationId
						,t.intStorageLocationId
					FROM 
						tblICInventoryTransaction t INNER JOIN tblICItem i 
							ON t.intItemId = i.intItemId 
					WHERE	
						t.intInTransitSourceLocationId IS NULL 
						AND t.dblQty <> 0
					GROUP BY 
						t.strTransactionId
						,t.intTransactionId
						,t.intTransactionDetailId
						,t.strBatchId
						,t.intItemId
						,t.intItemLocationId
						,t.intItemUOMId
						,t.intLotId 
						,t.intSubLocationId
						,t.intStorageLocationId				
				) groupedQty
					ON i.intItemId = groupedQty.intItemId
				OUTER APPLY (
					SELECT	TOP 1 
							t.*
							,il.intLocationId
							,i.intCommodityId
					FROM	
						tblICInventoryTransaction t INNER JOIN tblICItem i 
								ON t.intItemId = i.intItemId
						INNER JOIN tblICItemLocation il
							ON t.intItemLocationId = il.intItemLocationId
					WHERE	
						t.strTransactionId = groupedQty.strTransactionId
						AND t.intTransactionId = groupedQty.intTransactionId
						AND t.intTransactionDetailId = groupedQty.intTransactionDetailId
						AND t.strBatchId = groupedQty.strBatchId
						AND t.intItemId = groupedQty.intItemId
						AND t.intItemLocationId = groupedQty.intItemLocationId
						AND t.intItemUOMId = groupedQty.intItemUOMId
						AND t.dblQty <> 0
						AND ISNULL(t.intLotId, 0) = ISNULL(groupedQty.intLotId, 0) 
						AND ISNULL(t.intSubLocationId, 0) = ISNULL(groupedQty.intSubLocationId, 0) 
						AND ISNULL(t.intStorageLocationId, 0) = ISNULL(groupedQty.intStorageLocationId, 0) 
				) t
		UNION ALL 
		SELECT	
				t.intItemId
				,t.intItemLocationId
				,t.intItemUOMId
				,t.intSubLocationId
				,t.intStorageLocationId
				,t.intLotId
				,dtmDate = dbo.fnRemoveTimeOnDate(t.dtmDate) 
				,groupedQty.dblQty
				,t.dblUOMQty
				,t.dblCost
				,t.dblValue
				,t.dblSalesPrice
				,t.intCurrencyId
				,t.dblExchangeRate
				,t.intTransactionId
				,t.intTransactionDetailId
				,t.strTransactionId
				,t.strBatchId
				,t.intTransactionTypeId
				,t.ysnIsUnposted
				,t.strTransactionForm
				,t.intRelatedInventoryTransactionId
				,t.intRelatedTransactionId
				,t.strRelatedTransactionId
				,t.intCostingMethod
				,t.dtmCreated
				,t.intCreatedUserId
				,t.intCreatedEntityId
				,t.intConcurrencyId
				,t.intForexRateTypeId
				,t.dblForexRate
				,intInventoryTransactionId = CAST(NULL AS INT) 
				,t.intInventoryTransactionStorageId 
				,intOwnershipType = 2 
				,t.intCommodityId
				,t.intCategoryId
				,t.intLocationId 
				,t.intSourceEntityId
		FROM	(
					SELECT	
						dblQty = SUM(t.dblQty)
						,t.strTransactionId
						,t.intTransactionId
						,t.intTransactionDetailId
						,t.strBatchId
						,t.intItemId
						,t.intItemLocationId
						,t.intItemUOMId
						,t.intLotId 
						,t.intSubLocationId
						,t.intStorageLocationId				
					FROM tblICInventoryTransactionStorage t INNER JOIN tblICItem i 
							ON t.intItemId = i.intItemId 
					WHERE	
						t.dblQty <> 0
					GROUP BY 
						t.strTransactionId
						,t.intTransactionId
						,t.intTransactionDetailId
						,t.strBatchId
						,t.intItemId
						,t.intItemLocationId
						,t.intItemUOMId
						,t.intLotId 
						,t.intSubLocationId
						,t.intStorageLocationId				
				) groupedQty
				CROSS APPLY (
					SELECT	TOP 1 
							t.*
							,il.intLocationId
							,i.intCommodityId
							,i.intCategoryId
					FROM	
						tblICInventoryTransactionStorage t INNER JOIN tblICItem i 
							ON t.intItemId = i.intItemId
						INNER JOIN tblICItemLocation il
							ON t.intItemLocationId = il.intItemLocationId
					WHERE	
						t.strTransactionId = groupedQty.strTransactionId
						AND t.intTransactionId = groupedQty.intTransactionId
						AND t.intTransactionDetailId = groupedQty.intTransactionDetailId
						AND t.strBatchId = groupedQty.strBatchId
						AND t.intItemId = groupedQty.intItemId
						AND t.intItemLocationId = groupedQty.intItemLocationId
						AND t.intItemUOMId = groupedQty.intItemUOMId
						AND t.dblQty <> 0
						AND ISNULL(t.intLotId, 0) = ISNULL(groupedQty.intLotId, 0) 
						AND ISNULL(t.intSubLocationId, 0) = ISNULL(groupedQty.intSubLocationId, 0) 
						AND ISNULL(t.intStorageLocationId, 0) = ISNULL(groupedQty.intStorageLocationId, 0) 
				) t
	) combinedQuery