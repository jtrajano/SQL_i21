
/*
	This is the stored procedure that handles the unposting of the cost adjustment. 
	
	Parameters: 
	@intTransactionId - The integer value that represents the id of the transaction. Ex: tblAPBill.intBillId. 
	
	@strTransactionId - The string value that represents the id of the transaction. Ex: tblAPBill.strBillId

	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@intEntityUserSecurityId - The user who is initiating the unpost. 

	@intEntityUserSecurityId - A flag on whether to do a generate the recap information (@ysnRecap = 1) or not (@ysnRecap = 0). 
*/
CREATE PROCEDURE [dbo].[uspICUnpostCostAdjustment]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
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

-- Create the variables for transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
		,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
		,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

		,@INV_TRANS_TYPE_Consume AS INT = 8
		,@INV_TRANS_TYPE_Produce AS INT = 9
		,@INV_TRANS_TYPE_Build_Assembly AS INT = 11
		,@INV_TRANS_Inventory_Transfer AS INT = 12

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

		,@INV_TRANS_TYPE_Revalue_Item_Change AS INT = 35
		,@INV_TRANS_TYPE_Revalue_Split_Lot AS INT = 36
		,@INV_TRANS_TYPE_Revalue_Lot_Merge AS INT = 37
		,@INV_TRANS_TYPE_Revalue_Lot_Move AS INT = 38


DECLARE	@intItemId AS INT
		,@intItemLocationId AS INT 

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
		,intCostingMethod INT 
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
	,intCostingMethod
)
SELECT	Changes.intInventoryTransactionId
		,Changes.intTransactionId
		,Changes.strTransactionId
		,Changes.intRelatedTransactionId
		,Changes.strRelatedTransactionId
		,Changes.intTransactionTypeId
		,Changes.intCostingMethod 
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
				AND inventory_transaction.intTransactionTypeId IN (
						@INV_TRANS_TYPE_Cost_Adjustment
						, @INV_TRANS_TYPE_Revalue_Sold
						, @INV_TRANS_TYPE_Revalue_WIP
						, @INV_TRANS_TYPE_Revalue_Produced
						, @INV_TRANS_TYPE_Revalue_Transfer
						, @INV_TRANS_TYPE_Revalue_Build_Assembly
						, @INV_TRANS_TYPE_Revalue_Item_Change 
						, @INV_TRANS_TYPE_Revalue_Split_Lot 
						, @INV_TRANS_TYPE_Revalue_Lot_Merge 
						, @INV_TRANS_TYPE_Revalue_Lot_Move 
				)
				AND 1 = 
					CASE	WHEN	inventory_transaction.strTransactionId = Source_Query.strTransactionId 
									AND inventory_transaction.intTransactionId = Source_Query.intTransactionId THEN 
										1
							WHEN	inventory_transaction.strRelatedTransactionId = Source_Query.strTransactionId 
									AND inventory_transaction.intRelatedTransactionId = Source_Query.intTransactionId THEN	
										1
							ELSE 
										0
					END 					

			-- If matched, update the ysnIsUnposted and set it to true (1) 
			WHEN MATCHED THEN 
				UPDATE 
				SET		ysnIsUnposted = 1

			OUTPUT	$action
					, Inserted.intInventoryTransactionId
					, Inserted.intTransactionId
					, Inserted.strTransactionId
					, Inserted.intRelatedTransactionId
					, Inserted.strRelatedTransactionId
					, Inserted.intTransactionTypeId
					, Inserted.intCostingMethod
		) AS Changes (
			Action
			, intInventoryTransactionId
			, intTransactionId
			, strTransactionId
			, intRelatedTransactionId
			, strRelatedTransactionId
			, intTransactionTypeId
			, intCostingMethod
		)
WHERE	Changes.Action = 'UPDATE'
;

