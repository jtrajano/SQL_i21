/*
	This is the stored procedure that handles the adjustment of the cost for an item on LIFO. 
	
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

CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnLIFO]
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
	,@intCurrencyId AS INT 
	,@dblExchangeRate AS NUMERIC(38,20)
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
		,@CostBucketIntTransactionId AS INT
		,@CostBucketStrTransactionId AS NVARCHAR(40)

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
	SELECT	@CostBucketId = intInventoryLIFOId
			,@CostBucketCost = dblCost			
			,@CostBucketStockInQty = dblStockIn
			,@CostBucketStockOutQty = dblStockOut
			,@CostBucketUOMQty = tblICItemUOM.dblUnitQty
			,@CostBucketIntTransactionId = intTransactionId
			,@CostBucketStrTransactionId = strTransactionId
	FROM	dbo.tblICInventoryLIFO LEFT JOIN dbo.tblICItemUOM 
				ON tblICInventoryLIFO.intItemUOMId = tblICItemUOM.intItemUOMId
	WHERE	tblICInventoryLIFO.intItemId = @intItemId
			AND tblICInventoryLIFO.intItemLocationId = @intItemLocationId
			AND tblICInventoryLIFO.intItemUOMId = @intItemUOMId
			AND tblICInventoryLIFO.intTransactionId = @intSourceTransactionId
			AND tblICInventoryLIFO.strTransactionId = @strSourceTransactionId
			AND ISNULL(tblICInventoryLIFO.ysnIsUnposted, 0) = 0 
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
		RAISERROR(80062, 11, 1, @strItemNo)  
		GOTO Post_Exit  
	END
END 

-- Check if new cost is the same as the current cost
BEGIN 
	-- Exit and do nothing if the costs are the same. 
	IF ISNULL(@dblNewCost, 0) = ISNULL(@CostBucketCost, 0)
		GOTO Post_Exit
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Post the cost adjustment. 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Get the original cost. 
	BEGIN 
		-- Get the original cost from the LIFO cost adjustment log table. 
		SELECT	@OriginalCost = dblCost
		FROM	dbo.tblICInventoryLIFOCostAdjustmentLog
		WHERE	intInventoryLIFOId = @CostBucketId
				AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
		
		-- If none found, the original cost is the cost bucket cost. 
		SET @OriginalCost = ISNULL(@OriginalCost, @CostBucketCost) 
	END 

	-- Compute the new transaction value. 
	SELECT	@NewTransactionValue = @dblQty * @dblNewCost

	-- Compute the original transaction value. 
	SELECT	@OriginalTransactionValue = @dblQty * @OriginalCost

	-- Compute the new cost. 
	SELECT @dblNewCalculatedCost =	@CostBucketCost 
									+ ((@NewTransactionValue - @OriginalTransactionValue) / @CostBucketStockInQty)	

	-- Compute value to adjust the item valuation. 
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
		,@intCurrencyId							= @intCurrencyId 
		,@dblExchangeRate						= @dblExchangeRate
		,@intTransactionId						= @intTransactionId
		,@intTransactionDetailId				= @intTransactionDetailId
		,@strTransactionId						= @strTransactionId
		,@strBatchId							= @strBatchId
		,@intTransactionTypeId					= @INVENTORY_COST_ADJUSTMENT
		,@intLotId								= NULL 
		,@intRelatedInventoryTransactionId		= NULL 
		,@intRelatedTransactionId				= @CostBucketIntTransactionId 
		,@strRelatedTransactionId				= @CostBucketStrTransactionId
		,@strTransactionForm					= @TransactionTypeName
		,@intUserId								= @intUserId
		,@intCostingMethod						= @AVERAGECOST
		,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT

	-- Log original cost to tblICInventoryLIFOCostAdjustmentLog
	IF NOT EXISTS (
			SELECT	TOP 1 1 
			FROM	dbo.tblICInventoryLIFOCostAdjustmentLog
			WHERE	intInventoryLIFOId = @CostBucketId
					AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
	)
	BEGIN 
		INSERT INTO tblICInventoryLIFOCostAdjustmentLog (
				[intInventoryLIFOId]
				,[intInventoryTransactionId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty]
				,[dblCost]
				,[dtmCreated]
				,[intCreatedUserId]		
		)
		SELECT	[intInventoryLIFOId]				= @CostBucketId
				,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
				,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_Original_Cost
				,[dblQty]							= @CostBucketStockInQty
				,[dblCost]							= @CostBucketCost
				,[dtmCreated]						= GETDATE()
				,[intCreatedUserId]					= @intUserId
	END 

	-- Log a new cost. 
	BEGIN 
		INSERT INTO tblICInventoryLIFOCostAdjustmentLog (
				[intInventoryLIFOId]
				,[intInventoryTransactionId]
				,[intInventoryCostAdjustmentTypeId]
				,[dblQty]
				,[dblCost]
				,[dtmCreated]
				,[intCreatedUserId]		
		)
		SELECT	[intInventoryLIFOId]				= @CostBucketId
				,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
				,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_New_Cost
				,[dblQty]							= @dblQty
				,[dblCost]							= @dblNewCost
				,[dtmCreated]						= GETDATE()
				,[intCreatedUserId]					= @intUserId
	END 
			
	-- Calculate the new cost
	UPDATE	CostBucket
	SET		dblCost = @dblNewCalculatedCost
	FROM	tblICInventoryLIFO CostBucket
	WHERE	CostBucket.intInventoryLIFOId = @CostBucketId
			AND CostBucket.dblStockIn > 0 
			AND ISNULL(ysnIsUnposted, 0) = 0 
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Begin loop for sold stocks
-----------------------------------------------------------------------------------------------------------------------------
IF @dblNewCalculatedCost IS NOT NULL 
BEGIN 
	-- Get the LIFO Out records. 
	DECLARE @LIFOOutIdd AS INT 
			,@LIFOOutInventoryLIFOId AS INT 
			,@LIFOOutInventoryTransactionId AS INT 
			,@LIFOOutRevalueLIFOId AS INT 
			,@LIFOOutQty AS NUMERIC(18, 6)
			,@RevaluedQty AS NUMERIC(18, 6) = @dblQty

	-----------------------------------------------------------------------------------------------------------------------------
	-- Create the cursor
	-- Make sure the following options are used: 
	-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
	-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
	-----------------------------------------------------------------------------------------------------------------------------
	DECLARE loopLIFOOut CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intId
			,intInventoryLIFOId
			,intInventoryTransactionId
			,intRevalueLifoId
			,dblQty
	FROM	dbo.tblICInventoryLIFOOut LIFOOut
	WHERE	LIFOOut.intInventoryLIFOId = @CostBucketId

	OPEN loopLIFOOut;

	-- Initial fetch attempt
	FETCH NEXT FROM loopLIFOOut INTO 
			@LIFOOutIdd
			,@LIFOOutInventoryLIFOId 
			,@LIFOOutInventoryTransactionId 
			,@LIFOOutRevalueLIFOId 
			,@LIFOOutQty 

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
				WHERE	InvTransaction.intInventoryTransactionId = @LIFOOutInventoryTransactionId

				-- Create the Revalue sold 
				IF @TransactionId IS NOT NULL 
				BEGIN 
					SELECT @TransactionValue =	-1 	
												* CASE WHEN ISNULL(@LIFOOutQty, 0) > @RevaluedQty THEN 
														@RevaluedQty
													ELSE 
														ISNULL(@LIFOOutQty, 0)
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
						,@intRelatedInventoryTransactionId		= @LIFOOutInventoryTransactionId
						,@intRelatedTransactionId				= @TransactionIntegerId 
						,@strRelatedTransactionId				= @TransactionStringId 
						,@strTransactionForm					= @TransactionTypeName
						,@intUserId								= @intUserId
						,@intCostingMethod						= @AVERAGECOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
				END

				SET @RevaluedQty = @RevaluedQty - @LIFOOutQty
			END 					

		-- Attempt to fetch the next row from cursor. 
		FETCH NEXT FROM loopLIFOOut INTO 
				@LIFOOutIdd
				,@LIFOOutInventoryLIFOId 
				,@LIFOOutInventoryTransactionId 
				,@LIFOOutRevalueLIFOId 
				,@LIFOOutQty 
	END;
END;

CLOSE loopLIFOOut;
DEALLOCATE loopLIFOOut;

-----------------------------------------------------------------------------------------------------------------------------
-- End loop for sold stocks
-----------------------------------------------------------------------------------------------------------------------------
	
-----------------------------------------------------------------------------------------------------------------------------
-- Update the average cost 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICRecalcAveCostOnCostAdjustment
		@intItemId
		,@intItemLocationId
		,@RevaluedQty
		,@CostBucketUOMQty
		,@dblNewCost
		,@CostBucketCost
	;
END 

-- Immediate exit
Post_Exit: 