CREATE PROCEDURE [dbo].[uspICRebuildStockMovement]
	@dtmStartDate AS DATETIME = NULL 
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intReturnValue AS INT = 0; 
DECLARE @Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2

IF @strItemNo IS NULL AND @dtmStartDate IS NULL 
BEGIN 
	TRUNCATE TABLE tblICInventoryStockMovement
END 
ELSE 
BEGIN
	DELETE	m
	FROM	tblICInventoryStockMovement m INNER JOIN tblICItem i
				ON m.intItemId = i.intItemId
	WHERE	(
				@strItemNo IS NULL 
				OR i.strItemNo = @strItemNo
			)
			AND (
				@dtmStartDate IS NULL 
				OR dbo.fnDateGreaterThanEquals(m.dtmDate, @dtmStartDate) = 1
			)
END

IF @isPeriodic = 1
BEGIN 	
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
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
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
				,intOwnershipType = @Ownership_Own 
				,t.intItemCommodityId
				,t.intItemCategoryId
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
						AND (
							@strItemNo IS NULL 
							OR i.strItemNo = @strItemNo
						)
						AND (
							@dtmStartDate IS NULL 
							OR dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmStartDate) = 1
						)
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
							,intItemCommodityId = i.intCommodityId
							,intItemCategoryId = i.intCategoryId
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
				,intOwnershipType = @Ownership_Storage 
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
						AND (
							@strItemNo IS NULL 
							OR i.strItemNo = @strItemNo
						)
						AND (
							@dtmStartDate IS NULL 
							OR dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmStartDate) = 1
						)
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
		) x
	ORDER BY 
		x.dtmDate ASC 
		,CAST(REPLACE(x.strBatchId, 'BATCH-', '') AS INT) ASC 
		,x.dblQty DESC 
		,ISNULL(intInventoryTransactionId, intInventoryTransactionStorageId) ASC 
END

ELSE IF @isPeriodic = 0
BEGIN 	
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
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
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
				,intOwnershipType = @Ownership_Own 
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
					FROM tblICInventoryTransaction t INNER JOIN tblICItem i 
							ON t.intItemId = i.intItemId 
					WHERE	
						t.intInTransitSourceLocationId IS NULL 
						AND t.dblQty <> 0
						AND (
							@strItemNo IS NULL 
							OR i.strItemNo = @strItemNo
						)
						AND (
							@dtmStartDate IS NULL 
							OR dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmStartDate) = 1
						)
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
					SELECT TOP 1 
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
				,intOwnershipType = @Ownership_Storage 
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
						AND (
							@strItemNo IS NULL 
							OR i.strItemNo = @strItemNo
						)
						AND (
							@dtmStartDate IS NULL 
							OR dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmStartDate) = 1
						)
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
		) x
	ORDER BY 
		x.dtmCreated ASC 
END