IF EXISTS (SELECT TOP 1 1 FROM #tmpInvCostAdjustmentToReverse) 
BEGIN 

	-------------------------------------------------
	-- Update the cost buckets. Reverse the cost. 
	-------------------------------------------------
	BEGIN 
		-- Unpost the cost buckets for FIFO or Average Costing 
		EXEC dbo.uspICUnpostCostAdjustmentOnFIFO

		-- Unpost the cost buckets for LIFO
		EXEC dbo.uspICUnpostCostAdjustmentOnLIFO

		-- Unpost the cost buckets for Lot Costing 
		EXEC dbo.uspICUnpostCostAdjustmentOnLot 

		-- Unpost the cost buckets for Actual Costing
		EXEC dbo.uspICUnpostCostAdjustmentOnActualCost
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
			,[dblQty]								= -ActualTransaction.dblQty
			,[dblUOMQty]							= ActualTransaction.dblUOMQty
			,[dblCost]								= ActualTransaction.dblCost
			,[dblValue]								= -ActualTransaction.dblValue
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
			,[intCreatedEntityId]					= @intEntityUserSecurityId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= ActualTransaction.intCostingMethod
	FROM	#tmpInvCostAdjustmentToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId

	----------------------------------------------------
	-- Create reversal of the inventory LOT transactions
	----------------------------------------------------
	DECLARE @ActiveLotStatus AS INT = 1
	INSERT INTO dbo.tblICInventoryLotTransaction (		
		[intItemId]
		,[intLotId]
		,[intLocationId]
		,[intItemLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dtmDate]
		,[dblQty]
		,[intItemUOMId]
		,[dblCost]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[strBatchId]
		,[intLotStatusId] 
		,[strTransactionForm]
		,[ysnIsUnposted]
		,[dtmCreated] 
		,[intCreatedUserId] 
		,[intConcurrencyId] 
	)
	SELECT	[intItemId]					= ActualTransaction.intItemId
			,[intLotId]					= ActualTransaction.intLotId
			,[intLocationId]			= ItemLocation.intLocationId
			,[intItemLocationId]		= ActualTransaction.intItemLocationId
			,[intSubLocationId]			= ActualTransaction.intSubLocationId
			,[intStorageLocationId]		= ActualTransaction.intStorageLocationId
			,[dtmDate]					= ActualTransaction.dtmDate
			,[dblQty]					= -ActualTransaction.dblQty
			,[intItemUOMId]				= ActualTransaction.intItemUOMId
			,[dblCost]					= ActualTransaction.dblCost
			,[intTransactionId]			= ActualTransaction.intTransactionId
			,[strTransactionId]			= ActualTransaction.strTransactionId
			,[intTransactionTypeId]		= ActualTransaction.intTransactionTypeId
			,[strBatchId]				= @strBatchId
			,[intLotStatusId]			= @ActiveLotStatus 
			,[strTransactionForm]		= ActualTransaction.strTransactionForm
			,[ysnIsUnposted]			= 1
			,[dtmCreated]				= GETDATE()
			,[intCreatedEntityId]		= @intEntityUserSecurityId
			,[intConcurrencyId]			= 1
	FROM	#tmpInvCostAdjustmentToReverse ItemTransactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON ItemTransactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
				AND ActualTransaction.intLotId IS NOT NULL 
				AND ActualTransaction.intItemUOMId IS NOT NULL
			INNER JOIN tblICItemLocation ItemLocation
				ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId

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
	UPDATE	RelatedLotTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryLotTransaction RelatedLotTransactions 
	WHERE	RelatedLotTransactions.intTransactionId = @intTransactionId
			AND RelatedLotTransactions.strTransactionId = @strTransactionId
			AND RelatedLotTransactions.ysnIsUnposted = 0

	------------------------------------------------------------
	-- Update the Average Cost
	------------------------------------------------------------
	BEGIN 
		BEGIN 
			DECLARE loopUpdateAverageCost CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  DISTINCT 
					InvTrans.intItemId 					
					,InvTrans.intItemLocationId 
			FROM	dbo.tblICInventoryTransaction InvTrans INNER JOIN #tmpInvCostAdjustmentToReverse ItemToUnpost
						ON ItemToUnpost.intInventoryTransactionId = InvTrans.intInventoryTransactionId
						
			OPEN loopUpdateAverageCost;	

			-- Initial fetch attempt
			FETCH NEXT FROM loopUpdateAverageCost INTO 
				@intItemId
				,@intItemLocationId 
			;

			-----------------------------------------------------------------------------------------------------------------------------
			-- Start of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			WHILE @@FETCH_STATUS = 0
			BEGIN 

				-- Recalculate the average cost from the inventory transaction table. 
				UPDATE	ItemPricing
				SET		dblAverageCost = ISNULL(
							dbo.fnRecalculateAverageCost(intItemId, intItemLocationId)
							, dblAverageCost
						) 
				FROM	dbo.tblICItemPricing AS ItemPricing 
				WHERE	ItemPricing.intItemId = @intItemId
						AND ItemPricing.intItemLocationId = @intItemLocationId			
				
				FETCH NEXT FROM loopUpdateAverageCost INTO 
					@intItemId
					,@intItemLocationId 
				;
			END;

			-----------------------------------------------------------------------------------------------------------------------------
			-- End of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			CLOSE loopUpdateAverageCost;
			DEALLOCATE loopUpdateAverageCost;
		END
	END
END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateReversalGLEntries 
	@strBatchId
	,@intTransactionId
	,@strTransactionId
	,@intEntityUserSecurityId
;

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvCostAdjustmentToReverse')) 
	DROP TABLE #tmpInvCostAdjustmentToReverse