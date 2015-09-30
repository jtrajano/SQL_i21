/*
	This is the stored procedure that handles the adjustment of the cost for an item on Average Costing. 
	
	Parameters: 
	@intItemId - The item to adjust

	@intLocationId - The location where the item is being process. 

	@intItemUOMId - The UOM used for the item in a transaction. Each transaction can use different kinds of UOM on its items. 

	@intSubLocationId - The sub location of the item.

	@intStorageLocationId - The storage location of the item. 
	
	@dtmDate - The date used in the transaction and posting. 

	@dblValue - The value of the adjustment. 

	@intTransactionId - The  

	@strTransactionId - The string value of a transaction id. 

	@strBatchId - The batch id to use in generating the g/l entries. 

	@intTransactionTypeId - The type of the transaction. 

	@intUserId - The user who initiated or called this stored procedure. 
*/

CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnAverageCosting]
	@dtmDate AS DATETIME
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT 
	,@intItemUOMId AS INT	
	,@dblQty AS NUMERIC(18,6)
	,@dblNewCost AS NUMERIC(38,20)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@intSourceTransactionId AS INT
	,@strSourceTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-----------------------------------------------------------------------------------------------------------------------------
-- Initialize
-----------------------------------------------------------------------------------------------------------------------------

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

-- Declare the cost types
DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
		,@COST_ADJ_TYPE_New_Cost AS INT = 2

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_NEGATIVE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_COST_ADJUSTMENT AS INT = 22;

DECLARE @CostBucketId AS INT
		,@CostBucketCost AS NUMERIC(38,20)
		,@CostBucketStockInQty AS NUMERIC(18,6)
		,@CostBucketStockOutQty AS NUMERIC(18,6)
		,@CostBucketUOMQty AS NUMERIC(18,6)

		,@InventoryTransactionIdentityId AS INT
		,@OriginalCost AS NUMERIC(38,20)
		,@dblNewCalculatedCost AS NUMERIC(38,20)

DECLARE @TransactionId AS INT
		,@TransactionQty AS NUMERIC(18,6)
		,@TransactionUOMQty AS NUMERIC(18,6)
		,@TransactionCost AS NUMERIC(38,20)
		,@TransactionValue AS NUMERIC(38,20)
		,@TransactionSubLocationId AS INT
		,@TransactionStorageLocationId AS INT 
		,@TransactionCurrencyId AS INT
		,@TransactionExchangeRate AS INT
		,@TransactionStringId AS NVARCHAR(40)
		,@TransactionIntegerId AS INT
		,@TransactionTypeName AS NVARCHAR(200) 

DECLARE	@OriginalTransactionValue AS NUMERIC(38,20)
		,@NewTransactionValue AS NUMERIC(38,20)
		,@CostAdjustmentValue AS NUMERIC(38,20)

-- Initialize the transaction name. Use this as the transaction form name
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-- Get the cost bucket and original cost. 
BEGIN 
	SELECT	@CostBucketId = intInventoryFIFOId
			,@CostBucketCost = dblCost			
			,@CostBucketStockInQty = dblStockIn
			,@CostBucketStockOutQty = dblStockOut
			,@CostBucketUOMQty = tblICItemUOM.dblUnitQty
	FROM	dbo.tblICInventoryFIFO LEFT JOIN dbo.tblICItemUOM 
				ON tblICInventoryFIFO.intItemUOMId = tblICItemUOM.intItemUOMId
	WHERE	tblICInventoryFIFO.intItemId = @intItemId
			AND tblICInventoryFIFO.intItemLocationId = @intItemLocationId
			AND tblICInventoryFIFO.intItemUOMId = @intItemUOMId
			AND tblICInventoryFIFO.intTransactionId = @intSourceTransactionId
			AND tblICInventoryFIFO.strTransactionId = @strSourceTransactionId
			AND ISNULL(tblICInventoryFIFO.ysnIsUnposted, 0) = 0 
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Validation
-----------------------------------------------------------------------------------------------------------------------------

