
/*
	This is the stored procedure that handles the adjust to the item's cost. 	
*/
CREATE PROCEDURE [dbo].[uspICUnpostCostAdjustment]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(20)
	,@intUserId AS INT
	,@ysnRecap AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the cost types
DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
		,@COST_ADJ_TYPE_New_Cost AS INT = 2

-- Create the variables for the internal transaction types used by costing. 
DECLARE @REVALUE_SOLD AS INT = 3
		,@COST_ADJUSTMENT AS INT = 22

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvCostAdjustmentToReverse')) 
BEGIN 
	CREATE TABLE #tmpInvCostAdjustmentToReverse (
		intInventoryTransactionId INT NOT NULL 
		,intTransactionId INT NULL 
		,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intRelatedTransactionId INT NULL 
		,intTransactionTypeId INT NOT NULL 
	)
END 

-- Get all the inventory transaction related to the Unpost. 
-- While at it, update the ysnIsUnposted to true. 
-- Then grab the updated records and store it in #tmpInvCostAdjustmentToReverse 
INSERT INTO #tmpInvCostAdjustmentToReverse (
	intInventoryTransactionId
	,intTransactionId
	,strTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,intTransactionTypeId
)
SELECT	Changes.intInventoryTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
FROM	(
			-- Merge will help us get the records we need to unpost and update it at the same time. 
			MERGE	
				INTO	dbo.tblICInventoryTransaction 
				WITH	(HOLDLOCK) 
				AS		inventory_transaction	
				USING (
					SELECT	strTransactionId = @strTransactionId
							,intTransactionId = @intTransactionId
				) AS Source_Query  
					ON ISNULL(inventory_transaction.ysnIsUnposted, 0) = 0					
					AND inventory_transaction.intTransactionTypeId IN (@COST_ADJUSTMENT, @REVALUE_SOLD)
					AND 1 = 
						CASE	WHEN inventory_transaction.strTransactionId = Source_Query.strTransactionId AND inventory_transaction.intTransactionId = Source_Query.intTransactionId THEN 1
								WHEN inventory_transaction.strRelatedTransactionId = Source_Query.strTransactionId AND inventory_transaction.intRelatedTransactionId = Source_Query.intTransactionId THEN	1
								ELSE 0
						END 					

				-- If matched, update the ysnIsUnposted and set it to true (1) 
				WHEN MATCHED THEN 
					UPDATE 
					SET		ysnIsUnposted = 1

				OUTPUT $action, Inserted.intInventoryTransactionId, Inserted.intTransactionId, Inserted.strTransactionId, Inserted.intRelatedTransactionId, Inserted.strRelatedTransactionId, Inserted.intTransactionTypeId
		) AS Changes (Action, intInventoryTransactionId, intTransactionId, strTransactionId, intRelatedTransactionId, strRelatedTransactionId, intTransactionTypeId)
WHERE	Changes.Action = 'UPDATE'
;

