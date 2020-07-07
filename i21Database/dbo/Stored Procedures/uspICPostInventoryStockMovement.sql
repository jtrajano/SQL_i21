CREATE PROCEDURE [dbo].[uspICPostInventoryStockMovement]
	@InventoryTransactionId INT = NULL
	,@InventoryTransactionStorageId INT = NULL
	,@InventoryStockMovementId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryStockMovementId = NULL

DECLARE @Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2

MERGE INTO tblICInventoryStockMovement
WITH (HOLDLOCK)
AS	stockMovement
USING (
	SELECT	t.*
			,i.intCommodityId
			,il.intLocationId 
	FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
				ON t.intItemId = i.intItemId
			INNER JOIN tblICItemLocation il
				ON il.intItemLocationId = t.intItemLocationId 
	WHERE	t.intInventoryTransactionId = @InventoryTransactionId	
			AND @InventoryTransactionId IS NOT NULL 
			AND t.intInTransitSourceLocationId IS NULL 
			AND t.dblQty <> 0
) t
	ON stockMovement.strTransactionId = t.strTransactionId
	AND stockMovement.intTransactionId = t.intTransactionId
	AND stockMovement.intTransactionDetailId = t.intTransactionDetailId
	AND stockMovement.strBatchId = t.strBatchId
	AND stockMovement.intItemId = t.intItemId
	AND stockMovement.intItemLocationId = t.intItemLocationId
	AND stockMovement.intItemUOMId = t.intItemUOMId
	AND ISNULL(stockMovement.intLotId, 0) = ISNULL(t.intLotId, 0)
	AND ISNULL(stockMovement.intSubLocationId, 0) = ISNULL(t.intSubLocationId, 0)
	AND ISNULL(stockMovement.intStorageLocationId, 0) = ISNULL(t.intStorageLocationId, 0)
	AND stockMovement.intOwnershipType = @Ownership_Own

-- If matched, update only the Qty
WHEN MATCHED THEN 
	UPDATE 
	SET		dblQty += ISNULL(t.dblQty, 0)
			,@InventoryStockMovementId = stockMovement.intInventoryStockMovementId

-- If none found, insert a new stock movement record. 
WHEN NOT MATCHED THEN 
	INSERT (
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
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
		,intTransactionItemUOMId
	) VALUES (
		t.intItemId
		,t.intItemLocationId
		,t.intItemUOMId
		,t.intSubLocationId
		,t.intStorageLocationId
		,t.intLotId
		,dbo.fnRemoveTimeOnDate(t.dtmDate)
		,t.dblQty
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
		,NULL -- intInventoryTransactionStorageId
		,@Ownership_Own	 -- intOwnershipType	
		,t.intCommodityId
		,t.intCategoryId
		,t.intLocationId 
		,t.intSourceEntityId
		,t.intTransactionItemUOMId
	)
;
-- Get the stock movement id. 
IF @InventoryStockMovementId IS NULL 
BEGIN 
	SELECT @InventoryStockMovementId = SCOPE_IDENTITY();	
END 

IF @InventoryStockMovementId IS NOT NULL 
	RETURN 

MERGE INTO tblICInventoryStockMovement
WITH (HOLDLOCK)
AS	stockMovement
USING (
	SELECT	s.*
			,i.intCommodityId
			,i.intCategoryId
			,il.intLocationId
	FROM	tblICInventoryTransactionStorage s INNER JOIN tblICItem i
				ON s.intItemId = i.intItemId 
			INNER JOIN tblICItemLocation il
				ON il.intItemLocationId = s.intItemLocationId 
	WHERE	s.intInventoryTransactionStorageId = @InventoryTransactionStorageId	
			AND @InventoryTransactionStorageId IS NOT NULL 
			AND s.dblQty <> 0
) s
	ON stockMovement.strTransactionId = s.strTransactionId
	AND stockMovement.intTransactionId = s.intTransactionId
	AND stockMovement.intTransactionDetailId = s.intTransactionDetailId
	AND stockMovement.strBatchId = s.strBatchId
	AND stockMovement.intItemId = s.intItemId
	AND stockMovement.intItemLocationId = s.intItemLocationId
	AND stockMovement.intItemUOMId = s.intItemUOMId
	AND ISNULL(stockMovement.intLotId, 0) = ISNULL(s.intLotId, 0)
	AND ISNULL(stockMovement.intSubLocationId, 0) = ISNULL(s.intSubLocationId, 0)
	AND ISNULL(stockMovement.intStorageLocationId, 0) = ISNULL(s.intStorageLocationId, 0)
	AND stockMovement.intOwnershipType = @Ownership_Storage

-- If matched, update only the Qty
WHEN MATCHED THEN 
	UPDATE 
	SET		dblQty += ISNULL(s.dblQty, 0)
			,@InventoryStockMovementId = stockMovement.intInventoryStockMovementId

-- If none found, insert a new stock movement record. 
WHEN NOT MATCHED THEN 
	INSERT (
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
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
		,intTransactionItemUOMId
	) VALUES (
		s.intItemId
		,s.intItemLocationId
		,s.intItemUOMId
		,s.intSubLocationId
		,s.intStorageLocationId
		,s.intLotId
		,dbo.fnRemoveTimeOnDate(s.dtmDate)
		,s.dblQty
		,s.dblUOMQty
		,s.dblCost
		,s.dblValue
		,s.dblSalesPrice
		,s.intCurrencyId
		,s.dblExchangeRate
		,s.intTransactionId
		,s.intTransactionDetailId
		,s.strTransactionId
		,s.strBatchId
		,s.intTransactionTypeId
		,s.ysnIsUnposted
		,s.strTransactionForm
		,s.intRelatedInventoryTransactionId
		,s.intRelatedTransactionId
		,s.strRelatedTransactionId
		,s.intCostingMethod
		,s.dtmCreated
		,s.intCreatedUserId
		,s.intCreatedEntityId
		,s.intConcurrencyId
		,s.intForexRateTypeId
		,s.dblForexRate
		,NULL -- intInventoryTransactionId
		,s.intInventoryTransactionStorageId 
		,@Ownership_Storage -- intOwnershipType
		,s.intCommodityId
		,s.intCategoryId
		,s.intLocationId
		,s.intSourceEntityId
		,s.intTransactionItemUOMId
	)
;

-- Get the stock movement id. 
IF @InventoryStockMovementId IS NULL 
BEGIN 
	SELECT @InventoryStockMovementId = SCOPE_IDENTITY();
END 
;