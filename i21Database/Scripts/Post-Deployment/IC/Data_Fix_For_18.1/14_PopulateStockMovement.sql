PRINT N'BEGIN - IC Data Fix for 18.1. #14'
GO

IF (
	EXISTS (SELECT 1 FROM (SELECT TOP 1 dblVersion = CAST(LEFT(strVersionNo, 4) AS NUMERIC(18,1)) FROM tblSMBuildNumber ORDER BY intVersionID DESC) v WHERE v.dblVersion <= 18.1)
	AND NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryStockMovement)
)
BEGIN 
	DECLARE @Ownership_Own AS INT = 1
			,@Ownership_Storage AS INT = 2

	INSERT INTO dbo.tblICInventoryStockMovement (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
	)
	SELECT *
	FROM (
		SELECT	
				t.intItemId
				,t.intItemLocationId
				,t.intItemUOMId
				,t.intSubLocationId
				,t.intStorageLocationId
				,t.intLotId
				,t.dtmDate
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
				,intOwnershipType = @Ownership_Own 
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
					FROM tblICInventoryTransaction t
					WHERE	
						t.intInTransitSourceLocationId IS NULL 
						AND t.dblQty <> 0				
						AND ISNULL(t.ysnIsUnposted, 0) = 0
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
					SELECT	TOP 1 *
					FROM	tblICInventoryTransaction t
					WHERE	
						t.strTransactionId = groupedQty.strTransactionId
						AND t.intTransactionId = groupedQty.intTransactionId
						AND t.intTransactionDetailId = groupedQty.intTransactionDetailId
						AND t.strBatchId = groupedQty.strBatchId
						AND t.intItemId = groupedQty.intItemId
						AND t.intItemLocationId = groupedQty.intItemLocationId
						AND t.intItemUOMId = groupedQty.intItemUOMId
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
				,t.dtmDate
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
				,intOwnershipType = @Ownership_Storage 
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
					FROM tblICInventoryTransactionStorage t
					WHERE	
						t.dblQty <> 0				
						AND ISNULL(t.ysnIsUnposted, 0) = 0
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
					SELECT	TOP 1 *
					FROM	tblICInventoryTransactionStorage t
					WHERE	
						t.strTransactionId = groupedQty.strTransactionId
						AND t.intTransactionId = groupedQty.intTransactionId
						AND t.intTransactionDetailId = groupedQty.intTransactionDetailId
						AND t.strBatchId = groupedQty.strBatchId
						AND t.intItemId = groupedQty.intItemId
						AND t.intItemLocationId = groupedQty.intItemLocationId
						AND t.intItemUOMId = groupedQty.intItemUOMId
						AND ISNULL(t.intLotId, 0) = ISNULL(groupedQty.intLotId, 0) 
						AND ISNULL(t.intSubLocationId, 0) = ISNULL(groupedQty.intSubLocationId, 0) 
						AND ISNULL(t.intStorageLocationId, 0) = ISNULL(groupedQty.intStorageLocationId, 0) 
				) t
		) x
	ORDER BY 
		CAST(REPLACE(x.strBatchId, 'BATCH-', '') AS INT) ASC 
		,dtmCreated ASC 
		,ISNULL(intInventoryTransactionId, intInventoryTransactionStorageId) ASC 
END 

GO

PRINT N'END - IC Data Fix for 18.1. #14'