-- Validate the cost bucket
BEGIN 
	IF @CostBucketId IS NULL
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)

		SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'item with id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
		FROM	dbo.tblICItem 
		WHERE	intItemId = @intItemId

		-- 'Cost adjustment cannot continue. Unable to find the cost bucket for {Item}.'
		RAISERROR(51182, 11, 1, @strItemNo)  
		GOTO Post_Exit  
	END
END 

-- Check if new cost is the same as the current cost
BEGIN 
	-- Exit and do nothing if the costs are the same. 
	IF ISNULL(@dblNewCost, 0) = ISNULL(@CostBucketCost, 0)
		GOTO Post_Exit
END 

-- Log original cost to tblICInventoryFIFOCostAdjustmentLog
BEGIN 
	INSERT INTO tblICInventoryFIFOCostAdjustmentLog (
			[intInventoryFIFOId]
			,[intInventoryCostAdjustmentTypeId]
			,[dblQty]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]		
	)
	SELECT	[intInventoryFIFOId]				= @CostBucketId
			,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_Original_Cost
			,[dblQty]							= @CostBucketStockInQty
			,[dblCost]							= @CostBucketCost
			,[dtmCreated]						= GETDATE()
			,[intCreatedUserId]					= @intUserId
	WHERE NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblICInventoryFIFOCostAdjustmentLog
		WHERE	intInventoryFIFOId = @CostBucketId
				AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
	)
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Post the cost adjustment. 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Get the original cost from the FIFO cost adjustment log table. 
	SELECT	@OriginalCost = dblCost
	FROM	dbo.tblICInventoryFIFOCostAdjustmentLog
	WHERE	intInventoryFIFOId = @CostBucketId
			AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost

	-- Compute the new transaction value. 
	SELECT	@NewTransactionValue = @dblQty * @dblNewCost

	-- Compute the original transaction value. 
	SELECT	@OriginalTransactionValue = @dblQty * @OriginalCost

	SELECT @dblNewCalculatedCost =	@CostBucketCost 
									+ ((@NewTransactionValue - @OriginalTransactionValue) / @CostBucketStockInQty)	

	SELECT @CostAdjustmentValue = @dblQty * (@dblNewCost - @OriginalCost)

	-- Create the 'Cost Adjustment'
	EXEC [dbo].[uspICPostInventoryTransaction]
		@intItemId								= @intItemId
		,@intItemLocationId						= @intItemLocationId
		,@intItemUOMId							= @intItemUOMId
		,@intSubLocationId						= @intSubLocationId
		,@intStorageLocationId					= @intStorageLocationId
		,@dtmDate								= @dtmDate
		,@dblQty								= 0
		,@dblUOMQty								= 0
		,@dblCost								= 0
		,@dblValue								= @CostAdjustmentValue
		,@dblSalesPrice							= 0
		,@intCurrencyId							= NULL 
		,@dblExchangeRate						= 1
		,@intTransactionId						= @intTransactionId
		,@intTransactionDetailId				= @intTransactionDetailId
		,@strTransactionId						= @strTransactionId
		,@strBatchId							= @strBatchId
		,@intTransactionTypeId					= @INVENTORY_COST_ADJUSTMENT
		,@intLotId								= NULL 
		,@intRelatedInventoryTransactionId		= NULL 
		,@intRelatedTransactionId				= NULL 
		,@strRelatedTransactionId				= NULL 
		,@strTransactionForm					= @TransactionTypeName
		,@intUserId								= @intUserId
		,@intCostingMethod						= @AVERAGECOST
		,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT

	-- Log the new cost
	INSERT INTO tblICInventoryFIFOCostAdjustmentLog (
			[intInventoryFIFOId]
			,[intInventoryCostAdjustmentTypeId]
			,[dblQty]
			,[dblCost]
			,[dtmCreated]
			,[intCreatedUserId]		
	)
	SELECT	[intInventoryFIFOId]				= @CostBucketId
			,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_New_Cost
			,[dblQty]							= @dblQty
			,[dblCost]							= @dblNewCost
			,[dtmCreated]						= GETDATE()
			,[intCreatedUserId]					= @intUserId
			
	-- Calculate the new cost
	UPDATE	CostBucket
	SET		dblCost = @dblNewCalculatedCost
	FROM	tblICInventoryFIFO CostBucket
	WHERE	CostBucket.intInventoryFIFOId = @CostBucketId
			AND CostBucket.dblStockIn > 0 
			AND ISNULL(ysnIsUnposted, 0) = 0 
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Begin loop for sold stocks
-----------------------------------------------------------------------------------------------------------------------------
IF @dblNewCalculatedCost IS NOT NULL 
BEGIN 
	-- Get the FIFO Out records. 
	DECLARE @FIFOOutIdd AS INT 
			,@FIFOOutInventoryFIFOId AS INT 
			,@FIFOOutInventoryTransactionId AS INT 
			,@FIFOOutRevalueFifoId AS INT 
			,@FIFOOutQty AS NUMERIC(18, 6)
			,@RevaluedQty AS NUMERIC(18, 6) = @dblQty

	-----------------------------------------------------------------------------------------------------------------------------
	-- Create the cursor
	-- Make sure the following options are used: 
	-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
	-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
	-----------------------------------------------------------------------------------------------------------------------------
	DECLARE loopFIFOOut CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intId
			,intInventoryFIFOId
			,intInventoryTransactionId
			,intRevalueFifoId
			,dblQty
	FROM	dbo.tblICInventoryFIFOOut FIFOOut
	WHERE	FIFOOut.intInventoryFIFOId = @CostBucketId

	OPEN loopFIFOOut;

	-- Initial fetch attempt
	FETCH NEXT FROM loopFIFOOut INTO 
			@FIFOOutIdd
			,@FIFOOutInventoryFIFOId 
			,@FIFOOutInventoryTransactionId 
			,@FIFOOutRevalueFifoId 
			,@FIFOOutQty 

	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0
	BEGIN 
			-- If Qty with new cost was sold, do the revalue and write-off sold. 
			IF @CostBucketStockOutQty > 0 AND @RevaluedQty > 0
			BEGIN 
				-- Initialize the variables
				SELECT	@TransactionId					= NULL 
						,@TransactionSubLocationId		= NULL
						,@TransactionStorageLocationId	= NULL
						,@TransactionQty				= NULL
						,@TransactionUOMQty				= NULL
						,@TransactionCost				= NULL
						,@TransactionValue				= NULL
						,@TransactionCurrencyId			= NULL
						,@TransactionExchangeRate		= NULL
						,@TransactionIntegerId			= NULL
						,@TransactionStringId			= NULL

				-- Get the Stock Out data from the Inventory Transaction
				SELECT	@TransactionId						= InvTransaction.intInventoryTransactionId
						,@TransactionSubLocationId			= InvTransaction.intSubLocationId
						,@TransactionStorageLocationId		= InvTransaction.intStorageLocationId
						,@TransactionQty					= InvTransaction.dblQty 
						,@TransactionUOMQty					= InvTransaction.dblUOMQty
						,@TransactionCost					= InvTransaction.dblCost
						,@TransactionValue					= InvTransaction.dblValue 
						,@TransactionCurrencyId				= InvTransaction.intCurrencyId
						,@TransactionExchangeRate			= InvTransaction.dblExchangeRate
						,@TransactionIntegerId				= InvTransaction.intTransactionId
						,@TransactionStringId				= InvTransaction.strTransactionId
				FROM	dbo.tblICInventoryTransaction InvTransaction
				WHERE	InvTransaction.intInventoryTransactionId = @FIFOOutInventoryTransactionId

				-- Create the Revalue sold 
				IF @TransactionId IS NOT NULL 
				BEGIN 
					SELECT @TransactionValue =	-1 	
												* CASE WHEN ISNULL(@FIFOOutQty, 0) > @RevaluedQty THEN 
														@RevaluedQty
													ELSE 
														ISNULL(@FIFOOutQty, 0)
												END 																								
												* (@dblNewCost - @TransactionCost) 

					EXEC [dbo].[uspICPostInventoryTransaction]
						@intItemId								= @intItemId
						,@intItemLocationId						= @intItemLocationId
						,@intItemUOMId							= @intItemUOMId
						,@intSubLocationId						= @TransactionSubLocationId 
						,@intStorageLocationId					= @TransactionStorageLocationId 
						,@dtmDate								= @dtmDate
						,@dblQty								= 0
						,@dblUOMQty								= 0
						,@dblCost								= 0
						,@dblValue								= @TransactionValue
						,@dblSalesPrice							= 0
						,@intCurrencyId							= @TransactionCurrencyId
						,@dblExchangeRate						= @TransactionExchangeRate
						,@intTransactionId						= @intTransactionId
						,@intTransactionDetailId				= @intTransactionDetailId
						,@strTransactionId						= @strTransactionId
						,@strBatchId							= @strBatchId
						,@intTransactionTypeId					= @INVENTORY_REVALUE_SOLD
						,@intLotId								= NULL 
						,@intRelatedInventoryTransactionId		= @FIFOOutInventoryTransactionId
						,@intRelatedTransactionId				= @TransactionIntegerId 
						,@strRelatedTransactionId				= @TransactionStringId 
						,@strTransactionForm					= @TransactionTypeName
						,@intUserId								= @intUserId
						,@intCostingMethod						= @AVERAGECOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
				END

				SET @RevaluedQty = @RevaluedQty - @FIFOOutQty
			END 					

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopFIFOOut INTO 
				@FIFOOutIdd
				,@FIFOOutInventoryFIFOId 
				,@FIFOOutInventoryTransactionId 
				,@FIFOOutRevalueFifoId 
				,@FIFOOutQty 
	END;
