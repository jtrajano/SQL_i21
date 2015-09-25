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

CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnFIFOCosting]
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

-- Get the UOM Qty 
DECLARE @dblUOMQty AS NUMERIC(18,6)
SELECT TOP 1 
		@dblUOMQty = dblUnitQty
FROM	dbo.tblICItemUOM 
WHERE	intItemId = @intItemId
		AND intItemUOMId = @intItemUOMId

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_NEGATIVE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_COST_ADJUSTMENT AS INT = 22;

DECLARE @CostBucketId AS INT
		,@InventoryTransactionIdentityId AS INT
		,@OriginalCost AS NUMERIC(38,20)
		,@CurrentCost AS NUMERIC(38,20)
		,@CostBucketStockInQty AS NUMERIC(18,6)
		,@CostBucketStockOutQty AS NUMERIC(18,6)
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

-- Initialize the transaction name. Use this as the transaction form name
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-- Get the cost bucket and original cost. 
BEGIN 
	SELECT	@CostBucketId	= intInventoryFIFOId
			,@CurrentCost	= dblCost			
			,@CostBucketStockInQty = dblStockIn
			,@CostBucketStockOutQty = dblStockOut
	FROM	dbo.tblICInventoryFIFO
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId
			AND intItemUOMId = @intItemUOMId
			AND intTransactionId = @intSourceTransactionId
			AND strTransactionId = @strSourceTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0 
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
	IF ISNULL(@dblNewCost, 0) = ISNULL(@CurrentCost, 0)
		GOTO Post_Exit
END 

-- Log original cost to tblICInventoryFIFOCostAdjustment
BEGIN 
	INSERT INTO tblICInventoryFIFOCostAdjustment (
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
			,[dblCost]							= @CurrentCost
			,[dtmCreated]						= GETDATE()
			,[intCreatedUserId]					= @intUserId
	WHERE NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblICInventoryFIFOCostAdjustment
		WHERE	intInventoryFIFOId = @CostBucketId
				AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
	)
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Post the new cost 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Initialize the variables
	SELECT	@NewTransactionValue = @dblQty * @dblNewCost

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
		,@dblValue								= @NewTransactionValue
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
	INSERT INTO tblICInventoryFIFOCostAdjustment (
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
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Write off the Original Cost 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	SELECT	@OriginalCost = dblCost
	FROM	dbo.tblICInventoryFIFOCostAdjustment
	WHERE	intInventoryFIFOId = @CostBucketId
			AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost

	-- Initialize the variables
	SELECT	@OriginalTransactionValue = -1 * @dblQty * @OriginalCost

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
		,@dblValue								= @OriginalTransactionValue
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

	SELECT @dblNewCalculatedCost =	@CurrentCost 
									+ ((@OriginalTransactionValue + @NewTransactionValue) / @CostBucketStockInQty)					

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

				IF @TransactionId IS NOT NULL 
				BEGIN 
					-- Create the Write-Off Sold
					SET @TransactionValue = 
							CASE WHEN ISNULL(@FIFOOutQty, 0) > @RevaluedQty THEN 
									@RevaluedQty
								ELSE 
									ISNULL(@FIFOOutQty, 0)
							END 
							* ISNULL(@TransactionCost, 0) 

					EXEC [dbo].[uspICPostInventoryTransaction]
						@intItemId							= @intItemId
						,@intItemLocationId					= @intItemLocationId
						,@intItemUOMId						= @intItemUOMId
						,@intSubLocationId					= @TransactionSubLocationId 
						,@intStorageLocationId				= @TransactionStorageLocationId 
						,@dtmDate							= @dtmDate
						,@dblQty							= 0
						,@dblUOMQty							= 0
						,@dblCost							= 0
						,@dblValue							= @TransactionValue
						,@dblSalesPrice						= 0
						,@intCurrencyId						= @TransactionCurrencyId
						,@dblExchangeRate					= @TransactionExchangeRate
						,@intTransactionId					= @intTransactionId
						,@intTransactionDetailId			= @intTransactionDetailId
						,@strTransactionId					= @strTransactionId
						,@strBatchId						= @strBatchId
						,@intTransactionTypeId				= @INVENTORY_WRITE_OFF_SOLD
						,@intLotId							= NULL 
						,@intRelatedInventoryTransactionId	= @FIFOOutInventoryTransactionId
						,@intRelatedTransactionId			= @TransactionIntegerId 
						,@strRelatedTransactionId			= @TransactionStringId 
						,@strTransactionForm				= @TransactionTypeName
						,@intUserId							= @intUserId
						,@intCostingMethod					= @AVERAGECOST
						,@InventoryTransactionIdentityId	= @InventoryTransactionIdentityId OUTPUT
				
					-- Create the Revalue sold 
					SELECT @TransactionValue =	-1 	
												* CASE WHEN ISNULL(@FIFOOutQty, 0) > @RevaluedQty THEN 
														@RevaluedQty
													ELSE 
														ISNULL(@FIFOOutQty, 0)
												END 																								
												* ISNULL(@dblNewCalculatedCost, 0) -- and multiply it by the new calculated cost 

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

-- Immediate exit
Post_Exit: 