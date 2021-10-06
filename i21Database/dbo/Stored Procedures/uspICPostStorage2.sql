/*
	This is the stored procedure that handles the "posting" of items. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToStorage, a table-valued parameter (variable). 
	
	In each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Adjust the stock quantity and current average cost. 
		3. Calls another stored procedure that will return the generated G/L entries

	Parameters: 
	@ItemsToStorage - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@intEntityUserSecurityId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostStorage]
	@ItemsToStorage AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Declare the variables to use for the cursor
DECLARE @intId AS INT 
		,@intItemId AS INT
		,@intItemLocationId AS INT 
		,@intItemUOMId AS INT 
		,@dtmDate AS DATETIME
		,@dblQty AS NUMERIC(38, 20) 
		,@dblUOMQty AS NUMERIC(38, 20)
		,@dblCost AS NUMERIC(38, 20)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		--,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 
		,@strActualCostId AS NVARCHAR(50)
		,@intForexRateTypeId AS INT
		,@dblForexRate NUMERIC(38, 20)
		,@intSourceEntityId INT 

DECLARE @CostingMethod AS INT 
		,@strTransactionForm AS NVARCHAR(255)

-- Declare the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

DECLARE @returnValue AS INT 

-----------------------------------------------------------------------------------------------------------------------------
-- Assemble the Stock to Post
-----------------------------------------------------------------------------------------------------------------------------
DECLARE @StorageToPost AS ItemCostingTableType 
INSERT INTO @StorageToPost (
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
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
	,[intTransactionTypeId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[ysnIsStorage]
	,[strActualCostId]
    ,[intSourceTransactionId]
	,[strSourceTransactionId]
	,[intInTransitSourceLocationId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intStorageScheduleTypeId]
    ,[dblUnitRetail]
	,[intCategoryId]
	,[dblAdjustCostValue]
	,[dblAdjustRetailValue]
	,[intCostingMethod]
	,[ysnAllowVoucher]
	,[intSourceEntityId]
)
SELECT
	[intItemId] = p.intItemId 
	,[intItemLocationId] = p.intItemLocationId
	,[intItemUOMId] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN iu.intItemUOMId ELSE p.intItemUOMId END 
	,[dtmDate] = p.dtmDate
    ,[dblQty] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateQtyBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblQty) ELSE p.dblQty END 
	,[dblUOMQty] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN iu.dblUnitQty ELSE p.dblUOMQty END 
    ,[dblCost] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblCost) ELSE p.dblCost END 
	,[dblValue] = p.dblValue 
	,[dblSalesPrice] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblSalesPrice) ELSE p.dblSalesPrice END 
	,[intCurrencyId] = p.intCurrencyId
	,[dblExchangeRate] = p.dblExchangeRate
    ,[intTransactionId] = p.intTransactionId
	,[intTransactionDetailId] = p.intTransactionDetailId
	,[strTransactionId] = p.strTransactionId 
	,[intTransactionTypeId] = p.intTransactionTypeId
	,[intLotId] = p.intLotId 
	,[intSubLocationId] = p.intSubLocationId 
	,[intStorageLocationId] = p.intStorageLocationId
	,[ysnIsStorage] = p.ysnIsStorage
	,[strActualCostId] = p.strActualCostId
    ,[intSourceTransactionId] = p.intSourceTransactionId
	,[strSourceTransactionId] = p.strSourceTransactionId
	,[intInTransitSourceLocationId] = p.intInTransitSourceLocationId
	,[intForexRateTypeId] = p.intForexRateTypeId
	,[dblForexRate] = p.dblForexRate
	,[intStorageScheduleTypeId] = p.intStorageScheduleTypeId
    ,[dblUnitRetail] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblUnitRetail) ELSE p.dblUnitRetail END 
	,[intCategoryId] = p.intCategoryId
	,[dblAdjustCostValue] = p.dblAdjustCostValue
	,[dblAdjustRetailValue] = p.dblAdjustRetailValue
	,[intCostingMethod] = p.intCostingMethod
	,[ysnAllowVoucher] = p.ysnAllowVoucher
	,[intSourceEntityId] = p.intSourceEntityId 
FROM 
	@ItemsToStorage p 
	INNER JOIN tblICItem i 
		ON p.intItemId = i.intItemId 
	LEFT JOIN tblICItemUOM iu
		ON iu.intItemId = p.intItemId
		AND iu.ysnStockUnit = 1
ORDER BY 
	p.intId

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC @returnValue = dbo.uspICValidateCostingOnPostStorage
		@ItemsToValidate = @StorageToPost

	IF @returnValue < 0 RETURN @returnValue;
END

-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
DECLARE loopItems CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intId
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(dtmDate) 
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		--,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,strActualCostId
		,intForexRateTypeId
		,dblForexRate
		,intSourceEntityId
FROM	@StorageToPost

OPEN loopItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO 
	@intId
	,@intItemId
	,@intItemLocationId
	,@intItemUOMId
	,@dtmDate
	,@dblQty
	,@dblUOMQty
	,@dblCost
	,@dblSalesPrice
	,@intCurrencyId
	--,@dblExchangeRate
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSubLocationId
	,@intStorageLocationId
	,@strActualCostId
	,@intForexRateTypeId
	,@dblForexRate
	,@intSourceEntityId
	;
	
-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL;

	-- Initialize the transaction form
	SELECT	@strTransactionForm = strTransactionForm
	FROM	dbo.tblICInventoryTransactionType
	WHERE	intTransactionTypeId = @intTransactionTypeId
			AND strTransactionForm IS NOT NULL 

	-- Get the costing method of an item 
	SELECT	@CostingMethod = CostingMethod 
	FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)

	-- Initialize the dblUOMQty
	SELECT	@dblUOMQty = dblUnitQty
	FROM	dbo.tblICItemUOM
	WHERE	intItemId = @intItemId
			AND intItemUOMId = @intItemUOMId

	--------------------------------------------------------------------------------
	-- Call the SP that can process the item's costing method
	--------------------------------------------------------------------------------
	-- Average Cost
	-- FIFO 
	IF (@CostingMethod IN (@AVERAGECOST, @FIFO))
	BEGIN 
		EXEC @returnValue = dbo.uspICPostFIFOStorage
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId

		IF @returnValue < 0 GOTO _TerminateLoop;
	END

	-- LIFO 
	IF (@CostingMethod = @LIFO)
	BEGIN 
		EXEC @returnValue = dbo.uspICPostLIFOStorage
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId

		IF @returnValue < 0 GOTO _TerminateLoop;
	END

	-- LOT 
	IF (@CostingMethod = @LOTCOST)
	BEGIN 
		EXEC @returnValue = dbo.uspICPostLotStorage
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@intLotId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId

		IF @returnValue < 0 GOTO _TerminateLoop;
	END

	------------------------------------------------------------
	-- Update the Storage Quantity
	------------------------------------------------------------
	BEGIN 
		EXEC @returnValue = [dbo].[uspICPostStorageQuantity]
			@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,@dblQty
			,@dblUOMQty
			,@intLotId

		IF @returnValue < 0 GOTO _TerminateLoop;
	END 

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO 
		@intId
		,@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@dblQty
		,@dblUOMQty
		,@dblCost
		,@dblSalesPrice
		,@intCurrencyId
		--,@dblExchangeRate
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
		,@strActualCostId 
		,@intForexRateTypeId
		,@dblForexRate
		,@intSourceEntityId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

_TerminateLoop:

CLOSE loopItems;
DEALLOCATE loopItems;

IF @returnValue < 0 RETURN @returnValue;