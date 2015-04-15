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
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@dtmDate AS DATETIME
	,@dblValue AS NUMERIC(38,20)
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

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_NEGATIVE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_COST_VARIANCE AS INT = 22;

DECLARE @FIFOId AS INT
		,@InventoryTransactionIdentityId AS INT
		,@NewCost AS NUMERIC(38,20)
		,@CurrentCost AS NUMERIC(38,20)

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

-- Initialize the transaction name. Use this as the transaction form name
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-- Get the cost bucket and calculate the new cost. 
BEGIN 
	SELECT	@FIFOId				= intInventoryFIFOId
			,@CurrentCost		= dblCost			
			,@NewCost			= CASE	WHEN ISNULL(dblStockIn, 0) = 0 THEN 0 
										ELSE (
												ISNULL(dblStockIn, 0) 
												* ISNULL(dblCost, 0) 
												+ ISNULL(@dblValue, 0)
											) 
											/ dblStockIn
								END 
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
	IF @FIFOId IS NULL
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)

		SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'item with id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
		FROM	dbo.tblICItem 
		WHERE	intItemId = @intItemId

		-- 'Cost adjustment cannot continue. Unable to find the cost bucket for {Item}.'
		RAISERROR(50004, 11, 1, @strItemNo)  
		GOTO Post_Exit  
	END
END 

-- Check if new cost is the same as the current cost
BEGIN 
	-- Exit and do nothing if the costs are the same. 
	IF @NewCost = @CurrentCost GOTO Post_Exit
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Loop
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	-- Get the FIFO Out records. 
	DECLARE @FIFOOutIdd AS INT 
			,@FIFOOutInventoryFIFOId AS INT 
			,@FIFOOutInventoryTransactionId AS INT 
			,@FIFOOutRevalueFifoId AS INT 
			,@FIFOOutQty AS NUMERIC(18, 6) 

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
	WHERE	FIFOOut.intInventoryFIFOId = @FIFOId

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

			-- Get the data from the Out record
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
				SET @TransactionValue = -1 * ISNULL(@TransactionQty, 0) * ISNULL(@TransactionCost, 0)
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
					,@intTransactionTypeId					= @INVENTORY_WRITE_OFF_SOLD
					,@intLotId								= NULL 
					,@ysnIsUnposted							= 0
					,@intRelatedInventoryTransactionId		= @FIFOOutInventoryTransactionId
					,@intRelatedTransactionId				= @TransactionIntegerId 
					,@strRelatedTransactionId				= @TransactionStringId 
					,@strTransactionForm					= @TransactionTypeName
					,@intUserId								= @intUserId
					,@intCostingMethod						= @AVERAGECOST
					,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT

				-- Create the Revalue sold 
				SET @TransactionValue = ISNULL(@TransactionQty, 0) * ISNULL(@NewCost, 0) 

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
					,@ysnIsUnposted							= 0
					,@intRelatedInventoryTransactionId		= @FIFOOutInventoryTransactionId
					,@intRelatedTransactionId				= @TransactionIntegerId 
					,@strRelatedTransactionId				= @TransactionStringId 
					,@strTransactionForm					= @TransactionTypeName
					,@intUserId								= @intUserId
					,@intCostingMethod						= @AVERAGECOST
					,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT

				-- Create the Cost Variance 
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
					,@dblValue								= @dblValue
					,@dblSalesPrice							= 0
					,@intCurrencyId							= @TransactionCurrencyId
					,@dblExchangeRate						= @TransactionExchangeRate
					,@intTransactionId						= @intTransactionId
					,@intTransactionDetailId				= @intTransactionDetailId
					,@strTransactionId						= @strTransactionId
					,@strBatchId							= @strBatchId
					,@intTransactionTypeId					= @INVENTORY_COST_VARIANCE
					,@intLotId								= NULL 
					,@ysnIsUnposted							= 0
					,@intRelatedInventoryTransactionId		= @FIFOOutInventoryTransactionId
					,@intRelatedTransactionId				= @TransactionIntegerId 
					,@strRelatedTransactionId				= @TransactionStringId 
					,@strTransactionForm					= @TransactionTypeName
					,@intUserId								= @intUserId
					,@intCostingMethod						= @AVERAGECOST
					,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
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

-- Immediate exit
Post_Exit: 