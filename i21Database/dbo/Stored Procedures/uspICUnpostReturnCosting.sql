﻿/*
	Used to reverse the stocks from a posted transaction.
*/
CREATE PROCEDURE [dbo].[uspICUnpostReturnCosting]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@ysnRecap AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
	DROP TABLE #tmpInventoryTransactionStockToReverse

-- Create the temp table 
CREATE TABLE #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId INT NOT NULL 
	,intTransactionId INT NULL 
	,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,intRelatedTransactionId INT NULL 
	,intTransactionTypeId INT NOT NULL 
	,dblQty NUMERIC(38,20) 
)

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

DECLARE @ItemsToUnpost AS dbo.UnpostItemsTableType

DECLARE @intItemId AS INT
		,@intItemUOMId AS INT 
		,@intItemLocationId AS INT 
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 					
		,@dblQty AS NUMERIC(38,20) 
		,@dblUOMQty AS NUMERIC(38,20)
		,@dblCost AS NUMERIC(38,20)
		,@intTransactionTypeId AS INT
		,@intLotId AS INT
		,@dtmDate AS DATETIME
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@strTransactionForm AS NVARCHAR(255)
		,@intCostingMethod AS INT
		,@intFobPointId AS TINYINT

-- Get the list of items to unpost
BEGIN 
	-- Insert the items per location, UOM, and if possible also by Lot. 
	INSERT INTO @ItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,dblCost
			,dblUOMQty
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId
			,intTransactionTypeId
			,intCostingMethod
			,intFobPointId
	)
	SELECT	t.intItemId
			,t.intItemLocationId
			,t.intItemUOMId
			,t.intLotId
			,ISNULL(-t.dblQty, 0)
			,t.dblCost
			,t.dblUOMQty		
			,t.intSubLocationId
			,t.intStorageLocationId
			,t.intInventoryTransactionId
			,t.intTransactionTypeId
			,t.intCostingMethod
			,t.intFobPointId
	FROM	dbo.tblICInventoryTransaction t
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
			AND ISNULL(t.dblQty, 0) <> 0 
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ValidateItemsToUnpost AS dbo.UnpostItemsTableType	
	DECLARE @returnValue AS INT 

	-- Aggregate the stock qty for a faster validation. 
	INSERT INTO @ValidateItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId		
	)
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,SUM(ISNULL(dblQty, 0))				
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId
	FROM	@ItemsToUnpost
	WHERE	ISNULL(intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION
	GROUP BY 
		intItemId
		, intItemLocationId
		, intItemUOMId
		, intLotId
		, intSubLocationId
		, intStorageLocationId
		, intInventoryTransactionId

	-- Fill-in the Unit qty from the UOM
	UPDATE	ValidateItemsToUnpost
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	@ValidateItemsToUnpost ValidateItemsToUnpost INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ValidateItemsToUnpost.intItemUOMId = ItemUOM.intItemUOMId

	EXEC @returnValue = dbo.uspICValidateCostingOnUnpost 
		@ValidateItemsToUnpost
		,@ysnRecap

	IF @returnValue < 0 RETURN -1;
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures. This is also used in Average Costing.
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	--EXEC dbo.uspICUnpostFIFOIn 
	--	@strTransactionId
	--	,@intTransactionId
	--	,@ysnRecap

	EXEC dbo.uspICUnpostFIFOOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	--EXEC dbo.uspICUnpostLIFOIn 
	--	@strTransactionId
	--	,@intTransactionId
	--	,@ysnRecap

	EXEC dbo.uspICUnpostLIFOOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END


-----------------------------------------------------------------------------------------------------------------------------
-- Call the LOT unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	--EXEC dbo.uspICUnpostLotIn 
	--	@strTransactionId
	--	,@intTransactionId
	--	,@ysnRecap

	EXEC dbo.uspICUnpostLotOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the Actual Costing unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	--EXEC dbo.uspICUnpostActualCostIn
	--	@strTransactionId
	--	,@intTransactionId
	--	,@ysnRecap

	EXEC dbo.uspICUnpostActualCostOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Unpost the auto-negative gl entries
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostAutoNegative
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

IF EXISTS (SELECT TOP 1 1 FROM #tmpInventoryTransactionStockToReverse) 
BEGIN 
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
			,[intCreatedEntityId]
			,[intConcurrencyId]
			,[intCostingMethod]
			,[strDescription]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
			,[intSourceEntityId]
			,[dtmDateCreated]
			,[intCompanyLocationId]	
			,[strSourceType]
			,[strSourceNumber]
			,[strBOLNumber]
			,[intTicketId]
	)			
	SELECT	
			[intItemId]								= ActualTransaction.intItemId
			,[intItemLocationId]					= ActualTransaction.intItemLocationId
			,[intItemUOMId]							= ActualTransaction.intItemUOMId
			,[intSubLocationId]						= ActualTransaction.intSubLocationId
			,[intStorageLocationId]					= ActualTransaction.intStorageLocationId
			,[dtmDate]								= dbo.fnRemoveTimeOnDate(ActualTransaction.dtmDate)
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
			,[intRelatedInventoryTransactionId]		= tactionsToReverse.intInventoryTransactionId
			,[intRelatedTransactionId]				= ActualTransaction.intRelatedTransactionId
			,[strRelatedTransactionId]				= ActualTransaction.strRelatedTransactionId
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedEntityId]					= @intEntityUserSecurityId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= ActualTransaction.intCostingMethod
			,[strDescription]						= ActualTransaction.strDescription
			,[intFobPointId]						= ActualTransaction.intFobPointId
			,[intInTransitSourceLocationId]			= ActualTransaction.intInTransitSourceLocationId
			,[intForexRateTypeId]					= ActualTransaction.intForexRateTypeId
			,[dblForexRate]							= ActualTransaction.dblForexRate
			,[intSourceEntityId]					= ActualTransaction.intSourceEntityId
			,[dtmDateCreated]						= GETUTCDATE()
			,[intCompanyLocationId]					= ActualTransaction.intCompanyLocationId
			,[strSourceType]						= ActualTransaction.strSourceType
			,[strSourceNumber]						= ActualTransaction.strSourceNumber
			,[strBOLNumber]							= ActualTransaction.strBOLNumber
			,[intTicketId]							= ActualTransaction.intTicketId

	FROM	#tmpInventoryTransactionStockToReverse tactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON tactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
	
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
		,[intCreatedEntityId] 
		,[intConcurrencyId] 
		,[intSourceEntityId]	
		,[strSourceType]
		,[strSourceNumber]
		,[strBOLNumber]
		,[intTicketId]		
	)
	SELECT	[intItemId]					= ActualTransaction.intItemId
			,[intLotId]					= ActualTransaction.intLotId
			,[intLocationId]			= ItemLocation.intLocationId
			,[intItemLocationId]		= ActualTransaction.intItemLocationId
			,[intSubLocationId]			= ActualTransaction.intSubLocationId
			,[intStorageLocationId]		= ActualTransaction.intStorageLocationId
			,[dtmDate]					= dbo.fnRemoveTimeOnDate(ActualTransaction.dtmDate)
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
			,[intCreatedEntityId]			= @intEntityUserSecurityId
			,[intConcurrencyId]			= 1
			,[intSourceEntityId]		= ActualTransaction.intSourceEntityId
			,[strSourceType]			= ActualTransaction.strSourceType
			,[strSourceNumber]			= ActualTransaction.strSourceNumber
			,[strBOLNumber]				= ActualTransaction.strBOLNumber
			,[intTicketId]				= ActualTransaction.intTicketId
	FROM	#tmpInventoryTransactionStockToReverse tactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON tactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
				AND ActualTransaction.intLotId IS NOT NULL 
				AND ActualTransaction.intItemUOMId IS NOT NULL
			INNER JOIN tblICItemLocation ItemLocation
				ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId
				AND ItemLocation.intLocationId IS NOT NULL 

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	Relatedtactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryTransaction Relatedtactions 
	WHERE	Relatedtactions.intRelatedTransactionId = @intTransactionId
			AND Relatedtactions.strRelatedTransactionId = @strTransactionId
			AND Relatedtactions.ysnIsUnposted = 0

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
	-- Update the Stock Quantity and Average Cost
	------------------------------------------------------------
	BEGIN 
		BEGIN 
			DECLARE loopItemsToUnpost CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  intItemId 
					,intItemUOMId 
					,intItemLocationId 
					,intSubLocationId 
					,intStorageLocationId 
					,dblQty 
					,dblUOMQty 
					,dblCost
					,intLotId 
					,intTransactionTypeId
					,intCostingMethod
					,intFobPointId
			FROM	@ItemsToUnpost 

			OPEN loopItemsToUnpost;	

			-- Initial fetch attempt
			FETCH NEXT FROM loopItemsToUnpost INTO 
				@intItemId
				,@intItemUOMId
				,@intItemLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@dblQty 
				,@dblUOMQty 
				,@dblCost
				,@intLotId
				,@intTransactionTypeId
				,@intCostingMethod
				,@intFobPointId
				;

			-----------------------------------------------------------------------------------------------------------------------------
			-- Start of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			WHILE @@FETCH_STATUS = 0
			BEGIN 
				-- Update the lot Qty for each inventory transaction being unposted. 
				UPDATE	Lot 
				SET		Lot.dblQty =	dbo.fnCalculateLotQty(
											Lot.intItemUOMId
											, @intItemUOMId
											, Lot.dblQty
											, Lot.dblWeight
											, @dblQty 
											, Lot.dblWeightPerQty
										)
						,Lot.dblWeight = dbo.fnCalculateLotWeight(
												Lot.intItemUOMId
												, Lot.intWeightUOMId
												, @intItemUOMId 
												, Lot.dblWeight
												, @dblQty 
												, Lot.dblWeightPerQty
											)
						,Lot.dblLastCost = CASE WHEN @dblQty > 0 THEN dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty) ELSE Lot.dblLastCost END 
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intItemLocationId = @intItemLocationId
						AND Lot.intLotId = @intLotId
						AND ISNULL(@intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION


				-- Recalculate the average cost from the inventory transaction table. 
				-- Except on Actual Costing. Do not compute the average cost when doing actual costing.
				UPDATE	ItemPricing
				SET		dblAverageCost = ISNULL(
							dbo.fnRecalculateAverageCost(intItemId, intItemLocationId)
							, dblAverageCost
						) 
						,ysnIsPendingUpdate = 1 
				FROM	dbo.tblICItemPricing ItemPricing	
				WHERE	ItemPricing.intItemId = @intItemId
						AND ItemPricing.intItemLocationId = @intItemLocationId
						AND ISNULL(@intCostingMethod, dbo.fnGetCostingMethod(intItemId, intItemLocationId)) <> @ACTUALCOST
						--AND ISNULL(@intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION

				------------------------------------------------------------
				-- Update the Item Pricing
				------------------------------------------------------------
				EXEC uspICUpdateItemPricing
					@intItemId
					,@intItemLocationId

				-- Update the stock quantities on tblICItemStock and tblICItemStockUOM tables. 
				IF ISNULL(@intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION
				BEGIN 
					EXEC [dbo].[uspICPostStockQuantity]
						@intItemId
						,@intItemLocationId
						,@intSubLocationId
						,@intStorageLocationId
						,@intItemUOMId
						,@dblQty
						,@dblUOMQty
						,@intLotId
						,@intTransactionTypeId
						,@dtmDate
				END 

				FETCH NEXT FROM loopItemsToUnpost INTO 
					@intItemId
					,@intItemUOMId
					,@intItemLocationId 
					,@intSubLocationId 
					,@intStorageLocationId 
					,@dblQty 
					,@dblUOMQty 
					,@dblCost
					,@intLotId
					,@intTransactionTypeId
					,@intCostingMethod
					,@intFobPointId
					;
			END;

			-----------------------------------------------------------------------------------------------------------------------------
			-- End of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			CLOSE loopItemsToUnpost;
			DEALLOCATE loopItemsToUnpost;
		END
	END
	
	---------------------------------------------------------------------------------------
	-- Create the AUTO-Negative if costing method is average costing
	---------------------------------------------------------------------------------------
	BEGIN 
		DECLARE @ItemsForAutoNegative AS UnpostItemsTableType

		-- Get the qualified items for auto-negative. 
		INSERT INTO @ItemsForAutoNegative (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intSubLocationId
				,intStorageLocationId
				,intInventoryTransactionId
		)
		SELECT 
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intSubLocationId
				,intStorageLocationId
				,intInventoryTransactionId
		FROM	@ItemsToUnpost
		WHERE	ISNULL(intCostingMethod, dbo.fnGetCostingMethod(intItemId, intItemLocationId)) = @AVERAGECOST
				AND dblQty > 0 
				AND ISNULL(intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION

		SELECT	TOP 1 
				@intCurrencyId				= intCurrencyId
				,@dtmDate					= dbo.fnRemoveTimeOnDate(dtmDate)
				,@dblExchangeRate			= dblExchangeRate
				,@intTransactionId			= intTransactionId
				,@strTransactionId			= strTransactionId
				,@strTransactionForm		= strTransactionForm
		FROM	dbo.tblICInventoryTransaction
		WHERE	strBatchId = @strBatchId
				AND ISNULL(ysnIsUnposted, 0) = 1 

		WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsForAutoNegative)
		BEGIN 
			SELECT TOP 1 
					@intItemId				= intItemId 
					,@intItemLocationId		= intItemLocationId
					,@intItemUOMId			= intItemUOMId
					,@intSubLocationId		= intSubLocationId
					,@intStorageLocationId	= intStorageLocationId
					,@intLotId				= intLotId
			FROM	@ItemsForAutoNegative

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
						,[intCreatedEntityId]
						,[intConcurrencyId]
						,[strDescription]
						,[dtmDateCreated]
						,[intCompanyLocationId]
				)			
			SELECT	
					[intItemId]								= @intItemId
					,[intItemLocationId]					= @intItemLocationId
					,[intItemUOMId]							= NULL 
					,[intSubLocationId]						= NULL 
					,[intStorageLocationId]					= NULL 
					,[dtmDate]								= @dtmDate
					,[dblQty]								= 0
					,[dblUOMQty]							= 0
					,[dblCost]								= 0
					,[dblValue]								=	dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) 
																- dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) 
					,[dblSalesPrice]						= 0
					,[intCurrencyId]						= @intCurrencyId
					,[dblExchangeRate]						= @dblExchangeRate
					,[intTransactionId]						= @intTransactionId
					,[strTransactionId]						= @strTransactionId
					,[strBatchId]							= @strBatchId
					,[intTransactionTypeId]					= @AUTO_NEGATIVE
					,[intLotId]								= NULL 
					,[ysnIsUnposted]						= 1
					,[intRelatedInventoryTransactionId]		= NULL 
					,[intRelatedTransactionId]				= NULL 
					,[strRelatedTransactionId]				= NULL 
					,[strTransactionForm]					= @strTransactionForm
					,[dtmCreated]							= GETDATE()
					,[intCreatedEntityId]					= @intEntityUserSecurityId
					,[intConcurrencyId]						= 1
					,[strDescription]						= -- Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s. 
															 dbo.fnFormatMessage(
																dbo.fnICGetErrorMessage(80078)
																, dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
																, Stock.dblUnitOnHand
																, ItemPricing.dblAverageCost
																, (Stock.dblUnitOnHand * ItemPricing.dblAverageCost)
																, DEFAULT
																, DEFAULT
																, DEFAULT
																, DEFAULT
																, DEFAULT
																, DEFAULT
															)
					,[dtmDateCreated]						= GETUTCDATE()
					,[intCompanyLocationId]					= [location].intCompanyLocationId
			FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
						ON ItemPricing.intItemId = Stock.intItemId
						AND ItemPricing.intItemLocationId = Stock.intItemLocationId
					CROSS APPLY [dbo].[fnICGetCompanyLocation](
						@intItemLocationId
						, NULL --@intInTransitSourceLocationId
					) [location]
			WHERE	ItemPricing.intItemId = @intItemId
					AND ItemPricing.intItemLocationId = @intItemLocationId			
					AND dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) <> 0

			-- Delete the item and item-location from the table variable. 
			DELETE FROM	@ItemsForAutoNegative
			WHERE	intItemId = @intItemId 
					AND intItemLocationId = @intItemLocationId
		END 
	END

