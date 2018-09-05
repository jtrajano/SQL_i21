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
WHERE	t.intInventoryTransactionId = @InventoryTransactionId	
		AND @InventoryTransactionId IS NOT NULL 
		AND t.intInTransitSourceLocationId IS NULL 
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
WHERE	t.intInventoryTransactionStorageId = @InventoryTransactionStorageId	
		AND @InventoryTransactionStorageId IS NOT NULL 
		AND t.dblQty <> 0

SET @InventoryStockMovementId = SCOPE_IDENTITY();
