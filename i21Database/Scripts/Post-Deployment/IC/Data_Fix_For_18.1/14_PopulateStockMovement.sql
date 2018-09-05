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
			,intInventoryTransactionStorageId = NULL 
			,intOwnershipType = @Ownership_Own
		FROM	tblICInventoryTransaction t
		WHERE	t.intInTransitSourceLocationId IS NULL 
				AND t.dblQty <> 0

		UNION ALL 
		SELECT	
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
			,intInventoryTransactionId = NULL 
			,intInventoryTransactionStorageId 
			,intOwnershipType = @Ownership_Storage
		FROM	tblICInventoryTransactionStorage t
		WHERE	t.dblQty <> 0
	) x
	ORDER BY 
		CAST(REPLACE(x.strBatchId, 'BATCH-', '') AS INT) ASC 
		,dtmCreated ASC 
		,ISNULL(intInventoryTransactionId, intInventoryTransactionStorageId) ASC 
END 

GO

PRINT N'END - IC Data Fix for 18.1. #14'