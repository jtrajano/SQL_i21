/*
	This is the stored procedure that handles the "posting" of items. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToPost, a table-valued parameter (variable). 
	
	In each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Adjust the stock quantity and current average cost. 
		3. Calls another stored procedure that will return the generated G/L entries

	Parameters: 
	@ItemsToPost - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@strAccountDescription - The contra g/l account id to use when posting an item. By default, it is set to "Cost of Goods". 
				The calling code needs to specify it because each module may use a different contra g/l account against the 
				Inventory account. For example, a Sales transaction will contra Inventory account with "Cost of Goods" while 
				Receive stocks from AP module may use "AP Clearing".

	@intEntityUserSecurityId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostInTransitCosting]
	@ItemsToPost AS ItemInTransitCostingTableType READONLY
	,@strBatchId AS NVARCHAR(40)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@ValueToPost AS ItemInTransitValueOnlyTableType READONLY
	
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
		,@dblForexCost AS NUMERIC(38,20)	
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		--,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT
		,@intSourceTransactionId AS INT
		,@intSourceTransactionDetailId AS INT 
		,@strSourceTransactionId AS NVARCHAR(40)
		,@intFobPointId AS TINYINT 
		,@intInTransitSourceLocationId AS INT
		,@intForexRateTypeId AS INT
		,@dblForexRate NUMERIC(38, 20)
		
		,@intInventoryTransactionId INT 
		,@strTransactionForm AS NVARCHAR(255)
		,@intSourceEntityId INT
		,@strSourceType AS NVARCHAR(100)
		,@strSourceNumber AS NVARCHAR(100)
		,@strBOLNumber AS NVARCHAR(100)
		,@intTicketId AS INT 
		,@dblValue NUMERIC(38, 20)
		,@intOtherChargeItemId AS INT
		,@strActualCostId AS NVARCHAR(50) 

-- Declare the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_VARIANCE AS INT = 1

DECLARE @intReturnValue AS INT 
		,@intInventoryTransactionIdentityId AS INT

-----------------------------------------------------------------------------------------------------------------------------
-- Assemble the Stock to Post
-----------------------------------------------------------------------------------------------------------------------------
DECLARE @StockToPost AS ItemInTransitCostingTableType 
DECLARE @ValueToPostValidated AS ItemInTransitValueOnlyTableType 

DECLARE @dtmSytemGeneratedPostDate AS DATETIME = dbo.fnRemoveTimeOnDate(GETDATE()) 

INSERT INTO @StockToPost (	
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
    ,[dblQty]
	,[dblUOMQty]
    ,[dblCost]
	,[dblForexCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
    ,[intTransactionId]
	,[intTransactionDetailId]
	,[strTransactionId]
	,[intTransactionTypeId]
	,[intLotId]
    ,[intSourceTransactionId]
	,[strSourceTransactionId]
    ,[intSourceTransactionDetailId]
	,[intFobPointId]
	,[intInTransitSourceLocationId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intSourceEntityId]
	,[strSourceType] 
	,[strSourceNumber]
	,[strBOLNumber]
	,[intTicketId] 
)
SELECT
	[intItemId] = p.intItemId 
	,[intItemLocationId] = p.intItemLocationId
	,[intItemUOMId] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN iu.intItemUOMId ELSE p.intItemUOMId END 
	,[dtmDate] = p.dtmDate
    ,[dblQty] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateQtyBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblQty) ELSE p.dblQty END 
	,[dblUOMQty] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN iu.dblUnitQty ELSE p.dblUOMQty END 
    ,[dblCost] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblCost) ELSE p.dblCost END 
	,[dblForexCost] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblForexCost) ELSE p.dblForexCost END 
	,[dblValue] = p.dblValue 
	,[dblSalesPrice] = CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 AND ISNULL(i.strLotTracking, 'No') = 'No' THEN dbo.fnCalculateCostBetweenUOM(p.intItemUOMId, iu.intItemUOMId, p.dblSalesPrice) ELSE p.dblSalesPrice END 
	,[intCurrencyId] = p.intCurrencyId
	,[dblExchangeRate] = p.dblExchangeRate
    ,[intTransactionId] = p.intTransactionId
	,[intTransactionDetailId] = p.intTransactionDetailId
	,[strTransactionId] = p.strTransactionId 
	,[intTransactionTypeId] = p.intTransactionTypeId
	,[intLotId] = p.intLotId 
    ,[intSourceTransactionId] = p.intSourceTransactionId
	,[strSourceTransactionId] = p.strSourceTransactionId
    ,[intSourceTransactionDetailId] = p.intSourceTransactionDetailId
	,[intFobPointId] = p.intFobPointId
	,[intInTransitSourceLocationId] = p.intInTransitSourceLocationId
	,[intForexRateTypeId] = p.intForexRateTypeId
	,[dblForexRate] = p.dblForexRate
	,[intSourceEntityId] = p.intSourceEntityId
	,[strSourceType] = p.strSourceType 
	,[strSourceNumber] = p.strSourceNumber 
	,[strBOLNumber] = p.strBOLNumber 
	,[intTicketId] = p.intTicketId
FROM 
	@ItemsToPost p 
	INNER JOIN tblICItem i 
		ON p.intItemId = i.intItemId 
	LEFT JOIN tblICItemUOM iu
		ON iu.intItemId = p.intItemId
		AND iu.ysnStockUnit = 1	
ORDER BY 
	p.intId


INSERT INTO @ValueToPostValidated (
	[intItemId] 
	,[intItemLocationId] 
	,[dtmDate] 
	,[dblValue] 
    ,[intTransactionId] 
	,[intTransactionDetailId] 
	,[strTransactionId] 
	,[intTransactionTypeId] 
	,[intLotId] 
    ,[intSourceTransactionId] 
	,[strSourceTransactionId] 
	,[intFobPointId] 
	,[intInTransitSourceLocationId] 
	,[intCurrencyId] 
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[intSourceEntityId] 
	,[strSourceType] 
	,[strSourceNumber] 
	,[strBOLNumber] 
	,[intTicketId] 
	,[intOtherChargeItemId]
)
SELECT 
	[intItemId] = p.intItemId
	,[intItemLocationId] = p.intItemLocationId
	,[dtmDate] = p.dtmDate
	,[dblValue] = p.dblValue
    ,[intTransactionId] = p.intTransactionId
	,[intTransactionDetailId] = p.intTransactionDetailId
	,[strTransactionId] = p.strTransactionId
	,[intTransactionTypeId] = p.intTransactionTypeId
	,[intLotId] = p.intLotId
    ,[intSourceTransactionId] = p.intSourceTransactionId
    ,[strSourceTransactionId] = p.strSourceTransactionId
	,[intFobPointId] = p.intFobPointId
	,[intInTransitSourceLocationId] = p.intInTransitSourceLocationId
	,[intCurrencyId] = p.intCurrencyId
	,[intForexRateTypeId] = p.intForexRateTypeId
	,[dblForexRate] = p.dblForexRate
	,[intSourceEntityId] = p.intSourceEntityId
	,[strSourceType] = p.strSourceType
	,[strSourceNumber] = p.strSourceNumber
	,[strBOLNumber] = p.strBOLNumber
	,[intTicketId] = p.intTicketId 
	,[intOtherChargeItemId] = p.intOtherChargeItemId
FROM 
	@ValueToPost p
	INNER JOIN tblICItem i 
		ON p.intItemId = i.intItemId 
ORDER BY 
	p.intId

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @returnValue AS INT 

	EXEC @returnValue = dbo.uspICValidateCostingOnPostInTransit
		@ItemsToValidate = @StockToPost
		,@ValueToPost = @ValueToPostValidated

	IF @returnValue < 0 RETURN -1;
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
		,dblForexCost
		,dblSalesPrice
		,intCurrencyId
		--,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
		,intFobPointId
		,intInTransitSourceLocationId
		,intForexRateTypeId
		,dblForexRate
		,intSourceEntityId
		,strSourceType 
		,strSourceNumber 
		,strBOLNumber 
		,intTicketId

FROM	@StockToPost

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
	,@dblForexCost
	,@dblSalesPrice 
	,@intCurrencyId
	--,@dblExchangeRate
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSourceTransactionId
	,@intSourceTransactionDetailId
	,@strSourceTransactionId
	,@intFobPointId
	,@intInTransitSourceLocationId
	,@intForexRateTypeId
	,@dblForexRate
	,@intSourceEntityId
	,@strSourceType 
	,@strSourceNumber 
	,@strBOLNumber 
	,@intTicketId
;
	
-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 

	-- Initialize the transaction form
	SELECT	@strTransactionForm = strTransactionForm
	FROM	dbo.tblICInventoryTransactionType
	WHERE	intTransactionTypeId = @intTransactionTypeId
			AND strTransactionForm IS NOT NULL 

	-- Get the correct item location 
	EXEC uspICGetItemInTransitLocation @intItemId, NULL, @intItemLocationId OUTPUT 

	--------------------------------------------------------------------------------
	-- Call the SP that can process the In-Transit Costing 
	--------------------------------------------------------------------------------
	-- LOT 
	IF @intLotId IS NOT NULL 
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostLotInTransit
			@strSourceTransactionId -- @strActualCostId 
			,@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@dtmDate
			,@intLotId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblForexCost
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
			,@intFobPointId
			,@intInTransitSourceLocationId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId
			,@strSourceType 
			,@strSourceNumber 
			,@strBOLNumber 
			,@intTicketId
			;

		IF @intReturnValue < 0 GOTO _TerminateLoop;
	END

	-- ACTUAL COST 
	ELSE 
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostActualCostInTransit
			@strSourceTransactionId -- @strActualCostId 
			,@intItemId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@dtmDate 
			,@dblQty 
			,@dblUOMQty 
			,@dblCost 
			,@dblForexCost
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
			,@intFobPointId
			,@intInTransitSourceLocationId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId
			,@strSourceType 
			,@strSourceNumber 
			,@strBOLNumber 
			,@intTicketId
			;

		IF @intReturnValue < 0 GOTO _TerminateLoop;
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
		,@dblForexCost
		,@dblSalesPrice 
		,@intCurrencyId
		--,@dblExchangeRate
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSourceTransactionId
		,@intSourceTransactionDetailId
		,@strSourceTransactionId
		,@intFobPointId
		,@intInTransitSourceLocationId
		,@intForexRateTypeId
		,@dblForexRate
		,@intSourceEntityId
		,@strSourceType 
		,@strSourceNumber 
		,@strBOLNumber 
		,@intTicketId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

_TerminateLoop:

CLOSE loopItems;
DEALLOCATE loopItems;

IF @intReturnValue < 0 RETURN @intReturnValue; 


-----------------------------------------------------------------------------------------------------------------------------
-- LOOP for the In-Transit "value" Adjustments. 
-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
SELECT 
	@strSourceTransactionId = NULL 
	,@intItemId = NULL 
	,@intItemLocationId = NULL 
	,@intItemUOMId = NULL 
	,@dtmDate = NULL 
	,@intLotId = NULL 
	,@dblQty = NULL 
	,@dblUOMQty = NULL 
	,@dblCost = NULL 
	,@dblForexCost = NULL 
	,@dblSalesPrice = NULL 
	,@intCurrencyId = NULL 
	,@intTransactionId = NULL 
	,@intTransactionDetailId = NULL 
	,@strTransactionId = NULL 
	--,@strBatchId = NULL 
	--,@intTransactionTypeId = NULL 
	--,@strTransactionForm = NULL 
	--,@intEntityUserSecurityId = NULL 
	,@intFobPointId = NULL 
	,@intInTransitSourceLocationId = NULL 
	,@intForexRateTypeId = NULL 
	,@dblForexRate = NULL 
	,@intSourceEntityId = NULL 
	,@strSourceType = NULL 
	,@strSourceNumber = NULL 
	,@strBOLNumber = NULL 
	,@intTicketId = NULL 
	,@dblValue = NULL 
	,@intOtherChargeItemId = NULL 

DECLARE loopAdjustValue CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intId
		,[intItemId] 
		,[intItemLocationId] 
		,[dtmDate] = dbo.fnRemoveTimeOnDate(dtmDate) 
		,[dblValue] 
		,[intTransactionId] 
		,[intTransactionDetailId] 
		,[strTransactionId] 
		,[intTransactionTypeId] 
		,[intLotId] 
		,[intSourceTransactionId] 
		,[strSourceTransactionId] 
		,[intSourceTransactionDetailId] 
		,[intFobPointId] 
		,[intInTransitSourceLocationId] 
		,[intCurrencyId] 
		,[intForexRateTypeId] 
		,[dblForexRate] 
		,[intSourceEntityId] 
		,[strSourceType] 
		,[strSourceNumber] 
		,[strBOLNumber] 
		,[intTicketId] 
		,[intOtherChargeItemId]
FROM	@ValueToPostValidated

OPEN loopAdjustValue;

-- Initial fetch attempt
FETCH NEXT FROM loopAdjustValue INTO 
	@intId
	,@intItemId
	,@intItemLocationId
	,@dtmDate
	,@dblValue
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSourceTransactionId
	,@strSourceTransactionId
	,@intSourceTransactionDetailId
	,@intFobPointId
	,@intInTransitSourceLocationId
	,@intCurrencyId
	,@intForexRateTypeId
	,@dblForexRate
	,@intSourceEntityId
	,@strSourceType
	,@strSourceNumber
	,@strBOLNumber
	,@intTicketId 
	,@intOtherChargeItemId
;
	
-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 

	-- Initialize the transaction form
	SELECT	@strTransactionForm = strTransactionForm
	FROM	dbo.tblICInventoryTransactionType
	WHERE	intTransactionTypeId = @intTransactionTypeId
			AND strTransactionForm IS NOT NULL 

	-- Get the correct item location 
	EXEC uspICGetItemInTransitLocation @intItemId, NULL, @intItemLocationId OUTPUT 

	--------------------------------------------------------------------------------
	-- Call the SP that can process the In-Transit Costing 
	--------------------------------------------------------------------------------
	-- LOT 
	IF @intLotId IS NOT NULL 
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostLotInTransit
			@strSourceTransactionId -- @strActualCostId 
			,@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@dtmDate
			,@intLotId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblForexCost
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
			,@intFobPointId
			,@intInTransitSourceLocationId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId
			,@strSourceType 
			,@strSourceNumber 
			,@strBOLNumber 
			,@intTicketId
			,@dblValue
			,@intOtherChargeItemId
			;

		IF @intReturnValue < 0 GOTO _TerminateLoop2;
	END

	-- ACTUAL COST 
	ELSE 
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostActualCostInTransit
			@strSourceTransactionId -- @strActualCostId 
			,@intItemId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@dtmDate 
			,@dblQty 
			,@dblUOMQty 
			,@dblCost 
			,@dblForexCost
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
			,@intFobPointId
			,@intInTransitSourceLocationId
			,@intForexRateTypeId
			,@dblForexRate
			,@intSourceEntityId
			,@strSourceType 
			,@strSourceNumber 
			,@strBOLNumber 
			,@intTicketId
			,@dblValue
			,@intOtherChargeItemId
			;

		IF @intReturnValue < 0 GOTO _TerminateLoop2;
	END 

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopAdjustValue INTO 
		@intId
		,@intItemId
		,@intItemLocationId
		,@dtmDate
		,@dblValue
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSourceTransactionId
		,@strSourceTransactionId
		,@intSourceTransactionDetailId
		,@intFobPointId
		,@intInTransitSourceLocationId
		,@intCurrencyId
		,@intForexRateTypeId
		,@dblForexRate
		,@intSourceEntityId
		,@strSourceType
		,@strSourceNumber
		,@strBOLNumber
		,@intTicketId 
		,@intOtherChargeItemId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

_TerminateLoop2:

CLOSE loopAdjustValue;
DEALLOCATE loopAdjustValue;

IF @intReturnValue < 0 RETURN @intReturnValue; 


---------------------------------------------------------------------------------------
-- Make sure valuation is zero if stock is going to be zero. 
---------------------------------------------------------------------------------------
BEGIN 

	DECLARE @ItemsWithZeroQty AS TABLE (
		intId INT IDENTITY(1, 1) 
		,intItemId INT NULL
		,intItemLocationId INT NULL
		,intInTransitSourceLocationId INT NULL 
		,dblQty NUMERIC(38, 20) NULL
		,dblValue NUMERIC(38, 20) NULL
		,dblValueForex NUMERIC(38, 20) NULL
		,intCurrencyId INT NULL
		,intForexRateTypeId INT NULL 
		,dblForexRate NUMERIC(38, 20) NULL
		,strActualCostId NVARCHAR(50) NULL 
	)

	-- Get the in-transit with zero qty. 
	INSERT INTO @ItemsWithZeroQty (
		intItemId 
		,intItemLocationId 
		,intInTransitSourceLocationId 
		,dblQty 
		,dblValue 
		,dblValueForex 
		,intCurrencyId 
		,intForexRateTypeId
		,dblForexRate 
		,strActualCostId
	)
	SELECT 
		intItemId = s.intItemId
		,intItemLocationId = s.intItemLocationId
		,intInTransitSourceLocationId = s.intInTransitSourceLocationId
		,dblQty = currentValuation.dblQty
		,dblValue = currentValuation.dblValue
		,dblValueForex  = currentValuation.dblValueForex
		,intCurrencyId = currentValuation.intCurrencyId
		,intForexRateTypeId = currentValuation.intForexRateTypeId
		,dblForexRate = currentValuation.dblForexRate
		,strActualCostId = s.strSourceTransactionId
	FROM
		(
			SELECT DISTINCT 
				intItemId
				,intItemLocationId
				,intInTransitSourceLocationId
				,strSourceTransactionId
				,intLotId
			FROM @StockToPost
		) s
		OUTER APPLY (
			SELECT	dblQty = SUM(ROUND(ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0), 6))
			FROM	tblICInventoryLot cb 
			WHERE
					cb.strTransactionId = s.strSourceTransactionId						
					AND cb.intItemId = s.intItemId
					AND cb.intItemLocationId = s.intItemLocationId
					AND cb.intLotId = s.intLotId
					AND s.intLotId IS NOT NULL 
		) cbLot 
		OUTER APPLY (
			SELECT	dblQty = SUM(ROUND(ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0), 6))
			FROM	tblICInventoryActualCost cb 
			WHERE
					cb.strActualCostId = s.strSourceTransactionId						
					AND cb.intItemId = s.intItemId
					AND cb.intItemLocationId = s.intItemLocationId					
					AND s.intLotId IS NULL 
		) cbActualCost 
		OUTER APPLY 
		(
			SELECT 
				dblQty = SUM(ISNULL(t.dblQty, 0))
				,dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)) 
				,dblValueForex = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblForexCost, 0) + ISNULL(t.dblForexValue, 0), 2)) 
				,intCurrencyId
				,intForexRateTypeId
				,dblForexRate
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.intItemId = s.intItemId
				AND t.intItemLocationId = s.intItemLocationId 
				AND t.strActualCostId = s.strSourceTransactionId
				AND (
					t.intLotId = s.intLotId
					OR (t.intLotId IS NULL AND s.intLotId IS NULL) 
				)
				AND t.dblQty <> 0 
			GROUP BY 
				intCurrencyId
				,intForexRateTypeId
				,dblForexRate
		) currentValuation 
	WHERE
		(ISNULL(cbLot.dblQty, 0) = 0 OR ISNULL(cbActualCost.dblQty, 0) = 0)
		AND currentValuation.dblValue <> 0	

	SELECT	TOP 1 
			@dtmDate					= i2p.dtmDate
			,@intTransactionId			= i2p.intTransactionId
			,@strTransactionId			= i2p.strTransactionId
			--,@intCurrencyId				= i2p.intCurrencyId
	FROM	@StockToPost i2p 

	DECLARE 
		@dblAutoVariance AS NUMERIC(18, 6) 
		,@dblAutoVarianceForex AS NUMERIC(18, 6) 
		,@strAutoVarianceDescription NVARCHAR(255) 
		,@InventoryTransactionIdentityId AS INT 

	WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsWithZeroQty) 
	BEGIN 
		
		SET @intId = NULL
		SET @dblAutoVariance = NULL		
		SET @strAutoVarianceDescription = NULL 
		SET @InventoryTransactionIdentityId = NULL 
		SET @intItemId = NULL 
		SET @intItemLocationId = NULL 
		SET @dblAutoVariance = NULL 
		SET @dblAutoVarianceForex = NULL 
		SET @intCurrencyId = NULL 
		SET @intForexRateTypeId = NULL 
		SET @dblForexRate = NULL 
		SET @strActualCostId = NULL 

		SELECT TOP 1 
			@intId = intId
			,@intItemId = intItemId
			,@intItemLocationId = intItemLocationId
			,@intInTransitSourceLocationId = intInTransitSourceLocationId
			,@dblAutoVariance = -dblValue
			,@dblAutoVarianceForex = -dblValueForex
			,@intCurrencyId = intCurrencyId
			,@intForexRateTypeId = intForexRateTypeId
			,@dblForexRate = dblForexRate
			,@strActualCostId = strActualCostId
		FROM 
			@ItemsWithZeroQty

		--PRINT '@ItemsWithZeroQty'
		--PRINT @dblAutoVariance
		--PRINT @dblAutoVarianceForex
		--PRINT @intCurrencyId
		--PRINT @intForexRateTypeId
		--PRINT @dblForexRate
		--PRINT @strActualCostId

		SELECT	
			@strAutoVarianceDescription = 
				-- Stock quantity is now zero on {Item} in {Location}. Auto variance is posted to zero out its inventory valuation.
				dbo.fnFormatMessage(
						dbo.fnICGetErrorMessage(80093) 
						, i.strItemNo
						, CAST(il.strDescription AS NVARCHAR(100)) 
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
				)
		FROM	@ItemsWithZeroQty iWithZeroStock INNER JOIN tblICItem i
					ON i.intItemId = iWithZeroStock.intItemId
				INNER JOIN tblICItemLocation il
					ON il.intItemId = iWithZeroStock.intItemId
					AND il.intItemLocationId = iWithZeroStock.intItemLocationId
				CROSS APPLY [dbo].[fnICGetCompanyLocation](iWithZeroStock.intItemLocationId, iWithZeroStock.intItemLocationId) [location]
		WHERE
			ISNULL(@dblAutoVariance, 0) <> 0 OR ISNULL(@dblAutoVarianceForex, 0) <> 0 

		IF ISNULL(@dblAutoVariance, 0) <> 0 OR ISNULL(@dblAutoVarianceForex, 0) <> 0 
		BEGIN 
			EXEC [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = NULL 
				,@intSubLocationId = NULL
				,@intStorageLocationId = NULL 
				,@dtmDate = @dtmDate
				,@dblQty  = 0
				,@dblUOMQty = 0
				,@dblCost = 0
				,@dblForexCost = 0
				,@dblValue = @dblAutoVariance
				,@dblSalesPrice = 0
				,@intCurrencyId = @intCurrencyId 
				,@intTransactionId = @intTransactionId
				,@intTransactionDetailId = @intTransactionDetailId
				,@strTransactionId = @strTransactionId
				,@strBatchId = @strBatchId
				,@intTransactionTypeId = @AUTO_VARIANCE
				,@intLotId = NULL 
				,@intRelatedInventoryTransactionId = NULL 
				,@intRelatedTransactionId = NULL 
				,@strRelatedTransactionId = NULL 
				,@strTransactionForm = @strTransactionForm
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@intCostingMethod = @ACTUALCOST
				,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
				,@intFobPointId = NULL 
				,@intForexRateTypeId = @intForexRateTypeId
				,@dblForexRate = 1 --@dblForexRate
				,@strDescription = @strAutoVarianceDescription 
				,@intSourceEntityId = @intSourceEntityId
				,@strActualCostId = @strActualCostId
				,@dblForexValue = @dblAutoVarianceForex
				,@intInTransitSourceLocationId = @intInTransitSourceLocationId
		END 

		DELETE FROM @ItemsWithZeroQty
		WHERE
			@intId = intId
	END 
END 

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
--IF @strAccountToCounterInventory IS NOT NULL 
BEGIN 
	EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
		@strBatchId
		,@strAccountToCounterInventory
		,@intEntityUserSecurityId
		,@strGLDescription
		--,@intContraInventory_ItemLocationId

	IF @intReturnValue < 0 RETURN @intReturnValue
END 

-----------------------------------------
-- Call the Risk Log sp
-----------------------------------------
BEGIN 
	EXEC @intReturnValue = dbo.uspICLogRiskPositionFromInTransit
		@strBatchId
		,NULL
		,@intEntityUserSecurityId
END 