END;

-----------------------------------------------------------------------------------------------------------------------------
-- End loop for sold stocks
-----------------------------------------------------------------------------------------------------------------------------
	
-----------------------------------------------------------------------------------------------------------------------------
-- Update the average cost 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @CurrentStockQty AS NUMERIC(18,6)
			,@CurrentAverageCost AS NUMERIC(38,20)

	SELECT TOP 1 
			@CurrentStockQty = dblUnitOnHand
	FROM	dbo.tblICItemStock
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	SELECT	TOP 1
			@CurrentAverageCost = dblAverageCost
	FROM	dbo.tblICItemPricing 
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	MERGE	
	INTO	dbo.tblICItemPricing 
	WITH	(HOLDLOCK) 
	AS		ItemPricing
	USING (
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,[UnsoldQty] = dbo.fnCalculateStockUnitQty(@RevaluedQty, @CostBucketUOMQty)
					,[CostDifference] = dbo.fnCalculateUnitCost(@dblNewCost, @CostBucketUOMQty) - dbo.fnCalculateUnitCost(@CostBucketCost, @CostBucketUOMQty)
					,[CurrentStock] = @CurrentStockQty
	) AS StockToUpdate
		ON ItemPricing.intItemId = StockToUpdate.intItemId
		AND ItemPricing.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the average cost, last cost, and standard cost
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblAverageCost = dbo.fnCalculateAverageCostAfterCostAdj(
					StockToUpdate.[UnsoldQty]
					,StockToUpdate.[CostDifference]
					,StockToUpdate.[CurrentStock]
					,@CurrentAverageCost
				)

	-- If none found, insert a new item pricing record
	WHEN NOT MATCHED THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblAverageCost 
			,dblLastCost 
			,dblStandardCost
			,intConcurrencyId
		)
		VALUES (
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,@CurrentAverageCost
			,0
			,0
			,1
		)
	;
END 

-- Immediate exit
Post_Exit: 