END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
BEGIN 
	EXEC dbo.uspICCreateReversalReturnGLEntries 
		@strBatchId
		,@intTransactionId
		,@strTransactionId
		,@intEntityUserSecurityId
	;
END 

BEGIN 
	-- Delete the return records
	DELETE	rtn 
	FROM	tblICInventoryReturned rtn
	WHERE	rtn.intTransactionId = @intTransactionId
			AND rtn.strTransactionId = @strTransactionId
	;
END 

-------------------------------------------
-- Update the Valuation Summary
-------------------------------------------
BEGIN
	DECLARE @UpdateValuationSummary AS TABLE (
		intId INT IDENTITY(1, 1) 
		,intItemId INT 
		,intItemLocationId INT 
		,intItemUOMId INT
		,intInTransitSourceLocationId INT 
		,dtmDate DATETIME
		,dblCost NUMERIC(18, 6) NULL 
		,dblQty NUMERIC(18, 6) NULL 
		,dblValue NUMERIC(18, 6) NULL 
	)

	INSERT INTO @UpdateValuationSummary (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intInTransitSourceLocationId
		,dtmDate
		,dblCost
		,dblQty 
		,dblValue 
	)
	SELECT 
		t.intItemId
		,t.intItemLocationId
		,t.intItemUOMId
		,t.intInTransitSourceLocationId
		,t.dtmDate
		,t.dblCost
		,dblQty = SUM(t.dblQty) 		
		,dblValue = SUM(t.dblValue) 
	FROM 
		tblICInventoryTransaction t 
	WHERE
		t.strTransactionId = @strTransactionId
		AND t.strBatchId = @strBatchId
	GROUP BY 
		t.intItemId
		,t.intItemLocationId
		,t.intItemUOMId
		,t.intInTransitSourceLocationId
		,t.dtmDate
		,t.dblCost

	DECLARE 
		@intIdSummaryValuation INT
		,@intItemIdSummaryValuation INT 
		,@intItemLocationIdSummaryValuation INT 
		,@intItemUOMIdSummaryValuation INT
		,@intInTransitSourceLocationIdSummaryValuation INT 
		,@dtmDateSummaryValuation DATETIME
		,@dblCostSummaryValuation NUMERIC(18, 6) 
		,@dblQtySummaryValuation NUMERIC(18, 6) 
		,@dblValueSummaryValuation NUMERIC(18, 6) 

	WHILE EXISTS (SELECT TOP 1 1 FROM @UpdateValuationSummary) 
	BEGIN 
		SELECT 
			@intIdSummaryValuation = NULL 
			,@intItemIdSummaryValuation = NULL 
			,@intItemLocationIdSummaryValuation = NULL 
			,@intItemUOMIdSummaryValuation = NULL 
			,@intInTransitSourceLocationIdSummaryValuation = NULL 
			,@dtmDateSummaryValuation = NULL 
			,@dblCostSummaryValuation = NULL 
			,@dblQtySummaryValuation = NULL 
			,@dblValueSummaryValuation = NULL 

		SELECT TOP 1 
			@intIdSummaryValuation = intId
			,@intItemIdSummaryValuation = intItemId
			,@intItemLocationIdSummaryValuation = intItemLocationId
			,@intItemUOMIdSummaryValuation = intItemUOMId
			,@intInTransitSourceLocationIdSummaryValuation = intInTransitSourceLocationId
			,@dtmDateSummaryValuation = dtmDate
			,@dblCostSummaryValuation = dblCost
			,@dblQtySummaryValuation = dblQty
			,@dblValueSummaryValuation = dblValue
		FROM @UpdateValuationSummary 

		EXEC dbo.[uspICUpdateInventoryValuationSummary]
			@intItemId = @intItemIdSummaryValuation
			,@intItemLocationId = @intItemLocationIdSummaryValuation
			,@intSubLocationId = NULL 
			,@intStorageLocationId = NULL 
			,@intItemUOMId = @intItemUOMIdSummaryValuation
			,@dblQty = @dblQtySummaryValuation
			,@dblCost = @dblCostSummaryValuation
			,@dblValue = @dblValueSummaryValuation 
			,@intTransactionTypeId = NULL 
			,@dtmTransactionDate = @dtmDateSummaryValuation
			,@intInTransitSourceLocationId = @intInTransitSourceLocationIdSummaryValuation

		DELETE FROM @UpdateValuationSummary
		WHERE intId = @intIdSummaryValuation
	END 
END 

-----------------------------------------
-- Call the Risk Log sp
-----------------------------------------
BEGIN 
	EXEC dbo.uspICLogRiskPositionFromOnHand
		@strBatchId
		,@strTransactionId
		,@intEntityUserSecurityId
END 
