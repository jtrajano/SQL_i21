﻿/*
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
DECLARE @dtmSytemGeneratedPostDate AS DATETIME = dbo.fnRemoveTimeOnDate(GETDATE()) 

INSERT INTO @StockToPost (	
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
		--CASE 
		--	WHEN lastTransaction.dtmDate IS NOT NULL THEN @dtmSytemGeneratedPostDate
		--	ELSE p.dtmDate
		--END 
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
	--OUTER APPLY (
	--	SELECT TOP 1 
	--		t.dtmDate
	--	FROM 
	--		tblICInventoryTransaction t
	--	WHERE
	--		t.strTransactionId = p.strTransactionId	
	--		AND t.strBatchId <> @strBatchId 
	--	ORDER BY 
	--		t.intInventoryTransactionId DESC 
	--) lastTransaction
ORDER BY 
	p.intId

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @returnValue AS INT 

	EXEC @returnValue = dbo.uspICValidateCostingOnPostInTransit
		@ItemsToValidate = @StockToPost

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

---------------------------------------------------------------------------------------
-- Make sure valuation is zero if stock is going to be zero. 
---------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ItemsWithZeroStock AS ItemCostingZeroStockTableType
			,@currentItemValue AS NUMERIC(38, 20)

	-- Get the qualified items for auto-negative. 
	INSERT INTO @ItemsWithZeroStock (
			intItemId
			,intItemLocationId
	)
	SELECT	DISTINCT 
			i2p.intItemId
			,i2p.intItemLocationId
	FROM	@StockToPost i2p 
	WHERE	ISNULL(dbo.fnGetCostingMethod(i2p.intItemId, i2p.intItemLocationId), 0) <> @AVERAGECOST

	DELETE	ZeroList
	FROM	@ItemsWithZeroStock ZeroList
			OUTER APPLY (
				SELECT	dblQty = SUM(ROUND(t.dblQty, 6)) 
				FROM	tblICInventoryTransaction t
				WHERE	t.intItemId = ZeroList.intItemId
						AND t.intItemLocationId = ZeroList.intItemLocationId
			) currentValuation	
	WHERE	ISNULL(currentValuation.dblQty, 0) <> 0 

	SELECT	TOP 1 
			@dtmDate					= i2p.dtmDate
			,@intTransactionId			= i2p.intTransactionId
			,@strTransactionId			= i2p.strTransactionId
			,@intCurrencyId				= i2p.intCurrencyId
	FROM	@StockToPost i2p 

	DECLARE 
		@dblAutoVariance AS NUMERIC(18, 6) 
		,@strAutoVarianceDescription NVARCHAR(255) 
		,@InventoryTransactionIdentityId AS INT 

	WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsWithZeroStock) 
	BEGIN 
		SELECT TOP 1 
			@intItemId = intItemId
			,@intItemLocationId = intItemLocationId
		FROM @ItemsWithZeroStock

		SET @dblAutoVariance = NULL		
		SET @strAutoVarianceDescription = NULL 
		SET @InventoryTransactionIdentityId = NULL 

		SELECT	
				
				@dblAutoVariance = -currentValuation.floatingValue
				,@strAutoVarianceDescription = 
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
		FROM	@ItemsWithZeroStock iWithZeroStock INNER JOIN tblICItem i
					ON i.intItemId = iWithZeroStock.intItemId
				INNER JOIN tblICItemLocation il
					ON il.intItemId = iWithZeroStock.intItemId
					AND il.intItemLocationId = iWithZeroStock.intItemLocationId
				CROSS APPLY [dbo].[fnICGetCompanyLocation](iWithZeroStock.intItemLocationId, iWithZeroStock.intItemLocationId) [location]
				OUTER APPLY (
					SELECT	floatingValue = SUM(
								ROUND(t.dblQty * t.dblCost + t.dblValue, 2)
							)
							,dblQty = SUM(ROUND(t.dblQty, 6)) 
					FROM	tblICInventoryTransaction t
					WHERE	t.intItemId = iWithZeroStock.intItemId
							AND t.intItemLocationId = iWithZeroStock.intItemLocationId
				) currentValuation
		WHERE	ISNULL(currentValuation.floatingValue, 0) <> 0
				AND ISNULL(currentValuation.dblQty, 0) = 0 

		IF @dblAutoVariance IS NOT NULL 
		BEGIN 
			EXEC [dbo].[uspICPostInventoryTransaction]
				@intItemId = @intItemId
				,@intItemLocationId = @intItemLocationId
				,@intItemUOMId = NULL 
				,@intSubLocationId = NULL
				,@intStorageLocationId = NULL 
				,@dtmDate = @dtmDate
				,@dblQty  = @dblQty
				,@dblUOMQty = 0
				,@dblCost = 0
				,@dblValue = @dblAutoVariance
				,@dblSalesPrice = 0
				,@intCurrencyId = NULL 
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
				,@intForexRateTypeId = NULL
				,@dblForexRate = 1
				,@strDescription = @strAutoVarianceDescription 
				,@intSourceEntityId = @intSourceEntityId
		END 

		DELETE FROM @ItemsWithZeroStock
		WHERE
			@intItemId = intItemId
			AND @intItemLocationId = intItemLocationId
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