IF EXISTS (SELECT TOP 1 1 FROM #tmpInvCostAdjustmentToReverse) 
BEGIN 

	-------------------------------------------------
	-- Update the cost buckets. Reverse the cost. 
	-------------------------------------------------
	BEGIN 
		DECLARE @CostBucketIntTransactionId AS INT
				,@CostBucketStrTransactionId AS NVARCHAR(50)
				,@CostAdjQty AS NUMERIC(18,6)
				,@CostAdjNewCost AS NUMERIC(38,20)
				,@CostBucketId AS INT 

				,@CostBucketCost AS NUMERIC(38,20)
				,@OriginalCost AS NUMERIC(38,20)
				,@NewTransactionValue AS NUMERIC(38,20)
				,@OriginalTransactionValue AS NUMERIC(38,20)
				,@dblNewCalculatedCost AS NUMERIC(38,20)
				,@CostBucketStockInQty AS NUMERIC(18,6)
				

		DECLARE loopCostBucket CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  intTransactionId
				,strTransactionId
				,CostAdjLog.dblQty
				,CostAdjLog.dblCost
				,CostAdjLog.intInventoryFIFOId
		FROM	#tmpInvCostAdjustmentToReverse InvReverse INNER JOIN dbo.tblICInventoryFIFOCostAdjustmentLog CostAdjLog
					ON InvReverse.intInventoryTransactionId = CostAdjLog.intInventoryTransactionId
		WHERE	CostAdjLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_New_Cost

		OPEN loopCostBucket;

		-- Initial fetch attempt
		FETCH NEXT FROM loopCostBucket INTO 
				@CostBucketIntTransactionId
				,@CostBucketStrTransactionId 
				,@CostAdjQty 
				,@CostAdjNewCost 
				,@CostBucketId 
		;

		-----------------------
		-- Start of the loop
		-----------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN 
			-- Get the original cost
			SELECT TOP 1 
					@OriginalCost = dblCost
			FROM	dbo.tblICInventoryFIFOCostAdjustmentLog
			WHERE	intInventoryFIFOId = @CostBucketId
					AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost

			-- Get the cost at cost bucket. 
			SELECT	@CostBucketCost = dblCost
					,@CostBucketStockInQty = dblStockIn
			FROM	dbo.tblICInventoryFIFO
			WHERE	intInventoryFIFOId = @CostBucketId

			-- Compute the new transaction value. 
			SELECT	@NewTransactionValue = @CostAdjQty * @CostAdjNewCost

			-- Compute the original transaction value. 
			SELECT	@OriginalTransactionValue = @CostAdjQty * @OriginalCost

			-- Compute the new cost. 
			SELECT @dblNewCalculatedCost =	@CostBucketCost 
											- ((@NewTransactionValue - @OriginalTransactionValue) / @CostBucketStockInQty)	

			-- Calculate the new cost
			UPDATE	CostBucket
			SET		dblCost = @dblNewCalculatedCost
			FROM	tblICInventoryFIFO CostBucket
			WHERE	CostBucket.intInventoryFIFOId = @CostBucketId

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopCostBucket INTO 
				@CostBucketIntTransactionId
				,@CostBucketStrTransactionId 
				,@CostAdjQty 
				,@CostAdjNewCost 
				,@CostBucketId
			;
		END 

		CLOSE loopCostBucket;
		DEALLOCATE loopCostBucket;

		-----------------------
		-- End of the loop
		-----------------------
	END 
	
	-------------------------------------------------
	-- Create reversal of the inventory transactions
	-------------------------------------------------
	INSERT INTO dbo.tblICInventoryTransaction (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[strBatchId]
			,[intTransactionTypeId]
			,[intLotId]
			,[ysnIsUnposted]
			,[intRelatedInventoryTransactionId]
			,[intRelatedTransactionId]
			,[strRelatedTransactionId]
			,[strTransactionForm]
			,[dtmCreated]
			,[intCreatedUserId]
			,[intConcurrencyId]
			,[intCostingMethod]
	)			
	SELECT	
			[intItemId]								= ActualTransaction.intItemId
			,[intItemLocationId]					= ActualTransaction.intItemLocationId
			,[intItemUOMId]							= ActualTransaction.intItemUOMId
			,[intSubLocationId]						= ActualTransaction.intSubLocationId
			,[intStorageLocationId]					= ActualTransaction.intStorageLocationId
			,[dtmDate]								= ActualTransaction.dtmDate
			,[dblQty]								= ActualTransaction.dblQty * -1
			,[dblUOMQty]							= ActualTransaction.dblUOMQty
			,[dblCost]								= ActualTransaction.dblCost
			,[dblValue]								= ActualTransaction.dblValue * -1
			,[dblSalesPrice]						= ActualTransaction.dblSalesPrice
			,[intCurrencyId]						= ActualTransaction.intCurrencyId
			,[dblExchangeRate]						= ActualTransaction.dblExchangeRate
			,[intTransactionId]						= ActualTransaction.intTransactionId
			,[intTransactionDetailId]				= ActualTransaction.intTransactionDetailId
			,[strTransactionId]						= ActualTransaction.strTransactionId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= ActualTransaction.intTransactionTypeId
			,[intLotId]								= ActualTransaction.intLotId
			,[ysnIsUnposted]						= 1
			,[intRelatedInventoryTransactionId]		= ItemTransactionsToReverse.intInventoryTransactionId
			,[intRelatedTransactionId]				= ActualTransaction.intRelatedTransactionId
			,[strRelatedTransactionId]				= ActualTransaction.strRelatedTransactionId
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedUserId]						= @intUserId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= ActualTransaction.intCostingMethod
	FROM	#tmpInvCostAdjustmentToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId

	----------------------------------------------------
	-- Create reversal of the inventory LOT transactions
	----------------------------------------------------
	--DECLARE @ActiveLotStatus AS INT = 1
	--INSERT INTO dbo.tblICInventoryLotTransaction (		
	--	[intItemId]
	--	,[intLotId]
	--	,[intLocationId]
	--	,[intItemLocationId]
	--	,[intSubLocationId]
	--	,[intStorageLocationId]
	--	,[dtmDate]
	--	,[dblQty]
	--	,[intItemUOMId]
	--	,[dblCost]
	--	,[intTransactionId]
	--	,[strTransactionId]
	--	,[intTransactionTypeId]
	--	,[strBatchId]
	--	,[intLotStatusId] 
	--	,[strTransactionForm]
	--	,[ysnIsUnposted]
	--	,[dtmCreated] 
	--	,[intCreatedUserId] 
	--	,[intConcurrencyId] 
	--)
	--SELECT	[intItemId]					= ActualTransaction.intItemId
	--		,[intLotId]					= ActualTransaction.intLotId
	--		,[intLocationId]			= ItemLocation.intLocationId
	--		,[intItemLocationId]		= ActualTransaction.intItemLocationId
	--		,[intSubLocationId]			= ActualTransaction.intSubLocationId
	--		,[intStorageLocationId]		= ActualTransaction.intStorageLocationId
	--		,[dtmDate]					= ActualTransaction.dtmDate
	--		,[dblQty]					= ActualTransaction.dblQty * -1
	--		,[intItemUOMId]				= ActualTransaction.intItemUOMId
	--		,[dblCost]					= ActualTransaction.dblCost
	--		,[intTransactionId]			= ActualTransaction.intTransactionId
	--		,[strTransactionId]			= ActualTransaction.strTransactionId
	--		,[intTransactionTypeId]		= ActualTransaction.intTransactionTypeId
	--		,[strBatchId]				= @strBatchId
	--		,[intLotStatusId]			= @ActiveLotStatus 
	--		,[strTransactionForm]		= ActualTransaction.strTransactionForm
	--		,[ysnIsUnposted]			= 1
	--		,[dtmCreated]				= GETDATE()
	--		,[intCreatedUserId]			= @intUserId
	--		,[intConcurrencyId]			= 1
	--FROM	#tmpInvCostAdjustmentToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
	--			ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
	--			AND ActualTransaction.intLotId IS NOT NULL 
	--			AND ActualTransaction.intItemUOMId IS NOT NULL
	--		INNER JOIN tblICItemLocation ItemLocation
	--			ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	RelatedItemTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryTransaction RelatedItemTransactions 
	WHERE	RelatedItemTransactions.intRelatedTransactionId = @intTransactionId
			AND RelatedItemTransactions.strRelatedTransactionId = @strTransactionId
			AND RelatedItemTransactions.ysnIsUnposted = 0

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related LOT transactions 
	--------------------------------------------------------------
	--UPDATE	RelatedLotTransactions
	--SET		ysnIsUnposted = 1
	--FROM	dbo.tblICInventoryLotTransaction RelatedLotTransactions 
	--WHERE	RelatedLotTransactions.intTransactionId = @intTransactionId
	--		AND RelatedLotTransactions.strTransactionId = @strTransactionId
	--		AND RelatedLotTransactions.ysnIsUnposted = 0

	---------------------------------------------------
	-- Calculate the new average cost (if applicable)
	---------------------------------------------------
	BEGIN 
		-- Update the avearge cost at the Item Pricing table
		UPDATE	ItemPricing
		SET		dblAverageCost = CASE		WHEN ISNULL(Stock.dblUnitOnHand, 0) > 0 THEN 
													-- Recalculate the average cost
													dbo.fnRecalculateAverageCost(Stock.intItemId, Stock.intItemLocationId, ItemPricing.dblAverageCost) 
												ELSE 
													-- Use the same average cost. 
													ItemPricing.dblAverageCost
										END
		FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
					ON ItemPricing.intItemId = Stock.intItemId
					AND ItemPricing.intItemLocationId = Stock.intItemLocationId		
				INNER JOIN dbo.tblICInventoryTransaction InvTrans
					ON InvTrans.intItemId = Stock.intItemId
					AND InvTrans.intItemLocationId = Stock.intItemLocationId
				INNER JOIN #tmpInvCostAdjustmentToReverse ItemToUnpost
					ON ItemToUnpost.intInventoryTransactionId = InvTrans.intInventoryTransactionId
	END
END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateReversalGLEntries 
	@strBatchId
	,@intTransactionId
	,@strTransactionId
	,@intUserId
;

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvCostAdjustmentToReverse')) 
	DROP TABLE #tmpInvCostAdjustmentToReverse